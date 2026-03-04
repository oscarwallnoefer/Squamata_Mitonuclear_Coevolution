library(ggplot2)
library(dplyr)

df <- read.csv("Comm_Cytoscape_network_Filtered_ERC_results_R2T_spearman_0.05_0.4_FDR_fg_trimcutoff_0_centralities.csv")
df$Mito <- as.logical(df$Mito)
df_mito <- df %>% filter(Mito == TRUE)

metrics <- c("degree", "betweenness", "closeness", "eigenvector")

for (metric in metrics) {
  plot_title <- paste0(toupper(substr(metric,1,1)), substr(metric,2,nchar(metric)), 
                       ": All genes with mitochondrial genes highlighted")
  file_name <- paste0(metric, "_centrality_plot.svg")
  p <- ggplot(df, aes_string(x = metric)) +
    geom_boxplot(aes(y = 0), width = 0.2, fill = "gray80", alpha = 0.5, outlier.shape = NA) +
    geom_density(aes(y = ..scaled..), fill = "gray80", alpha = 0.3) +
    geom_segment(data = df_mito,
                 aes_string(x = metric, xend = metric, y = 0, yend = 20),
                 color = "#E41A1C", size = 0.6) +
    geom_text(data = df_mito,
              aes_string(x = metric, y = 20 + 0.01, label = "Label"),
              angle = 45, hjust = 0, vjust = 0.5,
              size = 3, color = "#E41A1C") +
    theme_minimal(base_size = 14) +
    theme(panel.grid = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()) +
    labs(x = paste0(toupper(substr(metric,1,1)), substr(metric,2,nchar(metric)), " centrality"),
         y = "",
         title = plot_title)
  print(p)
  ggsave(file_name, plot = p, width = 3, height = 2, units = "in", dpi = 300)
}

### summary statistics
> summary(df$degree)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
0.0004177 0.0054302 0.0137845 0.0214067 0.0317460 0.1319967 
> summary(df$betweenness)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
0.0000000 0.0001098 0.0004040 0.0008746 0.0009826 0.0256838 
> summary(df$closeness)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.2052  0.3059  0.3288  0.3269  0.3506  0.4179 
> summary(df$eigenvector)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
8.000e-09 8.526e-05 6.613e-04 8.775e-03 6.041e-03 9.915e-02 


# vctor
metrics <- c("degree", "betweenness", "closeness", "eigenvector")

# save results
test_results <- list()

for (metric in metrics) {
  mito_vals <- df[df$Mito == TRUE, metric]
  non_mito_vals <- df[df$Mito == FALSE, metric]
  # Wilcoxon rank-sum test
  wtest <- wilcox.test(mito_vals, non_mito_vals, alternative = "two.sided", exact = FALSE)

  test_results[[metric]] <- list(
    metric = metric,
    mito_median = median(mito_vals, na.rm = TRUE),
    non_mito_median = median(non_mito_vals, na.rm = TRUE),
    p_value = wtest$p.value
  )
}

test_results

################ $degree
$degree$metric
[1] "degree"

$degree$mito_median
[1] 0.03717627

$degree$non_mito_median
[1] 0.01378446

$degree$p_value
[1] 0.0008679777


################ $betweenness
$betweenness$metric
[1] "betweenness"

$betweenness$mito_median
[1] 0.002249434

$betweenness$non_mito_median
[1] 0.0004015942

$betweenness$p_value
[1] 1.514016e-05


################ $closeness
$closeness$metric
[1] "closeness"

$closeness$mito_median
[1] 0.3637194

$closeness$non_mito_median
[1] 0.3285753

$closeness$p_value
[1] 0.0001662519


################ $eigenvector
$eigenvector$metric
[1] "eigenvector"

$eigenvector$mito_median
[1] 0.009218096

$eigenvector$non_mito_median
[1] 0.0006480893

$eigenvector$p_value
[1] 0.002037481


