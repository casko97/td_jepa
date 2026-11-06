# OGBench AntMaze reproduction

This submission runs TD-JEPA on state-based OGBench AntMaze data. It corresponds to an AntMaze row under **OGBench (proprioception)** in Table 1 of the [TD-JEPA paper](https://arxiv.org/abs/2510.00739). The default domain is `antmaze-medium-navigate-v0`.

## Parameter comparison

The first column is the Python launcher base configuration; the second is the effective AntMaze run through the Berzelius helper. Paper values refer to Table 4 unless noted.

| Parameter | Python base | AntMaze launch configuration | Paper reported values |
|---|---|---|---|
| Training duration | 1M gradient steps | 1M; no override | 1M (Table 4, OGBench) |
| Successor feature predictors `Tϕ`, `Tψ` | Each: 2 hidden layers, width 512 | Each: 4×512 (`PHI_PREDICTOR_HIDDEN_LAYERS=4`, `PSI_PREDICTOR_HIDDEN_LAYERS=4`) | 4 hidden layers, width 512 (Table 4, OGBench) |
| State encoder ϕ | 4 hidden layers, width 512, dϕ=50 | Depth/width inherited; dimension set to dϕ=256 (`PHI_DIM=256`) | 4 hidden layers, width 512, dϕ=256 (Table 4, OGBench) |
| Task encoder ψ | 4 hidden layers, width 512, dψ=50 | 4×512, dψ=50; no override | 4 hidden layers, width 512, dψ=50 (Table 4, OGBench) |
| Actor π | Noise-conditioned actor; 2 hidden layers, width 512 | 4×512 (`ACTOR_HIDDEN_LAYERS=4`); raw-state input matches Appendix E.6 | 4 hidden layers, width 512 (Table 4, OGBench) |
| Flow vector field | 4 hidden layers, width 512 | 4×512; no override | Appendix E.6 specifies the actor architecture from Table 4: 4 hidden layers, width 512 |
| Batch size | 256 | 256 | 256 (Table 4, OGBench) |
| Discount factor γ | 0.99 | 0.99 | 0.99 (Table 4, OGBench) |
| Encoder/predictor EMA coefficients | 0.005 each | 0.005 each | 0.005 (Table 4, OGBench) |
| Task-encoder learning rate `lr_psi` | 1e-4 | Sweep `{1e-4, 1e-5}` | Sweep `[1e-4, 1e-5]` (Appendix E.5) |
| Orthonormal regularization λ | `phi_ortho_coef=1`; `psi_ortho_coef=1` | Sweep ψ over `{0.1, 1}`; keep ϕ at 1 | TD-JEPA OGBench navigation range `[0.1, 1]` (Table 5); paper reports one λ |
| Behavior-cloning coefficient | `bc_coeff=0` base | Sweep fixes `bc_coeff=0.3` | α=0.3 for navigation (Appendix E.6) |
| Evaluation episodes | 10 | 10 | 10 (Appendix E.7) |
| Seeds | Sweep defines ten IDs | First five by default | 10 (Appendix E.7); IDs not reported |

## Paper-aligned launch overrides

The submit/Slurm path passes four overrides to the Python launcher: `PHI_PREDICTOR_HIDDEN_LAYERS=4`, `PSI_PREDICTOR_HIDDEN_LAYERS=4`, `ACTOR_HIDDEN_LAYERS=4`, and `PHI_DIM=256`. Predictor and actor widths (512), state encoder depth/width, task encoder, training duration, batch size, discount, EMA, sweep, and behavior-cloning coefficient already match. Python base defaults remain unchanged. The helper defaults to five seeds; set `NUM_SEEDS=10` to match the paper's seed count.

## Remaining unclear

Table 5 reports one regularization coefficient λ, while this implementation has separate ϕ and ψ coefficients. The current sweep varies ψ over `{0.1, 1}` and holds ϕ at 1; the paper does not specify whether λ should be applied identically to both losses. Appendix E.7 reports ten seeds but not their IDs.

The default helper selects one domain, `antmaze-medium-navigate-v0`, and five seeds, submitting 20 trials (5 × 1 × 4). `NUM_DOMAINS` selects a prefix of the launcher list: medium-navigate, large-navigate, medium-stitch, large-stitch, medium-explore. State-based OGBench data defaults to `data/ogbench`.

## Run

From the repository root, after configuring the Berzelius allocation and environment:

```bash
bash scripts/train/berzelius/antmazereproduction/submit_td_jepa_antmaze_berzelius.sh
```

Useful overrides include `NUM_SEEDS`, `NUM_DOMAINS`, `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`. Architecture launch values can be changed with `PHI_PREDICTOR_HIDDEN_LAYERS`, `PSI_PREDICTOR_HIDDEN_LAYERS`, `ACTOR_HIDDEN_LAYERS`, and `PHI_DIM`; the defaults are the paper-aligned values above.
