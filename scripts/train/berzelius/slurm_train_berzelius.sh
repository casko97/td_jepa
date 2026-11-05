#!/usr/bin/env bash
#SBATCH --job-name=td-jepa
#SBATCH --account=proj-id
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gpus=1
#SBATCH --constraint=thin
#SBATCH --array=0-29%4
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
DATASET_ROOT="${DATASET_ROOT:-${PROJECT_DIR}/data/exorl_processed}"
SWEEP_NAME="${SWEEP_NAME:?Submit with scripts/train/berzelius/submit_td_jepa_berzelius.sh}"
ARRAY_TASK_ID="${SLURM_ARRAY_TASK_ID:?Submit this script as a Slurm array}"
NUM_TRAIN_STEPS="${NUM_TRAIN_STEPS:-2000000}"
NUM_SEEDS="${NUM_SEEDS:-3}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-20}"
WORK_DIR="${WORK_DIR:-${PROJECT_DIR}/results/${SWEEP_NAME}}"

cd "${PROJECT_DIR}"
mkdir -p "${WORK_DIR}"

module load Miniforge3/24.7.1-2-hpc1-bdist
mamba activate td-jepa

export DATASET_ROOT
export MUJOCO_GL="${MUJOCO_GL:-egl}"
export PYOPENGL_PLATFORM="${PYOPENGL_PLATFORM:-egl}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-8}"

if [[ ! -d "${DATASET_ROOT}/walker/rnd/buffer" ]]; then
    echo "Expected state-based ExORL data at ${DATASET_ROOT}/walker/rnd/buffer" >&2
    exit 1
fi

echo "Job ID: ${SLURM_JOB_ID:-local}"
echo "Host: $(hostname)"
echo "Dataset: ${DATASET_ROOT}"
echo "Walker sweep task: ${ARRAY_TASK_ID} / $((NUM_SEEDS * 6))"
echo "Training steps: ${NUM_TRAIN_STEPS}"
echo "Evaluation episodes: ${NUM_EVAL_EPISODES}"
nvidia-smi

python -m scripts.train.proprio.launch_td_jepa_dmc \
    --sweep-config sweep_walker \
    --array-task-id "${ARRAY_TASK_ID}" \
    --num-train-steps "${NUM_TRAIN_STEPS}" \
    --num-seeds "${NUM_SEEDS}" \
    --num-eval-episodes "${NUM_EVAL_EPISODES}" \
    --data-path "${DATASET_ROOT}" \
    --workdir-root "${WORK_DIR}"
