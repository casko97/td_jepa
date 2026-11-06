#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting, for example: export WANDB_API_KEY='<your-key>'" >&2
    exit 1
fi

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-td-jepa-walker-reprod$(date +%Y%m%d-%H%M%S)}"
NUM_TRAIN_STEPS="${NUM_TRAIN_STEPS:-2000000}"
NUM_SEEDS="${NUM_SEEDS:-3}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-20}"

# Only override architecture values that differ from the Python base and paper Table 4.
PHI_PREDICTOR_HIDDEN_LAYERS="${PHI_PREDICTOR_HIDDEN_LAYERS:-3}"
PSI_PREDICTOR_HIDDEN_LAYERS="${PSI_PREDICTOR_HIDDEN_LAYERS:-3}"
ACTOR_HIDDEN_LAYERS="${ACTOR_HIDDEN_LAYERS:-3}"
ACTOR_HIDDEN_DIM="${ACTOR_HIDDEN_DIM:-256}"

if [[ ! "${NUM_TRAIN_STEPS}" =~ ^[1-9][0-9]*$ ]]; then
    echo "NUM_TRAIN_STEPS must be a positive integer" >&2
    exit 1
fi
if [[ ! "${NUM_SEEDS}" =~ ^[1-5]$ ]]; then
    echo "NUM_SEEDS must be between 1 and 5" >&2
    exit 1
fi
if [[ ! "${NUM_EVAL_EPISODES}" =~ ^[1-9][0-9]*$ ]]; then
    echo "NUM_EVAL_EPISODES must be a positive integer" >&2
    exit 1
fi
for var_name in PHI_PREDICTOR_HIDDEN_LAYERS PSI_PREDICTOR_HIDDEN_LAYERS ACTOR_HIDDEN_LAYERS; do
    if [[ ! "${!var_name}" =~ ^[0-9]+$ ]]; then
        echo "${var_name} must be a non-negative integer" >&2
        exit 1
    fi
done
for var_name in ACTOR_HIDDEN_DIM; do
    if [[ ! "${!var_name}" =~ ^[1-9][0-9]*$ ]]; then
        echo "${var_name} must be a positive integer" >&2
        exit 1
    fi
done

# sweep_walker currently has six hyperparameter combinations per seed.
NUM_TRIALS=$((NUM_SEEDS * 6))
export PROJECT_DIR SWEEP_NAME NUM_TRAIN_STEPS NUM_SEEDS NUM_EVAL_EPISODES
export PHI_PREDICTOR_HIDDEN_LAYERS PSI_PREDICTOR_HIDDEN_LAYERS
export ACTOR_HIDDEN_LAYERS ACTOR_HIDDEN_DIM

echo "Submitting Walker sweep: ${SWEEP_NAME}"
echo "Training steps: ${NUM_TRAIN_STEPS}; evaluation episodes: ${NUM_EVAL_EPISODES}; seeds: ${NUM_SEEDS}; array tasks: ${NUM_TRIALS}"
echo "Architecture overrides: Tphi depth=${PHI_PREDICTOR_HIDDEN_LAYERS}; Tpsi depth=${PSI_PREDICTOR_HIDDEN_LAYERS}; actor=${ACTOR_HIDDEN_LAYERS}x${ACTOR_HIDDEN_DIM}. Other architecture values use the Python launcher defaults."
sbatch --export=ALL --array="0-$((NUM_TRIALS - 1))%4" scripts/train/berzelius/slurm_train_berzelius.sh
