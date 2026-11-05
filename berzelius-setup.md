# Berzelius Setup Instructions
 
Berzelius lathund:
* Monitor job status: `squeue -u $USER`
* Submit job: `sbatch myjob.sh`
* Interactive session `interactive -A proj-id -t 1:00:00 --gpus=1 --constraint thin`
* Launch bash: `srun --pty bash`
* Get into the node from the side: `srun --jobid=id --pty bash`