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
julia -p40 ./hpc-run.jl > out.txt
