#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/proj/rpl-soro/users/x_carsk/td_jepa}"
cd "${PROJECT_DIR}"

if [[ -z "${WANDB_API_KEY:-}" ]]; then
    echo "WANDB_API_KEY is missing. Export it before submitting, for example: export WANDB_API_KEY='<your-key>'" >&2
    exit 1
fi

mkdir -p logs
SWEEP_NAME="${SWEEP_NAME:-td-jepa-antmaze-reprod-$(date +%Y%m%d-%H%M%S)}"
NUM_SEEDS="${NUM_SEEDS:-5}"
NUM_DOMAINS="${NUM_DOMAINS:-1}"

# Paper Table 4 OGBench values that differ from the Python base architecture.
PHI_PREDICTOR_HIDDEN_LAYERS="${PHI_PREDICTOR_HIDDEN_LAYERS:-4}"
PSI_PREDICTOR_HIDDEN_LAYERS="${PSI_PREDICTOR_HIDDEN_LAYERS:-4}"
ACTOR_HIDDEN_LAYERS="${ACTOR_HIDDEN_LAYERS:-4}"
PHI_DIM="${PHI_DIM:-256}"

if [[ ! "${NUM_SEEDS}" =~ ^([1-9]|10)$ ]]; then
    echo "NUM_SEEDS must be between 1 and 10" >&2
    exit 1
fi
if [[ ! "${NUM_DOMAINS}" =~ ^[1-5]$ ]]; then
    echo "NUM_DOMAINS must be between 1 and 5" >&2
    exit 1
fi
for var_name in PHI_PREDICTOR_HIDDEN_LAYERS PSI_PREDICTOR_HIDDEN_LAYERS ACTOR_HIDDEN_LAYERS PHI_DIM; do
    if [[ ! "${!var_name}" =~ ^[1-9][0-9]*$ ]]; then
        echo "${var_name} must be a positive integer" >&2
        exit 1
    fi
done

# sweep_antmaze currently has four hyperparameter combinations per seed/domain.
NUM_TRIALS=$((NUM_SEEDS * NUM_DOMAINS * 4))
export PROJECT_DIR SWEEP_NAME NUM_SEEDS NUM_DOMAINS
export PHI_PREDICTOR_HIDDEN_LAYERS PSI_PREDICTOR_HIDDEN_LAYERS ACTOR_HIDDEN_LAYERS PHI_DIM

echo "Submitting state-based antmaze sweep: ${SWEEP_NAME}"
echo "Seeds: ${NUM_SEEDS}; domains: ${NUM_DOMAINS}; array tasks: ${NUM_TRIALS}"
echo "Architecture overrides: Tphi/Tpsi depth=${PHI_PREDICTOR_HIDDEN_LAYERS}/${PSI_PREDICTOR_HIDDEN_LAYERS}; actor depth=${ACTOR_HIDDEN_LAYERS}; phi_dim=${PHI_DIM}"
sbatch --job-name="${SWEEP_NAME}" --export=ALL --array="0-$((NUM_TRIALS - 1))%4" scripts/train/berzelius/slurm_train_antmaze_berzelius.sh
