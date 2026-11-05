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

## Launch a Slurm training run

Before submitting, replace `proj-id` in `#SBATCH --account=proj-id` in both Slurm files under `scripts/train/berzelius/` with your Berzelius allocation account. The submission helpers create the `logs/` directory and submit the corresponding Slurm array. Each submission gets a timestamped sweep name by default. That name is also used as the Slurm job name and in log filenames under `logs/`, followed by the Slurm array job ID and task index. Per-trial configs, training logs, evaluation CSVs, and checkpoints go to `results/<sweep-name>/<trial-index>/`.

Run them from the project root:

```bash
bash scripts/train/berzelius/submit_td_jepa_berzelius.sh
bash scripts/train/berzelius/submit_td_jepa_antmaze_berzelius.sh
```



### Walker, state-based ExORL

This uses the Python `sweep_walker` hyperparameter combinations and processed data from `data/exorl_processed`. Slurm overrides the Python launcher's 3,000,000-step default with 2,000,000 steps. Evaluation remains at 20 episodes, matching the Walker setting in Python. Slurm defaults to 3 of the 5 seeds; set `NUM_SEEDS=5` to run all five paper seeds.

There are six hyperparameter combinations per seed: 18 tasks by default or 30 with all five seeds. Each task requests one GPU and 8 CPUs; up to four tasks run concurrently.

Set any of these environment variables before invoking the helper to override its defaults:

| Variable | Default | Meaning |
| --- | --- | --- |
| `NUM_TRAIN_STEPS` | `2000000` | Positive number of training steps per run |
| `NUM_SEEDS` | `3` | Number of the first seeds from `sweep_walker` to run; range 1–5 |
| `NUM_EVAL_EPISODES` | `20` | Positive number of episodes per evaluation |
| `DATASET_ROOT` | `$PROJECT_DIR/data/exorl_processed` | Processed ExORL root; expected layout includes `walker/rnd/buffer/*.npz` |
| `PROJECT_DIR` | `/proj/rpl-soro/users/x_carsk/td_jepa` | Project checkout path |
| `SWEEP_NAME` | Timestamped `td-jepa-walker-*` | Results directory name |

For example, run one million steps using three seeds and ten evaluation episodes:

```bash
NUM_TRAIN_STEPS=1000000 NUM_SEEDS=3 NUM_EVAL_EPISODES=10 \
  bash scripts/train/berzelius/submit_td_jepa_berzelius.sh
```

The array task count is `NUM_SEEDS × 6`, because the Python sweep defines six learning-rate/orthogonality combinations per seed.

### Antmaze, state-based OGBench

This uses the Python `sweep_antmaze` configuration and the extracted state dataset at `data/ogbench` by default. Slurm defaults to the first 5 of the Python sweep's 10 seeds and all 5 domains, yielding 100 tasks (four hyperparameter combinations per seed/domain pair). Set `NUM_SEEDS=10` to run all seeds (200 tasks). Training steps and hyperparameters remain as defined by `BASE_CFG` and `sweep_antmaze`; Slurm only limits the seed/domain counts. Up to four array tasks run concurrently.

| Variable | Default | Meaning |
| --- | --- | --- |
| `NUM_SEEDS` | `5` | Number of the first seeds from `sweep_antmaze` to run; range 1–10 |
| `NUM_DOMAINS` | `5` | Number of the first antmaze domains from `sweep_antmaze` to run; range 1–5 |
| `DATASET_ROOT` | `$PROJECT_DIR/data/ogbench` | OGBench dataset root; each selected domain must have a `buffer/` directory |
| `PROJECT_DIR` | `/proj/rpl-soro/users/x_carsk/td_jepa` | Project checkout path |
| `SWEEP_NAME` | Timestamped `td-jepa-antmaze-*` | Results directory name |

For example, run the first three seeds on the first two antmaze domains:

```bash
NUM_SEEDS=3 NUM_DOMAINS=2 \
  bash scripts/train/berzelius/submit_td_jepa_antmaze_berzelius.sh
```

That submits `NUM_SEEDS × NUM_DOMAINS × 4` tasks.

Check submitted jobs with `squeue -u "$USER"`. The Slurm scripts request 24 hours per task and write task-specific logs under `logs/`.
