#! /usr/bin/bash

kalib_dir=$1

source activate base
conda activate kalib

# ! Installing dependencies.
cd "${kalib_dir}"/third_party/spatial_tracker/ || exit

cat requirements.txt | sed '$d' | xargs -n1 pip install 
pip install cupy-cuda11x 

mkdir -p ./checkpoints/

# Downlaod the SpaT_final.pth
cd ./checkpoints || exit
gdown --id 18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX
# https://drive.google.com/file/d/18YlG_rgrHcJ7lIYQWfRz_K669z6FdmUX/view?usp=drive_link

cd "${kalib_dir}"/third_party/spatial_tracker || exit

mkdir -p ./models/monoD/zoeDepth/ckpts

# WGET_ARG="--spider"
WGET_ARG=""
# https://github.com/isl-org/ZoeDepth/releases/tag/v1.0
wget https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_K.pt -P ./models/monoD/zoeDepth/ckpts/ ${WGET_ARG}
wget https://github.com/isl-org/ZoeDepth/releases/download/v1.0/ZoeD_M12_NK.pt -P ./models/monoD/zoeDepth/ckpts/ ${WGET_ARG}

# https://github.com/isl-org/MiDaS/releases
wget https://github.com/isl-org/MiDaS/releases/download/v3_1/dpt_beit_large_384.pt -P ./models/monoD/zoeDepth/ckpts/ ${WGET_ARG}

cd "${kalib_dir}"/ || exit
