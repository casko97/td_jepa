# Walker reproduction results

Final evaluation results at 2,000,000 training steps for the six `(lr_psi, psi_ortho_coef)` configurations. Each configuration has three seeds (3917, 3502, 8948). Values are mean ± sample standard deviation across seeds (`n = 3`).

The **Walker average** is computed by averaging the four logged task returns (`stand`, `walk`, `run`, `spin`) within each seed, then computing mean ± standard deviation across seeds. This is the Table 1-style Walker aggregate. Task columns show the corresponding per-task aggregates.

| `lr_psi` | `psi_ortho_coef` | Walker average | Stand | Walk | Run | Spin |
|---:|---:|---:|---:|---:|---:|---:|
| 1e-4 | 0.01 | 778.3 ± 52.7 | 924.2 ± 54.7 | 827.8 ± 88.5 | 378.6 ± 74.7 | 982.6 ± 2.7 |
| 1e-4 | 0.1 | 802.0 ± 18.7 | 948.4 ± 24.4 | 895.6 ± 5.4 | 379.0 ± 52.3 | 984.9 ± 2.2 |
| 1e-4 | 1 | 810.0 ± 11.7 | 982.4 ± 7.8 | 896.7 ± 23.0 | 379.1 ± 18.8 | 981.8 ± 3.8 |
| 1e-5 | 0.01 | 673.2 ± 147.5 | 894.6 ± 90.9 | 664.7 ± 324.1 | 247.1 ± 91.8 | 886.3 ± 91.4 |
| 1e-5 | 0.1 | 752.3 ± 34.5 | 941.2 ± 35.0 | 746.7 ± 24.8 | 367.2 ± 76.9 | 954.2 ± 42.7 |
| 1e-5 | 1 | 801.5 ± 26.6 | 969.2 ± 23.9 | 909.3 ± 38.0 | 374.3 ± 42.3 | 953.3 ± 6.0 |
| **Paper: TD-JEPA, DMC proprioception (Table 1)** | — | **785.2 ± 6.7 SE** | — | — | — | — |

The paper reference is the TD-JEPA value for Walker under DMC proprioception in [Table 1](https://arxiv.org/html/2510.00739v1). It reports mean ± standard error across 10 seeds; our rows report standard deviation across the three completed seeds available in this run, so the uncertainty values are not directly comparable. The run uses the first three local seeds, 3917, 3502, and 8948. The four tasks above are the tasks emitted by this run's final Walker evaluation.
