#!/usr/bin/env bash
#SBATCH --job-name=td-jepa-dmc-reprod
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
SWEEP_NAME="${SWEEP_NAME:?Submit with scripts/train/berzelius/walker_reproduction/submit_td_jepa_berzelius.sh}"
ARRAY_TASK_ID="${SLURM_ARRAY_TASK_ID:?Submit this script as a Slurm array}"
NUM_TRAIN_STEPS="${NUM_TRAIN_STEPS:-2000000}"
NUM_SEEDS="${NUM_SEEDS:-5}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-20}"
PHI_PREDICTOR_HIDDEN_LAYERS="${PHI_PREDICTOR_HIDDEN_LAYERS:-3}"
PSI_PREDICTOR_HIDDEN_LAYERS="${PSI_PREDICTOR_HIDDEN_LAYERS:-3}"
ACTOR_HIDDEN_LAYERS="${ACTOR_HIDDEN_LAYERS:-3}"
ACTOR_HIDDEN_DIM="${ACTOR_HIDDEN_DIM:-256}"
JOB_ID="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-local}}"
WORK_DIR="${WORK_DIR:-${PROJECT_DIR}/results/${SWEEP_NAME}}-${JOB_ID}"
LOG_DIR="${PROJECT_DIR}/logs/${SWEEP_NAME}-${JOB_ID}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting, for example: export WANDB_API_KEY='<your-key>'" >&2
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
    --use-wandb \
    --wandb-gname "${SWEEP_NAME}" \
    --array-task-id "${ARRAY_TASK_ID}" \
    --num-train-steps "${NUM_TRAIN_STEPS}" \
    --num-seeds "${NUM_SEEDS}" \
    --num-eval-episodes "${NUM_EVAL_EPISODES}" \
    --phi-predictor-hidden-layers "${PHI_PREDICTOR_HIDDEN_LAYERS}" \
    --psi-predictor-hidden-layers "${PSI_PREDICTOR_HIDDEN_LAYERS}" \
    --actor-hidden-layers "${ACTOR_HIDDEN_LAYERS}" \
    --actor-hidden-dim "${ACTOR_HIDDEN_DIM}" \
    --data-path "${DATASET_ROOT}" \
    --workdir-root "${WORK_DIR}"
