# OGBench AntMaze FB reproduction

This setup trains the state-based **FB** baseline on the five OGBench AntMaze domains represented in Table 1 of the [TD-JEPA paper](https://arxiv.org/abs/2510.00739): medium/large navigate, medium/large stitch, and medium explore. It uses the repository's `FBFlowBCAgent`, the OGBench FlowQ-style behavior-cloning correction, and the existing `sweep_antmaze` configuration unchanged, dispatched through a Berzelius Slurm array.

## Configuration

| Parameter | Effective launch value | Paper protocol |
|---|---:|---:|
| Training updates | 1M | 1M for OGBench (Table 4) |
| Batch size | 256 | 256 (Table 4) |
| Discount γ | 0.99 | 0.99 (Table 4) |
| FB latent dimension | 50 | Repository FB launcher default |
| Task encoder learning rate `lr_b` | `{1e-4, 1e-5}` | Sweep `{1e-4, 1e-5}` (Appendix E.5) |
| Orthonormal coefficient | `{100, 1000}` | FB OGBench navigation candidates (Table 5) |
| Behavior-cloning coefficient | `0.3` | `0.3` for navigation (Appendix E.6) |
| Evaluation | 10 episodes per task | 10 OGBench episodes (Appendix E.7) |
| Seeds | 10 | 10 (Appendix E.7) |

Each domain has four hyperparameter combinations (two learning rates × two regularization values). The default full sweep therefore submits 200 tasks (5 domains × 10 seeds × 4 settings). The deep state encoder, network dimensions, and target EMA values use the existing OGBench FB launcher defaults. OGBench reward inference uses the launcher's `shift_reward=1` setting.

## Run

From the repository root on Berzelius, after configuring the `td-jepa` environment and `WANDB_API_KEY`:

```bash
bash scripts/train/berzelius/antmaze_reproduction/submit_fb_antmaze_berzelius.sh
```

Optional environment overrides: `NUM_SEEDS` (1–10), `NUM_DOMAINS` (1–5), `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`. `NUM_DOMAINS` selects a prefix in this order: medium-navigate, large-navigate, medium-stitch, large-stitch, medium-explore. State-based OGBench data defaults to `data/ogbench`.
