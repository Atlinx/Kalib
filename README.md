<p align="center">
  <h3 align="center"><strong>Kalib: <br>Markerless</br> Hand-Eye Calibration with Keypoint Tracking</strong></h3>

<p align="center">
    <a href="https://github.com/ElectronicElephant">Tutian Tang</a><sup>1</sup>,
    <a href="https://github.com/Learner209">Minghao Liu</a><sup>1</sup>,
    <a href="https://wenqiangx.github.io/">Wenqiang Xu</a><sup>1</sup>,
    <a href="https://www.mvig.org/">CeWu Lu</a><sup>1</sup><span class="note">*</span>,
    <br>
    <br>
    <sup>*</sup>Corresponding authors.
    <br>
    <sup>1</sup>Shanghai Jiao Tong University
    <br>
</p>

<div align="center">

<img src="https://img.shields.io/badge/Python-v3-E97040?logo=python&logoColor=white" /> &nbsp;&nbsp;&nbsp;&nbsp;
<img alt="powered by Pytorch" src="https://img.shields.io/badge/PyTorch-❤️-F8C6B5?logo=pytorch&logoColor=white"> &nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://img.shields.io/badge/Conda-Supported-lightgreen?style=social&logo=anaconda" /> &nbsp;&nbsp;&nbsp;&nbsp;
<a href='https://sites.google.com/view/hand-eye-kalib'><img src='https://img.shields.io/badge/Project-Page-Green'></a> &nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FLearner209%2FKalib&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>

</div>

<!-- # **Kalib**: Markerless Hand-Eye Calibration with Keypoint Tracking

The official code repository for our paper: **Kalib: Markerless Hand-Eye Calibration with Keypoint Tracking.** -->

## ❖ Contents

