# Berzelius Setup Instructions
 
Berzelius lathund:
* Monitor job status: `squeue -u $USER`
* Submit job: `sbatch myjob.sh`
* Interactive session `interactive -A proj-id -t 1:00:00 --gpus=1 --constraint thin`
* Launch bash: `srun --pty bash`
* Get into the node from the side: `srun --jobid=id --pty bash`

## First time environment creation

1. Load mamba: `module load Miniforge3/24.7.1-2-hpc1-bdist`
2. Crete env: `mamba create -n td-jepa python=3.11`
3. Activate env: `mamba activate td-jepa`
4. Setup torch and CUDA: `CONDA_OVERRIDE_CUDA=13.0 mamba install 'pytorch==2.10.0=cuda*'`

