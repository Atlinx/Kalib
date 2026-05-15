#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Use first argument as dataset dir, or default to test_sample_droid_data
if [ -n "$1" ]; then
    DATASET_DIR="$1"
else
    DATASET_DIR="$SCRIPT_DIR/dataset/test_sample_droid_data"
fi

cd $SCRIPT_DIR
python easycalib_demo.py  --root_dir $DATASET_DIR \
    --use_segm_mask false \
    --caliberate_method pnp \
    --pnp_refinement true \
    --use_pnp_ransac false \
    --use_grounded_sam \
    --has_gt \
    --win_len 1 \
    --verbose \
    --render_mask \
    --easyhec_repo_path $SCRIPT_DIR/third_party/easyhec/ \
    --grounded_sam_repo_path $SCRIPT_DIR/third_party/grounded_segment_anything/ \
    --spatial_tracker_repo_path $SCRIPT_DIR/third_party/spatial_tracker/ \
    --cut_off 1 \
    --renderer_device_id 0 \
    --tracking_device_id 0 \
    --mask_inference_device_id 0 \
    --keypoint_ids 0 \
    --sam_type vit_b # Smaller sized SAM model