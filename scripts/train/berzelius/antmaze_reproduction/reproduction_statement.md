# OGBench AntMaze reproduction

This submission runs TD-JEPA on state-based OGBench AntMaze data. It corresponds to an AntMaze row under **OGBench (proprioception)** in Table 1 of the [TD-JEPA paper](https://arxiv.org/abs/2510.00739). The default domain is `antmaze-medium-navigate-v0`.

## Parameter comparison

The first column is the Python launcher's `BASE_CFG` before sweep and CLI overrides; the second is the effective default Berzelius run (`NUM_DOMAINS=1`, `NUM_SEEDS=5`). Paper values refer to Table 4 unless noted. Architecture values are configured hidden-layer counts and widths; the paper describes predictor/actor architectures as including two normalized embedding layers in addition to the Table 4 depth.

| Parameter | Python base | AntMaze launch configuration | Paper reported values |
|---|---|---|---|
| Training duration | 1M gradient steps | 1M; no override | 1M (Table 4, OGBench) |
| Successor feature predictors `Tϕ`, `Tψ` | Each: 2 hidden layers, width 512 | Each: 4×512 (`PHI_PREDICTOR_HIDDEN_LAYERS=4`, `PSI_PREDICTOR_HIDDEN_LAYERS=4`) | 4 hidden layers, width 512 (Table 4, OGBench) |
| State encoder ϕ | 4 hidden layers, width 512, dϕ=50 | Depth/width inherited; dimension set to dϕ=256 (`PHI_DIM=256`) | 4 hidden layers, width 512, dϕ=256 (Table 4, OGBench) |
| Task encoder ψ | 4 hidden layers, width 512, dψ=50 | 4×512, dψ=50; no override | 4 hidden layers, width 512, dψ=50 (Table 4, OGBench) |
| Actor π | Noise-conditioned actor; 2 hidden layers, width 512 | 4×512 (`ACTOR_HIDDEN_LAYERS=4`); raw-state input matches Appendix E.6 | 4 hidden layers, width 512 (Table 4, OGBench) |
| Flow vector field | Code default: 1 hidden layer, width 1024 | 4×512 (`ACTOR_VF_HIDDEN_LAYERS=4`, `ACTOR_VF_HIDDEN_DIM=512`) | Appendix E.6 says use Table 4 actor hyperparameters: 4 hidden layers, width 512 |
| Batch size | 256 | 256 | 256 (Table 4, OGBench) |
| Discount factor γ | 0.99 | 0.99 | 0.99 (Table 4, OGBench) |
| Encoder/predictor EMA coefficients | 0.005 each | 0.005 each | 0.005 (Table 4, OGBench) |
| Task-encoder learning rate `lr_psi` | 1e-4 | Sweep `{1e-4, 1e-5}` | Sweep `[1e-4, 1e-5]` (Appendix E.5) |
| Orthonormal regularization coefficients | Base `phi_ortho_coef=1`; `psi_ortho_coef=1` | `phi_ortho_coef` stays at 1; `psi_ortho_coef` sweeps `{0.1, 1}` | Table 5 gives TD-JEPA OGBench navigation λ values `[0.1, 1]`; Algorithm 1 uses one λ for both encoder losses |
| Behavior-cloning coefficient | `bc_coeff=0` base | Sweep fixes `bc_coeff=0.3` | α=0.3 for navigation (Appendix E.6) |
| Evaluation episodes | 10 | 10 | 10 (Appendix E.7) |
| Seeds | Sweep defines ten IDs | First five by default | Paper's reported evaluation uses 10 seeds; seed IDs are not reported |

The paper also uses `pgoal=0.5` (Table 4). The equivalent code setting is `train_goal_ratio=0.5`, inherited from `TDJEPAAgentTrainConfig`; it matches the paper default without an explicit launcher override.

## Paper-aligned launch overrides

The submit/Slurm path passes six architecture overrides: predictor depths, actor depth, actor flow-field depth and width, and `PHI_DIM`. The flow field is configured to 4×512 as required by Appendix E.6. Predictor/actor widths, encoders, training duration, batch size, discount, EMA, BC coefficient, and evaluation count already match. The helper defaults to five seeds; set `NUM_SEEDS=10` for the paper's seed count. The original sweep remains four configurations per seed/domain: two `lr_psi` values crossed with two `psi_ortho_coef` values; `phi_ortho_coef` remains at 1.

## Remaining unclear

**Regularization mapping:** Table 5 gives TD-JEPA OGBench navigation λ candidates `{0.1, 1}`, and Algorithm 1 applies one λ to both encoder regularizers. This implementation has separate `phi_ortho_coef` and `psi_ortho_coef`, but the existing AntMaze sweep changes only ψ while holding ϕ at `1`. It therefore runs `(ϕ, ψ) = (1,0.1)` and `(1,1)` for each learning rate. Only `(1,1)` is a shared-λ setting; whether Table 5's λ should map identically to both code fields is not explicit in the implementation, so these results should be reported as the repo's sweep rather than an exact reproduction of that regularization grid. Appendix E.7 reports ten seeds but not their IDs.

The default helper selects one domain, `antmaze-medium-navigate-v0`, and five seeds, submitting 20 trials (5 × 1 × 4). `NUM_DOMAINS` selects a prefix of the launcher list: medium-navigate, large-navigate, medium-stitch, large-stitch, medium-explore. State-based OGBench data defaults to `data/ogbench`.

## Run

From the repository root, after configuring the Berzelius allocation and environment:

```bash
bash scripts/train/berzelius/antmaze_reproduction/submit_td_jepa_antmaze_berzelius.sh
```

Useful overrides include `NUM_SEEDS`, `NUM_DOMAINS`, `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`. Architecture launch values can be changed with `PHI_PREDICTOR_HIDDEN_LAYERS`, `PSI_PREDICTOR_HIDDEN_LAYERS`, `ACTOR_HIDDEN_LAYERS`, `ACTOR_VF_HIDDEN_LAYERS`, `ACTOR_VF_HIDDEN_DIM`, and `PHI_DIM`.
