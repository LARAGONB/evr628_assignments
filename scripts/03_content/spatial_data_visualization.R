################################################################################
# Plotting Spatial Data
################################################################################
#
# Lina Marcela Aragón Baquero
# linamaragonb@gmail.com
# November 12, 2025
#
# Description
#
################################################################################  

# 1. Load packages ----
pkgs <- c("tidyverse", "janitor", "ggplot2", "cowplot", "ggspatial",
          "rnaturalearth", "sf", "terra", "tidyterra", "mapview",
          "ggmap")
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

# 2. Upload and filter data ----
## Garming data ----
activities <- read_rds("data/processed/garmin_processed_20251028.rds")

### Filter running and hiking data obtain specific info per place ----
ggmap::register_google("AIzaSyB0rVJ2fQi-N7wmvfixARkdyUKOo8YL-5g")
run_hik_sf <- activities |>
  filter(activity_type %in% c("Running", "Hiking")) |> 
  mutate(specific_info = str_replace(specific_info, "_", " ")) |> 
  mutate_geocode(specific_info, output = "more", .after = "specific_info") |> 
  separate_wider_delim(address, ", ", names = c("city", "state", "country"), 
                       too_few = "align_end") |> 
  mutate(city = case_when(
    state == "honoria 10351" ~ "honoria",
    state == "oaxaca" ~ "oaxaca",
    TRUE ~ city),
    state = str_replace(state, "honoria 10351", "huánuco"),
    country = str_replace(country, "usa", "united states of america")) |> 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |> 
  st_make_valid()

write_rds(run_hik_sf, "data/processed/run_hik_sf_processed_20251028.rds")
  

### Boundaries ----
states <- ne_states(country = unique(run_hik_sf$country))
countries <- ne_countries() |> 
  filter(continent %in% c("North America", "South America"))

write_rds(states, "data/processed/states_sf_processed_20251028.rds")
write_rds(countries, "data/processed/countries_sf_processed_20251028.rds")

### Join tables Activities vs Country/States ----
full_table_country <- st_join(countries, run_hik_sf, join = st_contains, left = FALSE)
full_table_states <- st_join(states, run_hik_sf, join = st_contains, left = FALSE)

### Calculate number of activities per state
activities_number <- full_table_states |> 
  group_by(name) |> 
  summarise(n_activities = n())

running_number <- full_table_states |> 
  filter(activity_type %in% "Running") |> 
  group_by(name) |> 
  summarise(n_activities = n())

hiking_number <- full_table_states |> 
  filter(activity_type %in% "Hiking") |> 
  group_by(name) |> 
  summarise(n_activities = n())

# 3. Plot the results ----
### Create buffer around the countries in which I have ran ----
buffered_points <- st_buffer(full_table_country, dist = 20)
countries_crop <- st_crop(countries, buffered_points)

### Reproject everything -----
crs_proj <- 4326

countries_crop_p    <- st_transform(countries_crop, crs_proj)
full_table_country_p <- st_transform(full_table_country, crs_proj)
full_table_states_p <- st_transform(full_table_states, crs_proj)
activities_number_p <- st_transform(activities_number, crs_proj)
running_number_p <- st_transform(running_number, crs_proj)
hiking_number_p <- st_transform(hiking_number, crs_proj)


### Plot Running & Hiking activities ----
run_hik_plot <- ggplot() +
  geom_sf(data = countries_crop_p, fill = "grey95", color = "grey80") +  
  geom_sf(data = full_table_country_p, fill = "grey80", color = "grey10") +    
  geom_sf(data = activities_number_p, aes(fill = n_activities), inherit.aes = FALSE) +
  scale_fill_viridis_c(option = "C", alpha = 1, begin = 0.3, end = 0.7, direction = -1) +
  labs(
    x = "Longitude",
    y = "Latitude",
    title = "Total number of Running & Hiking activities per state",
    fill = "Number of \nactivities",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(color = "black", size = 10),
    legend.title = element_text(size = 10),
    plot.caption = element_text(size = 8)) +
  annotation_north_arrow(pad_x = unit(0.6, "cm"), pad_y = unit(0.8, "cm")) +
  annotation_scale(location = "bl")

ggsave("results/img/run_hik_plots_20251028.png", run_hik_plot,
       width = 10, height = 5, dpi = 300)

### Plot Running activities ----
run_plot <- ggplot() +
  geom_sf(data = countries_crop_p, fill = "grey95", color = "grey80") +  
  geom_sf(data = full_table_country_p, fill = "grey80", color = "grey10") +    
  geom_sf(data = running_number_p, aes(fill = n_activities), inherit.aes = FALSE) +
  scale_fill_viridis_c(option = "C", alpha = 1, begin = 0.3, end = 0.7, direction = -1) +
  labs(
    x = "Longitude",
    y = "Latitude",
    title = "Total number of Running activities per state",
    fill = "Number of \nactivities",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(color = "black", size = 10),
    legend.title = element_text(size = 10),
    plot.caption = element_text(size = 8)) +
  annotation_north_arrow(pad_x = unit(0.6, "cm"), pad_y = unit(0.8, "cm")) +
  annotation_scale(location = "bl")

ggsave("results/img/run_plots_20251028.png", run_plot,
       width = 10, height = 5, dpi = 300)


### Plot Hiking activities ----
hik_plot <-ggplot() +
  geom_sf(data = countries_crop_p, fill = "grey95", color = "grey80") +  
  geom_sf(data = full_table_country_p, fill = "grey80", color = "grey10") +    
  geom_sf(data = hiking_number_p, aes(fill = n_activities), inherit.aes = FALSE) +
  scale_fill_viridis_c(option = "C", alpha = 1, begin = 0.3, end = 0.7, direction = -1) +
  labs(
    x = "Longitude",
    y = "Latitude",
    title = "Total number of Hiking activities per state",
    fill = "Number of \nactivities",
    caption = "Data obtained from my Garmin watch until October 28, 2025") +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(color = "black", size = 10),
    legend.title = element_text(size = 10),
    plot.caption = element_text(size = 8)) +
  annotation_north_arrow(pad_x = unit(0.6, "cm"), pad_y = unit(0.8, "cm")) +
  annotation_scale(location = "bl")

ggsave("results/img/hik_plots_20251028.png", hik_plot,
       width = 10, height = 5, dpi = 300)
