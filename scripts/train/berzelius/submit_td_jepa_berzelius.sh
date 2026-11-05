#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-td-jepa-walker-$(date +%Y%m%d-%H%M%S)}"
export PROJECT_DIR SWEEP_NAME

echo "Submitting Walker sweep: ${SWEEP_NAME}"
sbatch --export=ALL scripts/train/berzelius/slurm_train_berzelius.sh
