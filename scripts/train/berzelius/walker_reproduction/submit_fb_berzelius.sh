#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting." >&2
    exit 1
fi

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-fb-walker-reprod-$(date +%Y%m%d-%H%M%S)}"
NUM_TRAIN_STEPS="${NUM_TRAIN_STEPS:-2000000}"
NUM_SEEDS="${NUM_SEEDS:-3}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-20}"

if [[ ! "${NUM_TRAIN_STEPS}" =~ ^[1-9][0-9]*$ ]]; then
    echo "NUM_TRAIN_STEPS must be a positive integer" >&2
    exit 1
fi
if [[ ! "${NUM_SEEDS}" =~ ^[1-5]$ ]]; then
    echo "NUM_SEEDS must be between 1 and 5 (the Walker sweep defines five IDs)" >&2
    exit 1
fi
if [[ ! "${NUM_EVAL_EPISODES}" =~ ^[1-9][0-9]*$ ]]; then
    echo "NUM_EVAL_EPISODES must be a positive integer" >&2
    exit 1
fi

NUM_TRIALS=$((NUM_SEEDS * 6))
export PROJECT_DIR SWEEP_NAME NUM_TRAIN_STEPS NUM_SEEDS NUM_EVAL_EPISODES

echo "Submitting state-based FB Walker sweep: ${SWEEP_NAME}"
echo "Steps: ${NUM_TRAIN_STEPS}; evaluation episodes: ${NUM_EVAL_EPISODES}; seeds: ${NUM_SEEDS}; array tasks: ${NUM_TRIALS}"
sbatch --job-name="${SWEEP_NAME}" --export=ALL --array="0-$((NUM_TRIALS - 1))%4" scripts/train/berzelius/walker_reproduction/slurm_train_fb_walker_berzelius.sh
