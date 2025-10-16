################################################################################
# Cleaning Garming Connect Activity Data
################################################################################
#
# Lina Marcela Aragón Baquero
# linamaragonb@gmail.com
# October 15, 2025
#
# Description
#
################################################################################  

# 1. Load packages ----
pkgs <- c("tidyverse", "janitor")
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

# 2. Upload data ----
activities <- read_csv("data/raw/activities_garmin.csv")
head(activities)

# 3. Clean data ----
activities_clean <- activities |> 
  clean_names()

# 4. Get to know my data ----
dim(activities_clean)
colnames(activities_clean)

# 5. PROCESSING ----

# The data contains 194 activities (rows) and 42 columns
# The columns contain the name of the activity, time, date, as well as,
# body parameters collected by the watch during those.
# The data is tidier than what I was expecting (Well done :) Garmin).
# However, for the purpose of the class I should do something more than
# running the clean_names function. 
# I did notice that there are two columns associated with the activity's name
# The first column is the "activity_type" and the other one is the "title".
# The column title includes relevant information for running activities, 
# specifically the city in which I ran.
# So, I will attempt to extract that data from that column.

# One that contains the activity_name and another called city so that I can keep
# track of my runns per city :).
# It also seems I haven't highlighted any of the activites as my favorite, then
# I will remove this column too

# Check unique values for activity type
unique(activities_clean$activity_type)

# Check unique values for title
unique(activities_clean$title)


activities_clean2 <- activities_clean |> 
  separate_wider_delim(title, delim = " ",
                       names = c("a", "b", "c"),
                       too_few = "align_start",
                       too_many = "merge") |> 
  mutate(
    b = case_when(
      b %in% c("Cycling", "Hiking", "-", "Running", "and", "101") ~ NA,
      TRUE ~ b),
    c = case_when(
      c %in% c("Hiking", "Running", "Walking") ~ NA,
      TRUE ~ c)) |> 
  unite("specific_info",
        a:b,
        na.rm = TRUE) |>
  select(!c(c,favorite)) |> 
  separate_wider_delim(date, delim = " ",
                       names = c("date", "start_time")) |> 
  separate_wider_delim(date, delim = "/",
                       names = c("month", "day", "year"), cols_remove = FALSE) |> 
  relocate(date, .before = month)



