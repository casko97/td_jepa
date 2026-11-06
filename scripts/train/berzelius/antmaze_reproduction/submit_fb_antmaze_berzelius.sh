#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting." >&2
    exit 1
fi

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-fb-antmaze-reprod-$(date +%Y%m%d-%H%M%S)}"
NUM_SEEDS="${NUM_SEEDS:-5}"
NUM_DOMAINS="${NUM_DOMAINS:-1}"

if [[ ! "${NUM_SEEDS}" =~ ^([1-9]|10)$ ]]; then
    echo "NUM_SEEDS must be between 1 and 10" >&2
    exit 1
fi
if [[ ! "${NUM_DOMAINS}" =~ ^[1-5]$ ]]; then
    echo "NUM_DOMAINS must be between 1 and 5" >&2
    exit 1
fi

# FB sweep_antmaze has two learning rates and two orthonormal coefficients.
NUM_TRIALS=$((NUM_SEEDS * NUM_DOMAINS * 4))
export PROJECT_DIR SWEEP_NAME NUM_SEEDS NUM_DOMAINS

echo "Submitting state-based FB AntMaze sweep: ${SWEEP_NAME}"
echo "Seeds: ${NUM_SEEDS}; domains: ${NUM_DOMAINS}; array tasks: ${NUM_TRIALS}"
sbatch --job-name="${SWEEP_NAME}" --export=ALL --array="0-$((NUM_TRIALS - 1))%4" scripts/train/berzelius/antmaze_reproduction/slurm_train_fb_antmaze_berzelius.sh