- [❖ Contents](#-contents)
- [❖ Introduction:](#-introduction)
- [❖ Installation](#-installation)
- [❖ Download sample data and reproducibility.](#-download-sample-data-and-reproducibility)
- [❖ Usage](#-usage)
- [❖ Dataset Conventions](#-dataset-conventions)
- [❖ ✨Stars/forks/issues/PRs are all welcome!](#-starsforksissuesprs-are-all-welcome)
- [❖ Last but Not Least](#-last-but-not-least)

## ❖ Introduction:

Hand-eye calibration involves estimating the transformation between the camera and the robot. Traditional methods rely on fiducial markers, involving much manual labor and careful setup.
Recent advancements in deep learning offer markerless techniques, but they present challenges, including the need for retraining networks for each robot, the requirement of accurate mesh models for data generation, and the need to address the sim-to-real gap.
In this letter, we propose **Kalib**, an automatic and universal markerless hand-eye calibration pipeline that leverages the generalizability of visual foundation models to eliminate these barriers.
In each calibration process, **Kalib** uses keypoint tracking and proprioceptive sensors to estimate the transformation between a robot's coordinate space and its corresponding points in camera space.
Our method does not require training new networks or access to mesh models. Through evaluations in simulation environments and the real-world dataset DROID, **Kalib** demonstrates superior accuracy compared to recent baseline methods.
This approach provides an effective and flexible calibration process for various robot systems by simplifying setup and removing dependency on precise physical markers.

🤗 Please cite [Kalib](https://github.com/robotflow-initiative/Kalib) in your publications if it helps with your work. Please star🌟 this repo to help others notice **Kalib** if you think it is useful. Thank you!
😉

## ❖ Installation

We run on `Ubuntu 22.04 LTS` with a system configured with $2\times$ NVIDIA RTX A40 GPU. We also provide Dockerfile for different stages.

1. Use conda to create a env for **Kalib** and activate it.

```bash
conda create -n kalib python==3.10
conda activate kalib
pip install -r requirements.txt
```

2. Install spatial tracker.

Please refer to [Spatracker readme](https://github.com/henry123-boy/SpaTracker/blob/main/README.md)

Additionally, download the `SpaT_final.pth` checkpoints into `./third_party/spatial_tracker/checkpoints/` directory.

Alternatively, you can choose to setup the spatial-tracker env with `bash scripts/bootstrap_spatial_tracker.sh $PWD`

3. Install **Kalib** as a package.

```bash
cd <your-project-root-directory>
pip install -e .
```

> Docker command:
>
> ```bash
> DOCKER_BUILDKIT=1 docker build -t kalib_build --target build  --progress=plain . 2>&1 | tee build.log
> ```

> **📣 Attention :**, Optionally, you can use foreground mask to refine the keypoint tracking module. To do so, you need to install the following dependencies:

4. (**Optional**) Download SAM checkpoints.

```bash
bash scripts/bootstrap_sam.sh $PWD
```

> Note: If you wanna specify the sam checkpoints path(the default is \_sam_vit_l), plz modify default value in [sam_type](./easycalib/config/parse_demo_argument.py#L49) and [sam_checkpoint_path](./easycalib/config/parse_demo_argument.py#L43) or pass it as an argument.

5. (**Optional**) Grounded-SAM installation.

Please refer to [Grounded-SAM readme](https://github.com/IDEA-Research/Grounded-Segment-Anything/blob/main/README.md).

Alternatively, you can choose to setup the grounded-sam env with `bash scripts/bootstrap_grounded_sam.sh $PWD`

> Docker command:
>
> ```bash
> DOCKER_BUILDKIT=1 docker build -t kalib_grounded_sam --target sam_included  --progress=plain . 2>&1 | tee build.log
> ```

6. (**Optional**) Install cotracker if you wanna dabble into different keypoint-tracking module.

Please refer to [CoTracker readme](https://github.com/facebookresearch/co-tracker/blob/main/README.md)
Alternatively, you can choose to setup the cotracker env with `bash scripts/bootstrap_cotracker.sh $PWD`

> Docker command:
>
> ```bash
> DOCKER_BUILDKIT=1 docker build -t kalib_cotracker --target cotracker_included  --progress=plain . 2>&1 | tee build.log
> ```

## ❖ Download sample data and reproducibility.

1. Synthetic dataset generated with [pyrfuniverse](https://github.com/robotflow-initiative/pyrfuniverse): `all_exp_pyrfuniverse_sim_data`.
2. Our experimental results reported in the paper use the following _DROID_ takes: `exp_droid_list/exp_droid_list.txt`.
3. Download test sample data for both sim and _DROID_: `test_sample_droid_data`, `test_sample_sim_data`.
4. Download test sampel data for running procesing script on _DROID_: `test_extract_droid_data`.

Plz download these data from this [google drive link](https://drive.google.com/drive/folders/1gAONRRWb03m35hICTFaAhAC52EN8A9ba?usp=sharing) or instead use [this script](./dataset/populate_data.sh) to populate data in `./dataset` folder.
When the download completes ,the folder structure of `./dataset` should look like this:

```bash
.
├── all_exp_pyrfuniverse_sim_data
├── exp_droid_list/exp_droid_list.txt
├── test_extract_droid_data
├── test_sample_droid_data
├── test_sample_sim_data
└── populate_data.sh

```

## ❖ Usage

1. Running the camera calibration pipeline (this script loads the images and jsons specified by `dataset_dir`, shows a window prompting the user for one single-click(Use _Esc_ to quit the window), passes the **initially** annotated **TCP** point to kpt tracking module, and finally calls the **PNP** module to infer the camera pose.). A file with path `<your_dataset_dir>/Kalib/Kalib_outputs/pnp_inference_res.pkl` will be saved to disk afterwards, it contains keys: `avg_trans_err,avg_rot_err,avg_reprojection_error,pnp_transform_predicted_mats`. Its format can be known in [here](./easycalib_demo.py#L205).

```bash
grounded_sam_repo_path=$PWD/third_party/grounded_segment_anything/
spatial_tracker_repo_path=$PWD/third_party/spatial_tracker/
device_id=0;
dataset_dir=$PWD/dataset/test_sample_droid_data/; keypoints_id=0;
# Uncomment below to test on sample sim data.
# dataset_dir=$PWD/dataset/test_sample_sim_data/; keypoints_id=0;

python easycalib_demo.py  --root_dir $dataset_dir --use_segm_mask true --caliberate_method pnp --pnp_refinement true --use_pnp_ransac false --use_grounded_sam --has_gt --win_len 1 --verbose --render_mask --grounded_sam_repo_path $grounded_sam_repo_path --spatial_tracker_repo_path $spatial_tracker_repo_path --cut_off 300 --renderer_device_id ${device_id} --tracking_device_id ${device_id} --mask_inference_device_id ${device_id} --keypoint_ids ${keypoints_id}
```

Parameters:

-   `root_dir`: where you stored all your video frames and json data.
-   `use_segm_mask`: whether to use foreground mask to guide kpt tracking module.
-   `use_grounded_sam`: whether to use Grounded-SAM to automatically generate robot arm mask, the default prompt for mask segmentation is `robot arm`, to change prompt: use `--text_prompt` in argparse.
-   `cut_off`: only process first $cut_off frames for both computational efficiency and kpt tracking stability.
-   `renderer_device_id`, `tracking_device_id`, `mask_inference_device_id`, the gpu_id for rendering mask, tracking annotated TCP and use SAM/Grounded-SAM to inference foreground mask.
-   `keypoint_ids`: choose what keypoints to be tracked. The keypoint configurations are specified in [franka_config.json](./easycalib/config/franka_config.json). **NOTE**: the num of keypoint_ids should be consistent with your number of clicks in the prompting window, otherwise it is undefined behaviour.

2. (**Optional**) If you wanna generate synthetic data and run the synthetic data generation pipeline:
   We use pyrfuniverse as our simulation environment, please refer to [pyrfuniverse](https://github.com/robotflow-initiative/pyrfuniverse) for more details.
   Alternatively, you can choose to setup the pyrfuniverse env with `bash scripts/bootstrap_pyrfuniverse.sh $PWD`

```bash
python ./tests/sim_franka/test_gaussian_trajectory.py
```

> Docker command:
>
> ```bash
> DOCKER_BUILDKIT=1 docker build -t kalib_rfu --target pyrfuniverse_included  --progress=plain . 2>&1 | tee build.log
> ```

3. (**Optional**) If you wanna test our pipeline on other takes in _DROID_ dataset, you can run the _DROID_ processing and data conversion script. Please refer to [droid](https://github.com/droid-dataset/droid) for more details.

> **📣 Attention :**, you have to setup [pyzed_sdk](https://www.stereolabs.com/docs/app-development/python/install) in your conda env for this step, check out more info about this in [bootstrap_droid.sh](./scripts/bootstrap_droid.sh#L11).

Alternatively, you can choose to setup the droid env with `bash scripts/bootstrap_droid.sh`

```bash
python easycalib/utils/process_droid_data.py --data_dir ./dataset/test_extract_droid_data --data_save_path ./dataset/processed_droid_data
```

> Docker command:
>
> ```bash
> DOCKER_BUILDKIT=1 docker build -t kalib_droid --target droid_included  --progress=plain . 2>&1 | tee build.log
> ```

## ❖ Dataset Conventions

The video frames can be saved to `.png` or `.jpg` format, along with which an accompanying json file should be stored. For alignment between corresponding video frame and json file, they should be sorted alphabetically in ascending order.
A template json format for specifying the robot configurations at the same timestamp with its image counterpart is in [template_config.json](./easycalib/config/template_config.json).

A more elaborated example is as follows:

```json
{
    "objects": [
        {
            "class": "panda",
            "visibility": 1,
            "location": [
                854.9748197663477,
                532.4341293247742
            ],
            "camera_intrinsics": [
                [
                    935.3074360871939,
                    0.0,
                    960.0
                ],
                [
                    0.0,
                    935.3074360871938,
                    540.0
                ],
                [
                    0.0,
                    0.0,
                    1.0
                ]
            ],
            "local_to_world_matrix": [ // The gt local_to_world_matrix, only valid when gt data is present.
                [
                    0.936329185962677,
                    0.3511234521865845,
                    0.0,
                    -0.26919466257095337
                ],
                [
                    0.1636243760585785,
                    -0.4363316595554352,
                    -0.8847835659980774,
                    -0.01939260959625244
                ],
                [
                    -0.3106682598590851,
                    0.8284486532211304,
                    -0.4660024046897888,
                    2.3973233699798584
                ],
                [
                    0.0,
                    0.0,
                    0.0,
                    1.0
                ]
            ],
            "keypoints": [
                {
                    "name": "panda_link_0",
                    "location": [
                        2.421438694000244e-08,
                        8.149072527885437e-10,
                        -5.587935447692871e-08
                    ],
                    "projected_location": [ // The projected 2D keypoints locations on the images, only valid when gt data is present.
                        854.9748197663477,
                        532.4341293247742
                    ],
                    "predicted_location": [ // The predicted 2D keypoints locations by kpt-tracking module.
                        854.9748197663477,
                        532.4341293247742
                    ]
                },
                // other keypoints
            ],
            "eef_pos": [
                [
                    2.421438694000244e-08,
                    8.149072527885437e-10,
                    -5.587935447692871e-08
                ]
                ...
            ],
            "joint_positions": [
                1.4787984922025454,
                -0.6394085992873211,
                -1.1422850521276044,
                -1.4485166195536359,
                -0.5849469549952007,
                1.3101860404224674,
                0.2957148441498494,
                0.0
            ],
            "cartesian_position": [
                [
                    2.421438694000244e-08,
                    8.149072527885437e-10,
                    -5.587935447692871e-08
                ],
                ...
            ],
            // other auxiliary keys for debugging purposes.
        }
    ]
}
```

## ❖ ✨Stars/forks/issues/PRs are all welcome!

## ❖ Last but Not Least

If you have any additional questions or have interests in collaboration,please feel free to contact me at [Tutian Tang](tttang@sjtu.edu.cn), [Minghao Liu](lmh209@sjtu.edu.cn), [Wenqiang Xu](vinjohn@sjtu.edu.cn) 😃.
