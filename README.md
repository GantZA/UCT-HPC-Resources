# Unofficial UCT High Performance Computing Resources
Example scripts and resources for using UCT's High Performance Cluster

## Windows Example Usage

### SSH in using putty

* open putty and enter `hpc.uct.ac.za`
* login with username and password
* YOU ARE NOW ON THE MASTER NODE! CAREFUL!

### Load R/Julia packages

* Open an interactive session on a worker node by running `srun --pty --account=stats --time=60:00  bash -l`
* Load R/Julia by running `module load software/R-3.x.x` or `module load compilers/julia-1.1.1`
* Open R/Julia Terminal by running `R` or `Julia`
* Install R packages using `install.packages()` function
* Install Julia packages by using `] add `

Once the packages have been installed, press `CTRL D` to terminate the interactive bash session
on the worker node.

### Schedule Job Script

Create a `.sh` file with SBATCH directives which will contain all the settings and commands that we want the worker
to run. For example:
```
#!/bin/sh
#SBATCH --account=stats
#SBATCH --partition=ada
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --job-name="surface_plot_alpha_nu"
#SBATCH --mail-user=gntmic002@myuct.ac.za
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

module load compilers/julia-1.1.1
julia -p40 ./hpc_run.jl > out.txt

```
The first line is the __shebang__ which tells the computer that this is a bash script.
The SBATCH lines are arguments for the HPC's job scheduler. We are using the Statistics
account, the _ada_ partition (40 cores per node) for 24 hours, only 1 node, my UCT email will be emailed for status updates, we are running only 1 task and reserving 40 cores for this task.

The lines after the #SBATCH lines are the actual bash commands that are run. The first line
gets the worker node to load Julia and then the second line opens 40 Julia processes and
executes the `hpc-run.jl` file. Any output that would be printed to the command line is
instead saved to `out.txt`

We save this `.sh` file in our working directory somewhere. E.g. I saved the `.sh` file as `test-surface.sh` in my `/home/gntmic002/masters_dissertation/test_scripts` folder. The Julia script file I want to run, `run_hpc.jl` will also be in this folder.

Now to get the HPC to run our job, we run `sbatch test-surface.sh` in the `test_scripts` folder. You should then see a message saying `Submitted batch job xxxxxx`. To monitor this job, run `squeue -u gntmic002`, just replace gntmic002 with your student number. This should list all the running jobs that you have submitted and which node they are running on. You can then go to http://hpc.uct.ac.za/db/ and visually monitor how your assigned node is doing.

