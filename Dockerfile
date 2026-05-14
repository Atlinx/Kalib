FROM nvidia/cuda:12.6.2-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libopencv-dev \
    pkg-config \
    python3-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda + init conda for "root" user's bash shell
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh \
    && conda tos accept \
    && conda init bash

# Create conda environment
RUN conda create -n kalib python=3.10 -y \
    && conda clean -afy \
    && conda init bash

# Install additional tools
RUN apt-get update && apt-get install -y sudo neovim

# Activate conda environment
SHELL ["conda", "run", "-n", "kalib", "/bin/bash", "-c"]

RUN conda info | grep active

# Set working directory
WORKDIR /workspace

# Create a non-root user for development
RUN useradd -m -s /bin/bash developer && \
    echo "developer:developer" | chpasswd && \
    usermod -aG sudo developer && \
    chown -R developer:developer /workspace /opt/conda
USER developer

# Init conda for "developer" user's bash shell, and make shelf start in kalib env
RUN conda init bash \
    && echo "conda activate kalib" >> ~/.bashrc

# Install PyTorch with CUDA support
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Obtained from torch.cuda.get_arch_list() for CUDA 12.6
# See https://en.wikipedia.org/wiki/CUDA#GPUs_supported for more details on supported compute capabilities for each CUDA SDK version.
ENV TORCH_CUDA_ARCH_LIST="5.0 6.0 7.0 7.5 8.0 8.6 9.0+PTX"


# Install Kalib
RUN --mount=type=ssh git clone https://github.com/Atlinx/Kalib.git \
    && cd Kalib \
    && git submodule update --init --recursive \
    && pip install meson-python Cython \
    && pip install -r requirements.txt --no-build-isolation


# Install Grounded-SAM
# Download Grounded-SAM model checkpoints
ENV AM_I_DOCKER=False BUILD_WITH_CUDA=True CUDA_HOME=/usr/local/cuda/
RUN cd Kalib/third_party/grounded_segment_anything \
    && python -m pip install -e segment_anything \
    && pip install --no-build-isolation -e GroundingDINO \
    && pip install --upgrade diffusers[torch] \
    && bash install.sh \
    && git clone https://github.com/xinyu1205/recognize-anything.git \
    && pip install -r ./recognize-anything/requirements.txt \
    && pip install -e ./recognize-anything/ \
    && pip install opencv-python pycocotools matplotlib onnxruntime onnx ipykernel \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth" \
    && wget "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"


# Install SpaTracker
# Download SpaTracker model checkpoints (spaT_final.pth) from https://drive.google.com/file/d/18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX/view
RUN cd Kalib/third_party/spatial_tracker \
    && pip install -r requirements.txt \
    && pip install gdown \
    && mkdir checkpoints \
    && cd checkpoints \
    && gdown 18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX -O spaT_final.pth


# Install Co-Tracker
RUN cd Kalib/third_party/co_tracker \
    && pip install -e . \
    && pip install matplotlib flow_vis tqdm tensorboard


# Default command, open shell in the "kalib" conda environment
CMD ["/bin/bash"]

