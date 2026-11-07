# AntMaze reproduction results

Final evaluation results at 1,000,000 training steps for the four `(lr_psi, psi_ortho_coef)` configurations. Each configuration has five seeds (3917, 3502, 8948, 9460, 4729). Values are mean ± sample standard deviation across seeds (`n = 5`), in success-rate percentage points.

The **AntMaze medium-navigate average** is computed by averaging the five logged task success rates (`task1`–`task5`) within each seed, then computing mean ± standard deviation across seeds. The task columns show the corresponding per-task aggregates.

| `lr_psi` | `psi_ortho_coef` | AntMaze medium-navigate average | Task 1 | Task 2 | Task 3 | Task 4 | Task 5 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1e-4 | 0.1 | 82.8 ± 5.8 | 82.0 ± 13.0 | 92.0 ± 8.4 | 82.0 ± 4.5 | 68.0 ± 34.2 | 90.0 ± 14.1 |
| 1e-4 | 1 | 69.2 ± 17.2 | 66.0 ± 32.1 | 84.0 ± 5.5 | 44.0 ± 26.1 | 60.0 ± 40.6 | 92.0 ± 8.4 |
| 1e-5 | 0.1 | 60.8 ± 11.4 | 38.0 ± 32.7 | 92.0 ± 8.4 | 8.0 ± 17.9 | 72.0 ± 24.9 | 94.0 ± 8.9 |
| 1e-5 | 1 | 49.6 ± 5.0 | 64.0 ± 20.7 | 80.0 ± 12.2 | 0.0 ± 0.0 | 12.0 ± 16.4 | 92.0 ± 8.4 |
| **Paper: TD-JEPA, OGBench proprioception, antmaze-mn (Table 1)** | — | **70.4 ± 3.72 SE** | — | — | — | — | — |

The paper reference is the TD-JEPA value for AntMaze medium-navigate under OGBench proprioception in [Table 1](https://arxiv.org/html/2510.00739v1). It reports mean ± standard error across 10 seeds; our rows report standard deviation across the five completed seeds available in this run, so the uncertainty values are not directly comparable. The five task columns are the tasks emitted by this run's final AntMaze medium-navigate evaluation.
