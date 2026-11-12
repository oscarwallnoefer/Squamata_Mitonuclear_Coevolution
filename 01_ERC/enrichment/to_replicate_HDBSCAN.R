# Load libraries
library(ggplot2)
library(ggforce)
library(dbscan)
library(dplyr)

# Define headers
revigo.names <- c("term_ID","description","frequency","plot_X","plot_Y","log_size","value","uniqueness","dispensability")

# Import revigo data
revigo.data <- ############### COPY AND PASTE BP HERE!

one.data <- data.frame(revigo.data)
names(one.data) <- revigo.names
num.cols <- c("plot_X","plot_Y","log_size","value","frequency","uniqueness","dispensability")
one.data[num.cols] <- lapply(one.data[num.cols], function(x) as.numeric(as.character(x)))

# Clustering HDBSCAN
coords <- one.data %>% select(plot_X, plot_Y)
hdb <- hdbscan(coords, minPts = 3) ################# CHANGE minPts HERE!
one.data$cluster <- hdb$cluster

# Use frequency as labeling criteria ################### CHOOSE BETWEEN "log_size","value","frequency","uniqueness","dispensability" 
label.data <- one.data %>%
  filter(cluster != 0) %>%
  group_by(cluster) %>%
  slice_max(frequency, n = 1) %>%
  ungroup()

# ############### CHOOSE COLOR
point_color <- "#45204fff"

# Plot
p <- ggplot(one.data) +
  geom_mark_hull(
    data = one.data %>% filter(cluster != 0),
    aes(plot_X, plot_Y, group = cluster),
    expand = unit(2.5, "mm"),
    alpha = 0.2,
    fill = point_color,
    colour = point_color,
    size = 0.3
  ) +
  geom_point(
    aes(plot_X, plot_Y, fill = value, size = log_size),
    shape = 21,
    colour = "black",
    alpha = 0.9,
    stroke = 0.3
  ) +
  geom_text(
    data = label.data,
    aes(plot_X, plot_Y, label = description),
    size = 2.8,
    colour = "black"
  ) +
  scale_fill_gradient(
    low = "white",
    high = point_color,
    limits = c(min(one.data$value), 0)
  ) +
  scale_size(range = c(1, 4)) +
  theme_bw() +
  coord_fixed(
    xlim = c(-8, 8),
    ylim = c(-8, 8),
    ratio = 1
  ) +
  labs(
    x = "Semantic Space X",
    y = "Semantic Space Y"
  ) +
  theme(
    axis.title = element_text(size = 10, family = "Helvetica"),
    axis.text  = element_text(size = 8, family = "Helvetica"),
    legend.title = element_text(size = 8),
    legend.text  = element_text(size = 7)
  )
                             
p

# Save as pdf
ggsave("revigo_plot_C0.pdf", p, width = 4, height = 4)
