library(tidyverse)
library(patchwork)

# read AU test output

data <- read.table("AU_test_summary.tsv", header = TRUE)

# divide topologies and check pairs
nuc  <- data %>% filter(Tree == 2)  # nuclear
mito <- data %>% filter(Tree == 1)  # mitochondrial
stopifnot(all(nuc$Gene == mito$Gene))

# dataframe gene-wise
df <- data.frame(
  Gene = nuc$Gene,
  deltaL_nuc  = nuc$deltaL,
  deltaL_mito = mito$deltaL,
  pAU_nuc  = nuc$p.AU,
  pAU_mito = mito$p.AU
)

# exclude non-informative genes: if deltaL = 0 for both topologies, exclude
df <- df[!(df$deltaL_nuc == 0 & df$deltaL_mito == 0), ]

# scaling deltaL 0-100, define colors
max_delta <- max(c(df$deltaL_nuc, df$deltaL_mito))
df <- df %>%
  mutate(
    deltaL_nuc_scaled  = deltaL_nuc  / max_delta * 100,
    deltaL_mito_scaled = deltaL_mito / max_delta * 100,
    delta_signed = if_else(deltaL_nuc_scaled >= deltaL_mito_scaled,
                           deltaL_nuc_scaled,
                           -deltaL_mito_scaled),
    color = case_when(
      deltaL_nuc_scaled >= deltaL_mito_scaled & pAU_nuc < 0.05 ~ "#287D8EFF",
      deltaL_mito_scaled >  deltaL_nuc_scaled & pAU_mito < 0.05 ~ "orange",
      TRUE ~ "lightgrey"
    )
  )

# add sequence lengths, input comes from AMAS.py summary
summary <- read.table("summary_AUtest_2334_HOG.txt", header = TRUE, stringsAsFactors = FALSE)
summary <- summary %>% rename(Gene = Alignment_name)

df <- df %>%
  left_join(summary %>% select(Gene, Alignment_length), by = "Gene") %>%
  arrange(Alignment_length) %>%
  mutate(
    Gene = factor(Gene, levels = Gene),
    x = as.numeric(Gene)
  )

# define categories
df <- df %>%
  mutate(category = case_when(
    delta_signed > 0 & pAU_nuc < 0.05  ~ "Nuclear",
    delta_signed < 0 & pAU_mito < 0.05 ~ "Mitocondrial",
    TRUE                               ~ "None"
  ))

df_density <- df %>% filter(category %in% c("Nuclear", "Mitocondrial"))

# lollipop plot + density plot
lollipop_plot <- ggplot() +
  # nuclear density
  geom_density(
    data = df_density %>% filter(category == "Nuclear"),
    aes(x = Alignment_length, y = ..scaled.. * 50),
    fill = "#287D8EFF", alpha = 0.4
  ) +
  # mitochondrial density
  geom_density(
    data = df_density %>% filter(category == "Mitocondrial"),
    aes(x = Alignment_length, y = -..scaled.. * 50),
    fill = "orange", alpha = 0.4
  ) +
  # segments to points
  geom_segment(
    data = df,
    aes(x = Alignment_length, xend = Alignment_length, y = 0, yend = delta_signed, color = color),
    size = 0.8, alpha = 0.6
  ) +
  geom_point(
    data = df,
    aes(x = Alignment_length, y = delta_signed, color = color),
    size = 2, alpha = 0.6
  ) +
  scale_color_identity() +
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.02))) +
  ylim(-100, 100) +
  labs(
    x = "Gene length (aa)",
    y = "Delta likelihood (scaled 0-100)",
    title = "Gene-wise AU test: support nucleare vs mitocondriale"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.ticks.x = element_line(),
    legend.position = "none"
  )

# save genes supporting mitochondrial topology
mito_genes <- df %>%
  filter(deltaL_mito > deltaL_nuc & pAU_mito < 0.05) %>%
  pull(Gene) %>% unique()

write.table(mito_genes, file = "genes_supporting_mitochondrial.txt",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

# pie chart
df <- df %>%
  mutate(
    category = case_when(
      delta_signed > 0 & pAU_nuc < 0.05  ~ "Nuclear topology",
      delta_signed < 0 & pAU_mito < 0.05 ~ "Mitocondrial topology",
      TRUE                               ~ "None"
    )
  )

pie_data <- df %>%
  distinct(Gene, .keep_all = TRUE) %>%
  count(category)

piechart_plot <- ggplot(pie_data, aes(x = "", y = n, fill = category)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  scale_fill_manual(values = c(
    "Mitocondrial topology" = "orange",
    "Nuclear topology" = "#287D8EFF",
    "None" = "lightgrey"
  )) +
  theme_void(base_size = 14) +
  labs(title = "Supporto topologico dei geni")

# combine
combined_plot <- lollipop_plot + piechart_plot + plot_layout(nrow = 1, widths = c(3, 1))

# save as SVG
ggsave("AU_test_lollipop_pie.svg", combined_plot, width = 14, height = 6)


################## SOME STATISTICS
# the overall median length for the 2,334 orthologs is 389 aa. When we consider only those supporting nuclear topology, it is 481, while for mitochondrial supporters is 285. 

> summary(summary$Alignment_length)
     Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    100.0   257.0   389.0   483.8   590.0  4829.0 
> df_density %>% 
  +   filter(category == "Nuclear") %>%
  +   summarise(n = n(), median_len = median(Alignment_length))
      n median_len
  1 809        481
> 
> df_density %>% 
  +   filter(category == "Mitocondrial") %>%
  +   summarise(n = n(), median_len = median(Alignment_length))
      n median_len
  1 111        285
  
# statistical test on lengths differences
nuclear_lengths <- df_density %>% filter(category == "Nuclear") %>% pull(Alignment_length)
mito_lengths    <- df_density %>% filter(category == "Mitocondrial") %>% pull(Alignment_length)

# Wilcoxon rank-sum test
wilcox_test <- wilcox.test(nuclear_lengths, mito_lengths)

Wilcoxon rank sum test with continuity correction
data:  nuclear_lengths and mito_lengths
W = 65186, p-value = 1.101e-14
alternative hypothesis: true location shift is not equal to 0
