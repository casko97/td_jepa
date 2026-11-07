#!/usr/bin/env bash
#SBATCH --job-name=fb-antmaze-reprod
#SBATCH --account=proj-id
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gpus=1
#SBATCH --constraint=thin
#SBATCH --array=0-199%4
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
DATASET_ROOT="${DATASET_ROOT:-${PROJECT_DIR}/data/ogbench}"
SWEEP_NAME="${SWEEP_NAME:?Submit with submit_fb_antmaze_berzelius.sh}"
ARRAY_TASK_ID="${SLURM_ARRAY_TASK_ID:?Submit this script as a Slurm array}"
NUM_SEEDS="${NUM_SEEDS:-10}"
NUM_DOMAINS="${NUM_DOMAINS:-5}"
JOB_ID="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-local}}"
WORK_DIR="${WORK_DIR:-${PROJECT_DIR}/results/${SWEEP_NAME}}-${JOB_ID}"
LOG_DIR="${PROJECT_DIR}/logs/${SWEEP_NAME}-${JOB_ID}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting." >&2
    exit 1
fi

cd "${PROJECT_DIR}"
mkdir -p "${WORK_DIR}" "${LOG_DIR}"
exec > >(tee -a "${LOG_DIR}/${ARRAY_TASK_ID}.out") 2> >(tee -a "${LOG_DIR}/${ARRAY_TASK_ID}.err" >&2)

module load Miniforge3/24.7.1-2-hpc1-bdist
module load buildenv-gcccuda/12.4.1-gcc13.3.0
set +u
mamba activate td-jepa
set -u

export MUJOCO_GL="${MUJOCO_GL:-egl}"
export PYOPENGL_PLATFORM="${PYOPENGL_PLATFORM:-egl}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-8}"

if [[ ! -d "${DATASET_ROOT}" ]]; then
    echo "OGBench dataset root does not exist: ${DATASET_ROOT}" >&2
    exit 1
fi

echo "Job ID: ${SLURM_JOB_ID:-local}"
echo "Host: $(hostname)"
echo "Dataset: ${DATASET_ROOT}"
echo "FB AntMaze sweep task: ${ARRAY_TASK_ID} / $((NUM_SEEDS * NUM_DOMAINS * 4))"
echo "Seeds: ${NUM_SEEDS}; domains: ${NUM_DOMAINS}"
nvidia-smi

python -m scripts.train.proprio.launch_fb_ogbench \
    --sweep-config sweep_antmaze \
    --use-wandb \
    --wandb-gname "${SWEEP_NAME}" \
    --array-task-id "${ARRAY_TASK_ID}" \
    --num-seeds "${NUM_SEEDS}" \
    --num-domains "${NUM_DOMAINS}" \
    --data-path "${DATASET_ROOT}" \
    --workdir-root "${WORK_DIR}"
