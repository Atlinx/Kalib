#! /usr/bin/bash

kalib_dir=$1
cd ${kalib_dir}/third_party/droid || exit

source activate base
conda activate kalib

pip install -e .

# install additionally PyZed SDK API: https://github.com/stereolabs/zed-python-api
cd /tmp || exit
wget https://download.stereolabs.com/zedsdk/4.1/cu118/ubuntu22 -O zed_sdk_cu118_ubuntu22_zstd.run
apt update && apt install zstd && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
chmod +x zed_sdk_cu118_ubuntu22_zstd.run
./zed_sdk_cu118_ubuntu22_zstd.run -- silent

#! Attention! the rest part of code relies on opencv-contrib-python==4.10.0.82, while droid data extraction relies on opencv-contrib-python==4.6.0.66
# Fixing dependency issue triggered by droid requirements.txt.
pip uninstall -y opencv-python
pip install opencv-contrib-python==4.6.0.66
pip install "numpy<2.0"
pip install "torchvision"

cd ${kalib_dir}/ || exit
