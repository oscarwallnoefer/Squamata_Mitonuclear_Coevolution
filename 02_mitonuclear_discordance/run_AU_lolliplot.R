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
  pAU_mito = mito$p.AU)

# exclude non-informative genes (where both delta log-likelihoods are 0)
df <- df[!(df$deltaL_nuc == 0 & df$deltaL_mito == 0),]

# signed delta log-likelihood (RAW values)
df <- df %>%
  mutate(delta_signed = if_else(deltaL_nuc >= deltaL_mito,deltaL_nuc,-deltaL_mito),
    color = case_when(deltaL_nuc >= deltaL_mito & pAU_nuc < 0.05 ~ "#287D8EFF", deltaL_mito > deltaL_nuc & pAU_mito < 0.05 ~ "orange",TRUE ~ "lightgrey"))

# add sequence lengths (take the AMAS summary)
summary <- read.table("summary_AU.txt", header = TRUE,stringsAsFactors = FALSE)
summary <- summary %>% rename(Gene = Alignment_name)
df <- df %>%
  left_join(summary %>% select(Gene, Alignment_length), by = "Gene") %>%
  arrange(Alignment_length) %>%
  mutate(Gene = factor(Gene, levels = Gene), x = as.numeric(Gene))

# define categories
df <- df %>%
  mutate(category = case_when(
    delta_signed > 0 & pAU_nuc < 0.05 ~ "Nuclear",
    delta_signed < 0 & pAU_mito < 0.05 ~ "Mitocondrial",
    TRUE ~ "None"))
df_density <- df %>% filter(category %in% c("Nuclear", "Mitocondrial"))

# lollipop + density plot
lollipop_plot <- ggplot() +
  # nuclear density
  geom_density(
    data = df_density %>% filter(category == "Nuclear"),
    aes(x = Alignment_length, y = ..scaled.. * max(abs(df$delta_signed))),
    fill = "#287D8EFF", alpha = 0.3
  ) +
  # mitochondrial density
  geom_density(
    data = df_density %>% filter(category == "Mitocondrial"),
    aes(x = Alignment_length, y = -..scaled.. * max(abs(df$delta_signed))),
    fill = "orange", alpha = 0.3
  ) +
  # segments
  geom_segment(data = df, aes(x = Alignment_length, xend = Alignment_length, y = 0, yend = delta_signed, color = "white"), size = 0.5, alpha = 1) +
  # points
  geom_point(data = df, aes(x = Alignment_length, y = delta_signed, color = color), size = 2, alpha = 1) +
  scale_color_identity() + scale_x_continuous(expand = expansion(mult = c(0.02, 0.02))) +
  labs(x = "Gene length (aa)",y = "Delta log-likelihood", title = "") +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), axis.ticks.x = element_line(),legend.position = "none")

# save
ggsave("AU_test_lollipop.svg",lollipop_plot,width = 14, height = 6)
