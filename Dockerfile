FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

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

# Install Kalib
# RUN git clone https://github.com/Atlinx/Kalib.git \
#     && cd Kalib \
#     && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126 \
#     && pip install meson-python Cython \
#     && pip install -r requirements.txt --no-build-isolation

# # Install Grounded-SAM
# ENV AM_I_DOCKER=False BUILD_WITH_CUDA=True CUDA_HOME=/usr/local/cuda/

# RUN git clone https://github.com/IDEA-Research/Grounded-Segment-Anything.git \
#     && cd Grounded-Segment-Anything \
#     && python -m pip install -e segment_anything \
#     && pip install --no-build-isolation -e GroundingDINO \
#     && pip install --upgrade diffusers[torch] \
#     && git submodule update --init --recursive

# RUN cd Grounded-Segment-Anything/grounded-sam-osx && bash install.sh \

# RUN cd Grounded-Segment-Anything \
#     && git clone https://github.com/xinyu1205/recognize-anything.git \
#     && pip install -r ./recognize-anything/requirements.txt \
#     && pip install -e ./recognize-anything/ \
#     && pip install opencv-python pycocotools matplotlib onnxruntime onnx ipykernel

# # Download SAM checkpoints
# RUN cd Kalib \
#     && sam_ckpts_dir="./pretrained_checkpoints" \
#     && mkdir -p "$sam_ckpts_dir" \
#     && wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" \
#     && wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth" \
#     && wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"

# Create a non-root user for development (optional but recommended)
RUN useradd -m -s /bin/bash developer && \
    echo "developer:developer" | chpasswd && \
    usermod -aG sudo developer && \
    chown -R developer:developer /workspace /opt/conda

USER developer

# Init conda for "developer" user's bash shell
RUN conda init bash

# Default command, open shell in the "kalib" conda environment
CMD ["/bin/bash", "-c", "source /opt/conda/etc/profile.d/conda.sh && conda activate kalib && exec /bin/bash -i"]

