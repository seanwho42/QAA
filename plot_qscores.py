#!/usr/bin/env python

import gzip
import os
from matplotlib import pyplot as plt
import bioinfo
import re


# # for testing
# fq_paths_lengths = [
#     ('test_R1.fq.gz', 12),
#     ('test_R2.fq.gz', 12),
#     ('test_R3.fq.gz', 12),
#     ('test_R4.fq.gz', 12)
# ]

# for real data
# list of tuples with (path, number of reads)
fq_paths_n_reads = [
    ('SRR25630385_1.fastq.gz', 33181752),
    ('SRR25630385_2.fastq.gz', 33181752)
]


def main():
    for read_num, (file, n_reads) in enumerate(fq_paths_n_reads):
        file_identifier = re.search('(.*)\\.fastq\\.gz', file).group(1)
        
        # progress bar initialization
        print(f'Reading {file}')
        with gzip.open(file,'rt') as f:
            for i, line in enumerate(f):
                if i % 4 == 3:
                    line = line.strip()
                    # initialize the list
                    if i == 3:
                        num_chars = len(line)
                        means = [0.0 for i in range(num_chars)]
                    # add to sum
                    for j, char in enumerate(line):
                        means[j] += bioinfo.convert_phred(char)/n_reads
        # plot the thing here
        plt.bar(range(0,num_chars), means)
        plt.title(f'Mean Quality Score by Base Pair Index ({file_identifier})')
        plt.xlabel('# Base Pair')
        plt.ylabel('Mean Quality Score')
        plt.savefig(f'per_base_qscore_{file_identifier}.png')
        plt.cla()
        

main()