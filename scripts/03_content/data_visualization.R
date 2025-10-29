################################################################################
# Plotting my garmin data
################################################################################
#
# Lina Marcela Aragón Baquero
# linamaragonb@gmail.com
# October 28, 2025
#
# Description
#
################################################################################  

# 1. Load packages ----
pkgs <- c("tidyverse", "janitor", "ggplot2", "cowplot")
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

# 2. Upload data ----
activities <- read_rds("data/processed/garmin_processed_20251028.rds")
head(activities)

# 3. Make a plot to compare average and maximum heart rate between HIIT and Running acitivities ----
heart_rate_plots <- activities |> 
  filter(activity_type %in% c("Running", "HIIT", "Strength Training")) |> 
  mutate(activity_type = fct_relevel(activity_type, "HIIT", "Strength Training", "Running")) |> 
  pivot_longer(cols = contains("hr"), 
               names_to = "summary_hr",
               values_to = "hr") |> 
  ggplot(aes(x = month_abbr, y = hr)) +
  geom_boxplot(aes(fill = activity_type, color = activity_type), 
               position =  position_dodge(width = 0.8), 
               outliers = FALSE) +
  geom_point(aes(color = activity_type), 
             position = position_jitterdodge(dodge.width = 0.8), 
             size = 0.5) +
  scale_fill_viridis_d(option = "C", alpha = 0.5, begin = 0.3, end = 0.7) +
  scale_color_viridis_d(option = "C", alpha = 1, begin = 0.3, end = 0.7) +
  scale_y_continuous(breaks = seq(75, 200, 25), limits = c(75, 200)) +
  facet_wrap(~ summary_hr, labeller = as_labeller(c( avg_hr = "Average",
                                                   max_hr ="Maximum"))) +
  labs(
    x = "Month",
    y = "Heart rate (Beats per minute)",
    fill = "Activity",
    color = "Activity",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    plot.caption = element_text(size = 8)
  )

heart_rate_plots

ggsave("results/img/heart_rate_plots_20251028.png", heart_rate_plots,
       width = 10, height = 5, dpi = 300)


# 4. Let's play with the data obtained from my hiking and running activiies ----

## a. Stacked column plot showing the total distance covered by hiking and running activities per month ----

colplot_hik_run <- activities |> 
  filter(activity_type %in% c("Hiking", "Running")) |> 
  group_by(month_abbr, activity_type) |> 
  summarise(total_distance = sum(distance), .groups = "drop") |> 
  ggplot(aes(x = month_abbr, y = total_distance, fill = activity_type)) +
  geom_col() +
  scale_fill_viridis_d(option = "C", alpha = 0.8, begin = 0.3, end = 0.7) +
  labs(
    x = "Month",
    y = "Distance (Km)",
    fill = "Activity",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    plot.caption = element_text(size = 8)
  )

colplot_hik_run

ggsave("results/img/colplot_hik_run_20251028.png", colplot_hik_run,
       width = 6, height = 5, dpi = 300)


## b. Scatter plot showing the relationship between distance (Km) and total ascent (m) ----

activities |> 
  filter(activity_type %in% c("Hiking", "Running")) |> 
  mutate(total_ascent = replace_na(total_ascent, 0)) |> 
  reframe(range_ta = range(total_ascent),
          range_dist = range(distance),
          range_avg_hr = range(avg_hr),
          range_max_hr = range(max_hr))

scat_hik_run <- activities |> 
  filter(activity_type %in% c("Hiking", "Running")) |> 
  mutate(total_ascent = replace_na(total_ascent, 0)) |> 
  ggplot(aes(x = distance, y = total_ascent, shape = activity_type, color = activity_type)) +
  geom_point(size = 4) +
  geom_smooth(method = "lm") +
  scale_fill_viridis_d(option = "C", alpha = 0.5, begin = 0.3, end = 0.7) +
  scale_color_viridis_d(option = "C", alpha = 1, begin = 0.3, end = 0.7) +
  scale_y_continuous(breaks = seq(0, 550, 100)) +
  scale_x_continuous(breaks = seq(0, 12, 2), limits = c(0, 12)) +
  labs(
    x = "Distance (Km)",
    y = "Total ascent (m)",
    shape = "Activity",
    color = "Activity",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    plot.caption = element_text(size = 8)
  )

