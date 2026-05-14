#! /usr/bin/bash

kalib_dir=$1

source activate base
conda activate kalib

sam_ckpts_dir=${kalib_dir}"/pretrained_checkpoints"
mkdir -p "$sam_ckpts_dir"

# WGET_ARG="--spider"
WGET_ARG=""

wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth"  ${WGET_ARG}
wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth"  ${WGET_ARG}
wget -P "$sam_ckpts_dir" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"  ${WGET_ARG}

# Optionally, if you want to use foreground mask to guide the kpt tracking module to maximize performance gain, download these sam checkpoints and link them to Grounded-SAM.
# Additionally, link the downloaded SAM checkpoints to Grounded-SAM root path as Grounded-SAM are using SAM ckpts too.
ln -sf ${kalib_dir}/pretrained_checkpoints ${kalib_dir}/third_party/grounded_segment_anything/