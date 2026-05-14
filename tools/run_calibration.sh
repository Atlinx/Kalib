#!/bin/bash
REPO_DIR=$(dirname "$(readlink -f "$0/..")")

DATASET_DIR=$REPO_DIR/dataset/test_sample_droid_data
cd $REPO_DIR
python easycalib_demo.py  --root_dir $DATASET_DIR \
    --use_segm_mask true \
    --caliberate_method pnp \
    --pnp_refinement true \
    --use_pnp_ransac false \
    --use_grounded_sam \
    --has_gt \
    --win_len 1 \
    --verbose \
    --render_mask \
    --easyhec_repo_path $REPO_DIR/third_party/easyhec/ \
    --grounded_sam_repo_path $REPO_DIR/third_party/grounded_segment_anything/ \
    --spatial_tracker_repo_path $REPO_DIR/third_party/spatial_tracker/ \
    --cut_off 300 \
    --renderer_device_id 0 \
    --tracking_device_id 0 \
    --mask_inference_device_id 0 \
    --keypoint_ids 0