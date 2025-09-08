#!/usr/bin/env python
import argparse

# script modified from PS8
# dealing with arguments
def get_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("-f", "--file", help="Input sam file", required=True)
    return parser.parse_args()

args = get_args()

#counting things
with open(args.file, 'r') as f:
    mapped_reads = 0
    unmapped_reads = 0
    for line in f:
        split_line = line.split('\t')
        if line[0][0] != '@':
            flag = int(split_line[1])
            # only count if primary alignment
            if ((flag & 256) != 256):
                # check flag if it is mapped
                if((flag & 4) != 4):
                    mapped_reads += 1
                else:
                    unmapped_reads += 1
    print(f'# mapped: {mapped_reads}\n# unmapped: {unmapped_reads}')

# mapped: 21851108
# unmapped: 1645850