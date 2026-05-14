FROM nvidia/cuda:12.6.2-devel-ubuntu22.04

# Set up env vars
#
# TORCH_CUDA_ARCH_LIST is obtained from torch.cuda.get_arch_list() for CUDA 12.6
# See https://en.wikipedia.org/wiki/CUDA#GPUs_supported for more details on supported compute capabilities for each CUDA SDK version.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="5.0 6.0 7.0 7.5 8.0 8.6 9.0+PTX"

# Install tools
RUN apt-get update && apt-get install -y sudo neovim git wget

# Install Miniconda + init conda for "root" user's bash shell
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
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
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126


# Install Kalib - rewrite git@github.com: SSH URLs to HTTPS so public submodules don't need SSH auth
RUN git config --global url."https://github.com/".insteadOf "git@github.com:" \
    && git clone https://github.com/Atlinx/Kalib.git \
    && cd Kalib \
    && git submodule update --init --recursive \
    && pip install meson-python Cython \
    && pip install -r requirements.txt --no-build-isolation


# Install Grounded-SAM
ENV AM_I_DOCKER=False BUILD_WITH_CUDA=True CUDA_HOME=/usr/local/cuda/
RUN cd Kalib \
    && cd third_party/grounded_segment_anything \
    && pip install -e segment_anything \
    && pip install --no-build-isolation -e GroundingDINO \
    && pip install --upgrade diffusers[torch] \
    && cd grounded-sam-osx && bash install.sh \
    && cd .. \
    && pip install --no-cache-dir -r requirements.txt


# Download SAM model checkpoints
# Store in pretrained_checkpoints and link to grounded grounded_segment_anything
RUN cd Kalib \
    && mkdir pretrained_checkpoints \
    && ln -sf /home/developer/Kalib/pretrained_checkpoints /home/developer/Kalib/third_party/grounded_segment_anything/ \
    && cd pretrained_checkpoints \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth" \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"


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
    && wget https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_K.pt \
    && wget https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_NK.pt \
    && wget https://github.com/isl-org/MiDaS/releases/download/v3_1/dpt_beit_large_384.pt 


# Install Co-Tracker
# See ./bootstrap_cotracker.sh
RUN cd Kalib/third_party/cotracker \
    && mkdir -p checkpoints \
    && cd checkpoints \
    && wget https://huggingface.co/facebook/cotracker/resolve/main/cotracker2.pth \
    && cd .. \
    && pip install -e .

# Install Kalib package
RUN cd Kalib && pip install -e .

USER root
# Fix libGL.so issues: https://stackoverflow.com/questions/55313610/importerror-libgl-so-1-cannot-open-shared-object-file-no-such-file-or-directo
RUN apt-get install -y libgl1 libglib2.0-0
USER developer

WORKDIR /home/developer/Kalib

# Default command, open shell in the "kalib" conda environment
CMD ["/bin/bash"]

