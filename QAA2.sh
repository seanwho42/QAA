#!/bin/bash
#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=24                 #optional: number of cpus, default is 1
#SBATCH --mem=100GB                        #optional: amount of memory, default is 4GB per cpu
#SBATCH --job-name=qaa           #optional: job name
#SBATCH --output=qaa%j.out      #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=qaa%j.err       #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-12

unset SLURM_CPU_BIND

mamba activate QAA

SRR=SRR25630409

# # downloading SRR

# /usr/bin/time -v prefetch ${SRR}
# /usr/bin/time -v fasterq-dump ${SRR}

# # fastqc
# sbatch --account bgmp --partition bgmp --time 0-12 --mem 100GB -n 2 --job-name=fastqc --output=fastqc_${SRR}_%j.out --error=fastqc_${SRR}_%j.err \
#     --wrap "/usr/bin/time -v fastqc --svg -t 8 --memory 10000 ${SRR}_*.fastq"

# # cutadapt
# sbatch --account bgmp --partition bgmp --time 0-12 --mem 24GB -n 12 --job-name=cutadapt_1 --output=cutadapt_1_${SRR}_%j.out --error=cutadapt_1_${SRR}_%j.err  \
#     --wrap "mamba activate QAA; /usr/bin/time -v cutadapt -j 0 -a $R1_adapter -o ${SRR}_1_cutadapt.fastq.gz ${SRR}_1.fastq.gz"
# srun --account bgmp --partition bgmp --time 0-12 --mem 24GB -c 12 --job-name=cutadapt_2 --output=cutadapt_2_${SRR}_%j.out --error=cutadapt_2_${SRR}_%j.err \
#     /usr/bin/time -v cutadapt -j 0 -a $R2_adapter -o ${SRR}_2_cutadapt.fastq.gz ${SRR}_2.fastq.gz


# # fastqc after cutadapt
# sbatch --account bgmp --partition bgmp --time 0-12 --mem 100GB -n 2 --job-name=fastqc --output=fastqc_${SRR}_%j.out --error=fastqc_${SRR}_%j.err \
#     --wrap "/usr/bin/time -v fastqc --svg -t 8 --memory 10000 ${SRR}_*_cutadapt.fastq.gz"

# # trimmomatic
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 12 --job-name=trimmomatic_${SRR} --output=trimmomatic_${SRR}_%j.out --error=trimmomatic_${SRR}_%j.err \
#     /usr/bin/time -v java -Xmx99g -jar /home/sbergan/miniforge3/envs/QAA/share/trimmomatic-0.40-0/trimmomatic.jar \
#     PE -threads 12 ${SRR}_1_cutadapt.fastq.gz ${SRR}_2_cutadapt.fastq.gz \
#     trim_paired_${SRR}_1.fq.gz trim_unpaired_${SRR}_1.fq.gz trim_paired_${SRR}_2.fq.gz trim_unpaired_${SRR}_2.fq.gz \
#     ILLUMINACLIP:adapters.fa:2:30:10 HEADCROP:8 LEADING:3 TRAILING:3 SLIDINGWINDOW:5:15 MINLEN:35

# # fastqc after trimmomatic
# sbatch --account bgmp --partition bgmp --time 0-12 --mem 100GB -n 2 --job-name=fastqc --output=fastqc_${SRR}_%j.out --error=fastqc_${SRR}_%j.err \
#     --wrap "/usr/bin/time -v fastqc --svg -t 8 --memory 10000 trim_paired_${SRR}_1.fq.gz trim_paired_${SRR}_2.fq.gz"

# # make a character count file with information for each

# echo -e "read_num\tseq_length" > ${SRR}_read_lengths.tsv
# n=0
# for file in trim_paired_${SRR}_1.fq.gz trim_paired_${SRR}_2.fq.gz; do
#     n=$((n + 1))
#     zcat $file | sed -n '2~4 p' | awk '{ print length }' | sed -E "s/(.*)/Read $n\t\1/" >> ${SRR}_read_lengths.tsv
# done

# # svg isn't working in Rmd for some reason so not this
# /usr/bin/time -v ./plot_read_length_dists.R ${SRR}_read_lengths.tsv seq_length_dist_${SRR}.svg "${SRR} read lengths distribution"
/usr/bin/time -v ./plot_read_length_dists.R ${SRR}_read_lengths.tsv seq_length_dist_${SRR}.png "${SRR} read lengths distribution"