scat_hik_run

ggsave("results/img/scat_hik_run_20251028.png", scat_hik_run,
       width = 6, height = 5, dpi = 300)

## c. Scatter plot showing the relationship between distance (Km) and average heart rate (bpm) ----

avghr_hik_run <- activities |> 
  filter(activity_type %in% c("Hiking", "Running")) |> 
  mutate(total_ascent = replace_na(total_ascent, 0)) |> 
  ggplot(aes(x = distance, y = avg_hr, shape = activity_type, color = activity_type)) +
  geom_point(size = 4) +
  geom_smooth(method = "lm") +
  scale_fill_viridis_d(option = "C", alpha = 0.5, begin = 0.3, end = 0.7) +
  scale_color_viridis_d(option = "C", alpha = 1, begin = 0.3, end = 0.7) +
  scale_y_continuous(breaks = seq(80, 180, 20), limits = c(80, 180)) +
  scale_x_continuous(breaks = seq(0, 12, 2), limits = c(0, 12)) +
  labs(
    x = "Distance (Km)",
    y = "Avg. heart rate (bpm)",
    shape = "Activity",
    color = "Activity",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    plot.caption = element_text(size = 8)
  )

avghr_hik_run

ggsave("results/img/avghr_hik_run_20251028.png", avghr_hik_run,
       width = 6, height = 5, dpi = 300)

## d. Scatter plot showing the relationship between distance (Km) and maximum heart rate (bpm) ----

maxhr_hik_run <- activities |> 
  filter(activity_type %in% c("Hiking", "Running")) |> 
  mutate(total_ascent = replace_na(total_ascent, 0)) |> 
  ggplot(aes(x = distance, y = max_hr, shape = activity_type, color = activity_type)) +
  geom_point(size = 4) +
  geom_smooth(method = "lm") +
  scale_fill_viridis_d(option = "C", alpha = 0.5, begin = 0.3, end = 0.7) +
  scale_color_viridis_d(option = "C", alpha = 1, begin = 0.3, end = 0.7) +
  scale_y_continuous(breaks = seq(115, 185, 10), limits = c(115, 185)) +
  scale_x_continuous(breaks = seq(0, 12, 2), limits = c(0, 12)) +
  labs(
    x = "Distance (Km)",
    y = "Max. heart rate (bpm)",
    shape = "Activity",
    color = "Activity",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    plot.caption = element_text(size = 8)
  )

maxhr_hik_run

ggsave("results/img/maxhr_hik_run_20251028.png", maxhr_hik_run,
       width = 6, height = 5, dpi = 300)


## e. Create combined plot ----

colplot_hik_run_wl <- colplot_hik_run + theme(legend.position = "none",
                                              plot.caption = element_blank())

scat_hik_run_wl <- scat_hik_run + theme(legend.position = "none",
                                        plot.caption = element_blank())

avghr_hik_run_wl <- avghr_hik_run + theme(legend.position = "none",
                                          plot.caption = element_blank())

maxhr_hik_run_wl <- maxhr_hik_run + theme(legend.position = "none",
                                          plot.caption = element_blank())

legend_a <- get_legend(colplot_hik_run)
legend_b <- get_legend(maxhr_hik_run)

caption_plot <- ggplot() + 
  geom_text(aes(x = 0, y = 0, 
                label = "Data obtained from my Garmin watch until October 28, 2025"), 
            hjust = 0.5, vjust = 0.5, size = 3, fontface = "italic") + 
  theme_void()

plot_wl <- plot_grid(colplot_hik_run_wl, scat_hik_run_wl,
          avghr_hik_run_wl, maxhr_hik_run_wl,
          ncol = 2,
          labels = c("A.", "B.", "C.", "D."))

plot_wl2 <- plot_grid(plot_wl, caption_plot, 
                     ncol = 1,
                     rel_heights = c(3,0.1))

plot_l <- plot_grid(legend_a, legend_b,
                    ncol = 1)

combined_plot <- plot_grid(plot_wl2, plot_l, 
                           ncol = 2,
                           rel_widths = c(3, 1)) +
  theme(plot.background = element_rect(fill = "white", colour = NA))

ggsave("results/img/combined_plot_20251028.png", combined_plot,
       width = 12, height = 8, dpi = 300)
