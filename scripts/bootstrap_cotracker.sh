#! /usr/bin/bash

kalib_dir=$1

source activate base
conda activate kalib

cd ${kalib_dir}/third_party/cotracker || exit
mkdir -p checkpoints
cd ./checkpoints || exit

# WGET_ARG="--spider"
WGET_ARG=""
wget https://huggingface.co/facebook/cotracker/resolve/main/cotracker2.pth ${WGET_ARG}

cd ${kalib_dir}/third_party/cotracker || exit
pip install -e .

cd ${kalib_dir}/ || exit
