#!/usr/bin/env python

import gzip
from matplotlib import pyplot as plt
import os
import re


fq_paths = ['SRR25630385_1.fastq.gz', 'SRR25630385_2.fastq.gz']


def main():
    for file in fq_paths:
        file_identifier = re.search('(.*)\\.fastq\\.gz', file).group(1)
        os.makedirs(f'{file_identifier}_plots', exist_ok = True)
        n_counts = {}
        n_reads_at_index = {}
        print(f'Reading {file}')
        with gzip.open(file,'rt') as f:
            for i, line in enumerate(f):
                if i % 4 == 3:
                    line = line.strip()
                    if i == 3:
                        n_reads += 1
                        for char, j in enumerate(line):
                            # making it resilient to varying sequence lengths
                            if j in n_reads_at_index:
                                n_reads_at_index[j] += 1
                            else:
                                n_reads_at_index[j] = 1
                            if char == 'N':
                                if j in n_counts:
                                    n_counts[j] += 1
                                else:
                                    n_counts[j] = 1
            
        
        # make it into a list of percentage content
        print(n_reads_at_index)
        sorted_n_percentages = []
        for i in range(0, max(n_counts.keys())):
            if i in n_counts:
                # in case not all reads are the same length, this makes it a percentage per index
                # rather than a percentage of the total number of reads.. shouldn't matter for raw
                # data but just in case we want to rerun this on trimmed data.
                n_perc = n_counts[i] / n_reads_at_index[i] * 100
                sorted_n_percentages.append(n_perc)

        # plot the thing here
        plt.bar(range(0,num_chars), means)
        plt.title(f'N content by Base Pair Index ({file_identifier})')
        plt.xlabel('# Base Pair')
        plt.ylabel('Mean Quality Score')
        plt.savefig(f'per_base_n_content_{file_identifier}.png')
        plt.cla()
        

main()