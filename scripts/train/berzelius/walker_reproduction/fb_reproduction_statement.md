# DMC Walker FB reproduction

This setup trains the state-based **FB** baseline on ExORL/DMC Walker, corresponding to the Walker row under DMC proprioception in Table 1 of the [TD-JEPA paper](https://arxiv.org/abs/2510.00739). It uses the existing FB learner and evaluation pipeline, with a Berzelius Slurm array around the Walker hyperparameter sweep.

## Configuration

| Parameter | Effective launch value | Paper protocol |
|---|---:|---:|
| Training updates | 2M | 2M for DMC (Table 4) |
| Batch size | 1,024 | 1,024 for state DMC (Table 4) |
| Discount γ | 0.98 | 0.98 (Table 4) |
| FB latent dimension | 50 | Repository FB launcher default |
| Task encoder learning rate `lr_b` | `{1e-4, 1e-5}` | Sweep `{1e-4, 1e-5}` (Appendix E.5) |
| Orthonormal coefficient | `{0.1, 1, 10}` | Existing `sweep_walker` configuration; Table 5 reports `{0.01, 0.1, 1}` for FB DMC |
| Evaluation | 20 episodes per task | 20 DMC episodes (Appendix E.7) |
| Seeds | 5 | 5 for DMC (Appendix E.7); the repo Walker sweep contains five IDs |

The six sweep settings are crossed with each selected seed, for 30 array tasks by default. The model architecture, shallow state encoder, actor, and target update coefficients use the FB launcher's defaults. In DMC the repository default training length is 3M, so this setup explicitly uses the paper's 2M updates.

## Run

From the repository root on Berzelius, after configuring the `td-jepa` environment and `WANDB_API_KEY`:

```bash
bash scripts/train/berzelius/walker_reproduction/submit_fb_berzelius.sh
```

Optional environment overrides: `NUM_SEEDS` (1–5), `NUM_TRAIN_STEPS`, `NUM_EVAL_EPISODES`, `DATASET_ROOT`, `PROJECT_DIR`, and `SWEEP_NAME`. The dataset is expected at `data/exorl_processed/walker/rnd/buffer` unless `DATASET_ROOT` is set.

This uses the repository's existing FB `sweep_walker` unchanged, matching the established launcher configuration. Its regularization values differ from the paper's Table 5 candidates. It matches the paper's reported DMC seed count; the paper does not publish seed IDs, so the repo's five IDs are used.
