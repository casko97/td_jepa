# DMC Walker reproduction

This submission runs TD-JEPA on state-based Walker data from ExORL/DMC. It corresponds to the Walker row under **DMC (proprioception)** in Table 1 of the [TD-JEPA paper (arxiv version)](https://arxiv.org/abs/2510.00739).

## Parameter comparison

The first column shows the launcher's `BASE_CFG` before sweep values and CLI overrides. The second shows the effective default Berzelius run (`NUM_SEEDS=3`), after the submit and Slurm wrappers pass values to the launcher. Paper values are from Table 4 unless otherwise indicated. Architecture values are configured hidden-layer counts and widths; the paper describes predictor/actor architectures as including two normalized embedding layers in addition to the Table 4 depth.

| Parameter | Default implementation | Walker launch configuration | Paper reported values |
|---|---|---|---|
| Training duration | 3M gradient steps | **2M**, passed by the submit script | **2M** (Table 4, DMC) |
| Successor feature predictors `Tϕ`, `Tψ` | Python base: each has 1 hidden layer, width 1024 | Launch overrides depth to 3; width 1024 comes from Python default | 3 hidden layers, width 1024 (Table 4, DMC) |
| State encoder ϕ | 0 hidden layers, width 256, output dimension dϕ=256 | Uses matching Python defaults; no launch override | 0 hidden layers, width 256, dϕ=256 (Table 4, DMC) |
| Task encoder ψ | 2 hidden layers, width 256, output dimension dψ=50 | Uses matching Python defaults; no launch override | 2 hidden layers, width 256, dψ=50 (Table 4, DMC) |
| Actor π | Python base: 1 hidden layer, width 1024 | Launch overrides to 3 hidden layers, width 256 | 3 hidden layers, width 256 (Table 4, DMC) |
| Batch size | 1024 | 1024 | 1024 (Table 4, DMC) |
| Discount factor γ | 0.98 | 0.98 | 0.98 (Table 4, DMC) |
| EMA coefficient | 0.001 | Encoder and predictor target EMA coefficients: 0.001 each | 0.001 (Table 4, DMC) |
| Task-encoder learning rate `lr_psi` | 1e-4 | Sweep over `{1e-4, 1e-5}` | Sweep over `[1e-4, 1e-5]` (Appendix E.5) |
| Orthonormal regularization coefficients | Base `phi_ortho_coef=0.1`; `psi_ortho_coef=0.1` | `phi_ortho_coef` stays at 0.1; `psi_ortho_coef` sweeps `{0.01, 0.1, 1}` | Table 5 gives TD-JEPA DMC λ values `[0.01, 0.1, 1]`; Algorithm 1 uses one λ for both encoder losses |
| Evaluation episodes | Launcher default: 20 for Walker | 20 | 20 for DMC (Appendix E.7) |
| Seeds | Sweep defines `[3917, 3502, 8948, 9460, 4729]` | First 3 by default; `NUM_SEEDS` selects a prefix | Paper reports 10 seeds (Appendix E.7); the paper does not report seed IDs |

The paper's Table 4 also reports `pgoal=0.5`. The equivalent code setting is `train_goal_ratio=0.5`, inherited from `TDJEPAAgentTrainConfig`; it matches without an explicit launcher override.

## Remaining unclear parameters

- **Regularization mapping:** Table 5 gives TD-JEPA DMC λ candidates `{0.01, 0.1, 1}`, and Algorithm 1 applies one λ to both encoder regularizers. This implementation has separate `phi_ortho_coef` and `psi_ortho_coef`, but the existing Walker sweep changes only ψ while holding ϕ at `0.1`. It therefore runs `(ϕ, ψ) = (0.1,0.01), (0.1,0.1), (0.1,1)` for each learning rate. Only `(0.1,0.1)` is a shared-λ setting; whether Table 5's λ should map identically to both code fields is not explicit in the implementation, so these results should be reported as the repo's sweep rather than an exact reproduction of that regularization grid.
- **Layer counting:** the paper does not clarify whether its reported layer counts include the two embedding layers. The launch overrides set the configured hidden-layer counts to 3 as reported.
- **Seeds:** Appendix E.7 reports ten seeds and does not give their IDs. The local sweep defines five seed IDs, so this launcher cannot reproduce the paper's reported seed count; `NUM_SEEDS=5` runs all available local IDs.
- **`F`:** it is general successor-feature notation, not a separate TD-JEPA network; no `F` module is added.

## Paper-aligned launch overrides

Four architecture values are explicitly set by the submit/Slurm path: `PHI_PREDICTOR_HIDDEN_LAYERS=3`, `PSI_PREDICTOR_HIDDEN_LAYERS=3`, `ACTOR_HIDDEN_LAYERS=3`, and `ACTOR_HIDDEN_DIM=256`. Predictor widths and both encoders come from Python defaults. The path uses the paper's 2M steps, six-config sweep, and 20 Walker evaluation episodes. Its default three seeds are a reduced-seed run; the local sweep contains only five IDs while the paper reports ten, so no supported `NUM_SEEDS` value can match the paper count.

## Run

From the repository root, after configuring the Berzelius allocation and environment:

```bash
bash scripts/train/berzelius/walker_reproduction/submit_td_jepa_berzelius.sh
```

Optional submit-script overrides include `NUM_SEEDS`, `NUM_TRAIN_STEPS`, `NUM_EVAL_EPISODES`, `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`.
