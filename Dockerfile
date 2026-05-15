FROM nvidia/cuda:12.8.2-devel-ubuntu22.04

# Set up env vars
#
# TORCH_CUDA_ARCH_LIST is obtained from torch.cuda.get_arch_list() for CUDA 12.8
# See https://en.wikipedia.org/wiki/CUDA#GPUs_supported for more details on supported compute capabilities for each CUDA SDK version.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="7.5 8.0 8.6 8.9 9.0 10.0 12.0+PTX" \
    WGET="wget -nv --show-progress --progress=bar:force:noscroll"

# Install tools
#   neovim git wget
# Fix libGL.so issues: https://stackoverflow.com/questions/55313610/importerror-libgl-so-1-cannot-open-shared-object-file-no-such-file-or-directo
#   libgl1 libglib2.0-0 
# Fix xrandr not found
#   x11-xserver-utils
# Dependency of easycalib/utils/utilities.py
#   proxychains4
RUN apt-get update && apt-get install -y sudo neovim git wget \
    libgl1 libglib2.0-0 x11-xserver-utils proxychains4

# Install Miniconda + init conda for "root" user's bash shell
RUN $WGET "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh \
    && conda tos accept

# Create conda environment
RUN conda create -n kalib python=3.10 -y \
    && conda clean -afy \
    && conda init bash

# Activate conda environment
SHELL ["conda", "run", "-n", "kalib", "/bin/bash", "-c"]

RUN conda info | grep active

# Create a non-root user for development
RUN useradd -m -s /bin/bash developer && \
    echo "developer:developer" | chpasswd && \
    usermod -aG sudo developer && \
    chown -R developer:developer /opt/conda
USER developer

# Set working directory
WORKDIR /home/developer

# Init conda for "developer" user's bash shell, and make shelf start in kalib env
RUN conda init bash \
    && echo "conda activate kalib" >> ~/.bashrc

# Install PyTorch with CUDA support
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128


# Install Kalib - rewrite git@github.com: SSH URLs to HTTPS so public submodules don't need SSH auth
RUN git config --global url."https://github.com/".insteadOf "git@github.com:" \
    && git clone https://github.com/Atlinx/Kalib.git \
    && cd Kalib \
    && git submodule update --init --recursive \
    && pip install meson-python Cython \
    && pip install -r requirements.txt --no-build-isolation


# Install Grounded-SAM
# Apply patched.ms_deform_attn_cuda.cu to support CUDA 12.8+
#   Fixes error: ms_deform_attn.py: "Failed to load custom C++ ops. Running on CPU mode Only!
#   See https://github.com/IDEA-Research/Grounded-Segment-Anything/issues/556
# Pin huggingface_hub, transformers, and litellm versions to avoid AttributeError: 'BertModel' object has no attribute 'get_head_mask'
#   See https://github.com/IDEA-Research/GroundingDINO/issues/446
# Download weights for groundingdino_swint_ogc.pth
#   See https://github.com/IDEA-Research/Grounded-Segment-Anything/issues/497
ENV AM_I_DOCKER=False BUILD_WITH_CUDA=True CUDA_HOME=/usr/local/cuda/
COPY ./patched.ms_deform_attn_cuda.cu /home/developer/Kalib/third_party/grounded_segment_anything/GroundingDINO/groundingdino/models/GroundingDINO/csrc/MsDeformAttn/ms_deform_attn_cuda.cu
RUN cd Kalib \
    && cd third_party/grounded_segment_anything \
    && pip install -e segment_anything \
    && pip install --no-build-isolation -e GroundingDINO \
    && pip install --upgrade diffusers[torch] \
    && cd grounded-sam-osx && bash install.sh \
    && cd .. \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --upgrade "huggingface_hub<1.0"  "transformers==4.37" "litellm" \
    && $WGET "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth"


# Download SAM model checkpoints
# Store in pretrained_checkpoints and link to grounded grounded_segment_anything
RUN cd Kalib \
    && mkdir pretrained_checkpoints \
    && ln -sf /home/developer/Kalib/pretrained_checkpoints /home/developer/Kalib/third_party/grounded_segment_anything/ \
    && cd pretrained_checkpoints \
    && $WGET "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" \
    && $WGET "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth" \
    && $WGET "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"


# Install SpaTracker
# Replace cupy with prebuild cupy version to avoid build issues in docker
# Download SpaTracker model checkpoints (spaT_final.pth) from https://drive.google.com/file/d/18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX/view
#
# See ./bootstrap_spatial_tracker.sh for more info
RUN cd Kalib/third_party/spatial_tracker \
    && sed -i 's/cupy==12\.2\.0/cupy-cuda12x==12.2.0/g' requirements.txt \
    && cat requirements.txt \
    && pip install -r requirements.txt \
    && pip install gdown \
    && mkdir checkpoints \
    && cd checkpoints \
    && gdown 18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX -O spaT_final.pth \
    && cd .. \
    && mkdir -p ./models/monoD/zoeDepth/ckpts \
    && cd ./models/monoD/zoeDepth/ckpts \
    && $WGET "https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_K.pt" \
    && $WGET "https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_NK.pt" \
    && $WGET "https://github.com/isl-org/MiDaS/releases/download/v3_1/dpt_beit_large_384.pt" 


# Install Co-Tracker
# See ./bootstrap_cotracker.sh
RUN cd Kalib/third_party/cotracker \
    && mkdir -p checkpoints \
    && cd checkpoints \
    && $WGET "https://huggingface.co/facebook/cotracker/resolve/main/cotracker2.pth" \
    && cd .. \
    && pip install -e .

# Install Kalib package
RUN cd Kalib && pip install -e .

WORKDIR /home/developer/Kalib

# Default command, open shell in the "kalib" conda environment
CMD ["/bin/bash"]

