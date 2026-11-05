print("running berzelius setup test...")

import torch
print("Torch:", torch.__version__)
print("Built CUDA:", torch.version.cuda)
print("CUDA usable:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))

import mujoco, dm_control, ogbench, metamotivo
print("CUDA:", torch.version.cuda, torch.cuda.is_available())
print("Project imports OK")

from dm_control import suite
# needs MUJOCO_GL and PYOPENGL_PLATFORM env vars set
env = suite.load("walker", "walk")
image = env.physics.render(height=64, width=64, camera_id=0)
print("EGL/MuJoCo OK:", image.shape)

print("berzelius setup test done!")
