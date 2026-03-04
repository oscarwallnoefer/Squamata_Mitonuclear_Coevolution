library("tidyverse")

## Load node metrics ----
metrics <- read.csv(
  "Comm_Cytoscape_network_Filtered_ERC_results_R2T_spearman_0.05_0.4_FDR_fg_trimcutoff_0_centralities.csv")

## Permutation function ----
metrics_nomit <- metrics |> 
  filter(Mito == "False") |> 
  select(degree, betweenness, closeness, eigenvector)

metrics_mit <- metrics |> 
  filter(Mito == "True") |> 
  select(degree, betweenness, closeness, eigenvector)

for (metric in colnames(metrics_nomit)) {
  obs_median <- median(metrics_mit[[metric]])
  perm_nuc <- replicate(10000, median(sample(metrics_nomit[[metric]], 10)))
  p_med <- mean(perm_nuc >= obs_median)
  mean_nuc <- mean(perm_nuc)
  sd_nuc <- sd(perm_nuc)
  perm_results[[metric]] <- list(mit_median = obs_median, nuc_mean = mean_nuc,
                                 sd_nuc = sd_nuc, pvalue = p_med)
}

perm_results <- do.call(rbind.data.frame, perm_results)

write.table(perm_results, "network_permutation.tsv", sep = "\t", quote = FALSE)
