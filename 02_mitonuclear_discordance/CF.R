library(viridis)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(GGally)
library(entropy)


gcf <- read.table("gCF.cf.stat", header = T, skip = 14)
scf <- read.table("sCF.cf.stat", header = T, skip = 14)
d <- cbind(scf$ID, scf$sCF, gcf$gCF, scf$bootstrap)
d <- as.data.frame(d)
colnames(d) <- c("id", "scf", "gcf", "bootstrap")

p <- ggplot(d, aes(x = gCF, y = sCF, label = ID)) +
  geom_point(aes(colour = bootstrap), size = 4) +
  scale_colour_viridis_c(option = "D", direction = -1) +
  geom_text_repel(max.overlaps = Inf,
                  box.padding = 0.5,
                  point.padding = 0.1,
                  segment.size = 0.5,
                  size = 3.5) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  coord_cartesian(xlim = c(0, 100), ylim = c(0, 100)) +
  theme_light() +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 11)
  ) +
  labs(x = "gCF", y = "sCF", colour = "Bootstrap")

# Mostra il plot
print(p)

# Salva in SVG
p <- p +
  scale_x_continuous(limits = c(0, 100)) +
  scale_y_continuous(limits = c(0, 100)) +
  coord_fixed(ratio = 1)

ggsave("gCF_vs_sCF.svg", plot = p, width = 5, height = 5, dpi = 300)
