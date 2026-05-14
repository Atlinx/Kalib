#! /usr/bin/bash

kalib_dir=$1

source activate base
conda activate kalib

export AM_I_DOCKER=False
export BUILD_WITH_CUDA=True

python -m pip install -e segment_anything

cd ${kalib_dir}/third_party/grounded_segment_anything || exit
pip install --no-build-isolation .
cd - || exit

pip install --upgrade diffusers[torch]

git submodule update --init --recursive
cd grounded-sam-osx && bash install.sh

cd ${kalib_dir}/third_party/grounded_segment_anything || exit

python -m pip install --no-cache-dir -r requirements.txt

# Alrealy soft linked in bootstrap_sam.sh
# wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
wget https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth

cd ${kalib_dir}/ || exit