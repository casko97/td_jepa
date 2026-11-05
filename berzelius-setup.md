# Berzelius Setup Instructions
 
Berzelius lathund:
* Monitor job status: `squeue -u $USER`
* Submit job: `sbatch myjob.sh`
* Interactive session `interactive -A proj-id -t 1:00:00 --gpus=1 --constraint thin`
* Launch bash: `srun --pty bash`
* Get into the node from the side: `srun --jobid=id --pty bash`

## First time environment creation

1. Load mamba: `module load Miniforge3/24.7.1-2-hpc1-bdist`
2. Crete env: `mamba create -n td-jepa python=3.11`
3. Activate env: `mamba activate td-jepa`
4. Setup torch and CUDA: `CONDA_OVERRIDE_CUDA=13.0 mamba install 'pytorch==2.10.0=cuda*'`
5. Install req's: `python -m pip install -e .` 
6. Set variables (permanently, after validation)`conda env config vars set MUJOCO_GL=egl PYOPENGL_PLATFORM=egl`
7. Verify dependencies (on the gpu node) by running `python scripts/smoke/test_berzelius_setup.py`

## Data download

* OGBench: 
    ```
    python -m scripts.data_processing.ogbench.extract_all /
    --output_folder /proj/rpl-soro/users/x_carsk/td_jepa/data/ogbench / 
    --data-type state
    ```
* ExORL: 
    ```
    python -m scripts.data_processing.exorl.download --output_folder /proj/rpl-soro/users/x_carsk/td_jepa/data/exorl_raw 
    ```

* Pre-processing:  (defaults to state; use `--data-type visual` to render and save RGB frames)
    
    ```
    python -m scripts.data_processing.exorl.update_all \
    --input_folder /proj/rpl-soro/users/x_carsk/td_jepa/data/exorl_raw \
    --output_folder /proj/rpl-soro/users/x_carsk/td_jepa/data/exorl_processed \
    --num_workers 8
    ```


## Training smoke-run 

### OgBench

After downloading and pre-processing data. 

`export DATASET_ROOT=/proj/rpl-soro/users/x_carsk/td_jepa/data/ogbench`

The smoke run uses the state-based `cube-single-play-v0` OGBench dataset. Check that extraction created episode files: `find "$DATASET_ROOT/cube-single-play-v0/buffer" -maxdepth 1 -name '*.npz' | head`

The expected layout is: `$DATASET_ROOT/cube-single-play-v0/buffer/*.npz`

`export SMOKE_WORKDIR="$PWD/results/smoke-td-jepa"`

Run six small GPU updates: `python scripts/smoke/berzelius_smoke_train_ogbench.py`

Results will be in `results/smoke-td-jepa/`

### EcORL

For ExORL, point `DATASET_ROOT` at the processed dataset directory instead:

`export DATASET_ROOT=/proj/rpl-soro/users/x_carsk/td_jepa/data/exorl_processed`

The smoke run uses the state-based `walker/rnd` dataset. Check that preprocessing created episode files: `find "$DATASET_ROOT/walker/rnd/buffer" -maxdepth 1 -name '*.npz' | head`

The expected layout is: `$DATASET_ROOT/walker/rnd/buffer/*.npz`

Set a separate work directory and run the ExORL smoke trainer:

`export SMOKE_WORKDIR="$PWD/results/smoke-td-jepa-exorl"`

`python scripts/smoke/berzelius_smoke_train_exorl.py`

Results will be in `results/smoke-td-jepa-exorl/`

## Slurm setup

1. Load module: `module load Miniforge3/24.7.1-2-hpc1-bdist`
2. Activate environment: `mamba activate td-jepa`