# # set the paths for all of the genome alignment deal
# genomeDir=campy_genome/
# genomeFastaFiles=campylomormyrus.fasta
# sjdbGTFfile=campylomormyrus.gtf
# R1=trim_paired_${SRR}_1.fq.gz
# R2=trim_paired_${SRR}_2.fq.gz

# if [[ ! -e $sjdbGTFfile ]]; then
#   agat_convert_sp_gff2gtf.pl --gff campylomormyrus.gff -o $sjdbGTFfile
# fi

# # make the genome directory if we need to
# if [[ ! -e $genomeDir ]]; then
#   mkdir $genomeDir

#   # generate the genome index deal
#   srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=star_gen_${SRR} --output=star_gen_${SRR}_%j.out --error=star_gen_${SRR}_%j.err \
#     /usr/bin/time -v STAR --runThreadN 8 --runMode genomeGenerate \
#     --genomeDir $genomeDir \
#     --genomeFastaFiles $genomeFastaFiles \
#     --sjdbGTFfile $sjdbGTFfile
# elif [[ ! -d $genomeDir ]]; then
#     echo "$genomeDir already exists but is not a directory" 1>&2
# fi

# # align the reads
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=star_align_${SRR} --output=star_align_${SRR}_%j.out --error=star_align_${SRR}_%j.err \
#   /usr/bin/time -v STAR --runThreadN 24 --runMode alignReads \
#   --outFilterMultimapNmax 3 \
#   --outSAMunmapped Within KeepPairs \
#   --alignIntronMax 1000000 --alignMatesGapMax 1000000 \
#   --readFilesCommand zcat \
#   --readFilesIn $R1 $R2 \
#   --genomeDir $genomeDir \
#   --outFileNamePrefix campy_${SRR}_

# # convert to bam first
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=sam_convert_${SRR} --output=sam_convert_${SRR}_%j.out --error=sam_convert_${SRR}_%j.err \
#   /usr/bin/time -v samtools view -bo campy_${SRR}_aligned.bam campy_${SRR}_Aligned.out.sam

# # now sorting it
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=sam_sort_${SRR} --output=sam_sort_${SRR}_%j.out --error=sam_sort_${SRR}_%j.err \
#   /usr/bin/time -v samtools sort -o campy_${SRR}_sorted.bam -@ 24 campy_${SRR}_aligned.bam

# # need to add read groups for picard
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=sam_rg_${SRR} --output=sam_rg_${SRR}_%j.out --error=sam_rg_${SRR}_%j.err \
#   /usr/bin/time -v samtools addreplacerg -r "@RG\tID:RG1\tSM:campylomormyrus\tPL:Illumina\tLB:campylomormyrus.fasta" -o campy_${SRR}_rg.bam campy_${SRR}_sorted.bam

# # now picard
# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=picard_${SRR} --output=picard_${SRR}_%j.out --error=picard_${SRR}_%j.err \
#   /usr/bin/time -v picard MarkDuplicates \
#   I=campy_${SRR}_rg.bam \
#   O=campy_${SRR}_marked_duplicates.bam \
#   M=campy_${SRR}_marked_dupes_metrics.txt \
#   REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT

# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=sam_convert_${SRR} --output=sam_convert_${SRR}_%j.out --error=sam_convert_${SRR}_%j.err \
#   /usr/bin/time -v samtools view -ho campy_${SRR}_marked_duplicates.sam campy_${SRR}_marked_duplicates.bam

# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=count_mapped_${SRR} --output=count_mapped_${SRR}_%j.out --error=count_mapped_${SRR}_%j.err \
#   /usr/bin/time -v ./mapped_unmapped.py -f "campy_${SRR}_marked_duplicates.sam"

# # now time for htseq-count
# # make the directory if it doesn't exist
# if [[ ! -e htseq_results ]]; then
#   mkdir htseq_results
# fi


# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=htseq-count_${SRR} --output=htseq_results/${SRR}.txt --error=htseq-count_${SRR}_%j.err \
#   /usr/bin/time -v htseq-count -i ID --stranded yes campy_${SRR}_marked_duplicates.sam campylomormyrus.gff

# srun --account bgmp --partition bgmp --time 0-12 --mem 100GB -c 24 --job-name=htseq-count_rev_${SRR} --output=htseq_results/${SRR}_rev.txt --error=htseq-count_rev_${SRR}_%j.err \
#   /usr/bin/time -v htseq-count -i ID --stranded reverse campy_${SRR}_marked_duplicates.sam campylomormyrus.gff