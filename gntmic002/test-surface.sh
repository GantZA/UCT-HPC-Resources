#!/bin/sh
#SBATCH --account=stats
#SBATCH --partition=swan
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --job-name="surface_plot_D_sigma_002"
#SBATCH --mail-user=gntmic002@myuct.ac.za
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

module load compilers/julia-1.1.1
julia -p40 hpc_run.jl 20 32 "D" 1.0 5.0 "σ" 0.1 4.0 > out.txt

