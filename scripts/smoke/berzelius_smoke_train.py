import copy
import os

from scripts.train.proprio.launch_td_jepa_ogbench import BASE_CFG
from train import TrainConfig

cfg = copy.deepcopy(BASE_CFG)
cfg.update(
    work_dir=os.environ["SMOKE_WORKDIR"],
    num_train_steps=5,       # loop runs steps 0 through 5
    log_every_updates=1,
    checkpoint_every_steps=1000,
    eval_every_steps=1000,
    evaluations=[],          # do not run the expensive rollout evaluation
)

cfg["data"].update(
    dataset_root=os.environ["DATASET_ROOT"],
    load_n_episodes=2,
)

cfg["agent"]["compile"] = False  # avoids torch.compile startup during a smoke test
cfg["agent"]["train"]["batch_size"] = 64

TrainConfig(**cfg).build().train()
print("Smoke training completed successfully.")
