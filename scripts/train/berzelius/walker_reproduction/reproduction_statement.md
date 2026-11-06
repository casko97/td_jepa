# DMC Walker reproduction

This submission runs TD-JEPA on state-based Walker data from ExORL/DMC. It corresponds to the Walker row under **DMC (proprioception)** in Table 1 of the [TD-JEPA paper (arxiv version)](https://arxiv.org/abs/2510.00739).

## Parameter comparison

The first column shows the launcher's base configuration before sweep values and submit-script overrides. The second shows the effective Walker run configuration after those changes. Paper values are from Table 4 unless otherwise indicated.

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
| Orthonormal regularization coefficient λ | `phi_ortho_coef=0.1`; `psi_ortho_coef=0.1` | Sweep `psi_ortho_coef` over `{0.01, 0.1, 1}`; keep `phi_ortho_coef=0.1` | TD-JEPA DMC range `[0.01, 0.1, 1]` (Table 5). Paper reports one λ; local code splits it across ϕ and ψ coefficients. |
| Evaluation episodes | Launcher default: 20 for Walker | 20 | 20 for DMC (Appendix E.7) |
| Seeds | Sweep defines `[3917, 3502, 8948, 9460, 4729]` | First 3 by default; `NUM_SEEDS` selects a prefix | 5 for DMC (Appendix E.7); the paper does not report seed IDs |

## Remaining unclear parameters

- **Regularization:** Table 5 reports one λ, but this code has separate ϕ and ψ coefficients. The sweep varies ψ over `{0.01, 0.1, 1}` and holds ϕ at `0.1`; the paper does not specify how λ maps to both losses.
- **Layer counting:** the paper does not clarify whether its reported layer counts include the two embedding layers. The launch overrides set the configured hidden-layer counts to 3 as reported.
- **Seeds:** the paper reports five DMC seeds but not their IDs. The submit default runs three; use `NUM_SEEDS=5` to match the paper's seed count.
- **`F`:** it is general successor-feature notation, not a separate TD-JEPA network; no `F` module is added.

## Paper-aligned launch overrides

Only four values need explicit launch overrides: `PHI_PREDICTOR_HIDDEN_LAYERS=3`, `PSI_PREDICTOR_HIDDEN_LAYERS=3`, `ACTOR_HIDDEN_LAYERS=3`, and `ACTOR_HIDDEN_DIM=256`. Predictor widths and both encoders already match Table 4 in Python defaults. The submit script otherwise uses the paper's 2M steps, six-config sweep, and 20 evaluation episodes. Its default three seeds are intentional; set `NUM_SEEDS=5` for the paper's seed count.

## Run

From the repository root, after configuring the Berzelius allocation and environment:

```bash
bash scripts/train/berzelius/walker_reproduction/submit_td_jepa_berzelius.sh
```

Optional submit-script overrides include `NUM_SEEDS`, `NUM_TRAIN_STEPS`, `NUM_EVAL_EPISODES`, `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`.
