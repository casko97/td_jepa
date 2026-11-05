#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-td-jepa-antmaze-$(date +%Y%m%d-%H%M%S)}"
NUM_SEEDS="${NUM_SEEDS:-10}"
NUM_DOMAINS="${NUM_DOMAINS:-5}"

if [[ ! "${NUM_SEEDS}" =~ ^([1-9]|10)$ ]]; then
    echo "NUM_SEEDS must be between 1 and 10" >&2
    exit 1
fi
if [[ ! "${NUM_DOMAINS}" =~ ^[1-5]$ ]]; then
    echo "NUM_DOMAINS must be between 1 and 5" >&2
    exit 1
fi

# sweep_antmaze currently has four hyperparameter combinations per seed/domain.
NUM_TRIALS=$((NUM_SEEDS * NUM_DOMAINS * 4))
export PROJECT_DIR SWEEP_NAME NUM_SEEDS NUM_DOMAINS

echo "Submitting state-based antmaze sweep: ${SWEEP_NAME}"
echo "Seeds: ${NUM_SEEDS}; domains: ${NUM_DOMAINS}; array tasks: ${NUM_TRIALS}"
sbatch --export=ALL --array="0-$((NUM_TRIALS - 1))%4" scripts/train/berzelius/slurm_train_antmaze_berzelius.sh
