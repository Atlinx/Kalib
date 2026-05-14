#! /usr/bin/bash

# Maintain here for API consistency.
kalib_dir=$1

source activate base
conda activate kalib

# https://github.com/robotflow-initiative/pyrfuniverse
mkdir -p /tmp
git clone https://github.com/mvig-robotflow/pyrfuniverse.git /tmp/pyrfuniverse
cd /tmp/pyrfuniverse || exit

# conda create -n rfuniverse python=3.10 -y
# conda activate rfuniverse

pip install -r requirements.txt

pip install -e .

# https://github.com/robotflow-initiative/rfuniverse
pyrfuniverse download -s /tmp/rfuniverse_release

# test
pip install pyrfuniverse-test
pyrfuniverse-test test_pick_and_place
