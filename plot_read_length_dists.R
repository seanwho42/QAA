#!/packages/R/4.4.2/bin/Rscript
library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

input_file = args[1]
print(input_file)
output_graph = args[2]
print(output_graph)
title_str = args[3]

seqs_lengths = read_tsv(input_file)
print(seqs_lengths)

hist = seqs_lengths %>%
  mutate(read_num = factor(read_num, levels = c("Read 1", "Read 2"))) %>% 
  ggplot(aes(x = seq_length, fill = read_num)) +
  geom_histogram() +
  facet_wrap(~read_num, ncol = 1) +
  theme_bw() +
  theme(legend.position = "none") +
  labs(x = "Sequence Length", y = "Count", title = title_str)

ggsave(output_graph, hist)


