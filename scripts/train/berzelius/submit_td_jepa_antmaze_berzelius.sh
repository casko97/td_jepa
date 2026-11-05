#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-td-jepa-antmaze-$(date +%Y%m%d-%H%M%S)}"
export PROJECT_DIR SWEEP_NAME

echo "Submitting state-based antmaze sweep: ${SWEEP_NAME}"
sbatch --export=ALL scripts/train/berzelius/slurm_train_antmaze_berzelius.sh
