#!/bin/bash
#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=1                 #optional: number of cpus, default is 1
#SBATCH --mem=16GB                        #optional: amount of memory, default is 4GB per cpu
#SBATCH --job-name=phyml           #optional: job name
#SBATCH --output=phyml%j.out      #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=phyml%j.err       #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-9


# downloading SRR25630409 
mamba activate bgmp_sra

/usr/bin/time -v prefetch SRR25630409
/usr/bin/time -v fasterq-dump SRR25630409

exit
