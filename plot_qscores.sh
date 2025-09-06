#!/bin/bash
#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=1                 #optional: number of cpus, default is 1
#SBATCH --mem=8GB                         #optional: amount of memory, default is 4GB per cpu
#SBATCH --mail-user=sbergan@uoregon.edu   #optional: if you'd like email
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=plot_qscores                   #optional: job name
#SBATCH --output=plot_qscores_%j.out              #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=plot_qscores_%j.err               #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-10

mamba activate demultiplex

/usr/bin/time -v ./plot_qscores.py