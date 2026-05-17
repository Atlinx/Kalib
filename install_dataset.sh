#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

cd $SCRIPT_DIR
mkdir -p dataset
cd dataset
gdown --folder 1gAONRRWb03m35hICTFaAhAC52EN8A9ba -O drive_dataset
cd drive_dataset
# Unzip all zip files into the parent folder (dataset), then remove the zip files
find . -type f -name "*.zip" -exec unzip -d .. {} \; -exec rm {} \;
cd ..
rm -rf drive_dataset
mkdir -p exp_droid_list
mv exp_droid_list.txt exp_droid_list/exp_droid_list.txt