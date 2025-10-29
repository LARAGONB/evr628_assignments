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
pkgs <- c("tidyverse", "janitor", "lubridate")
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

# 2. Upload data ----
activities <- read_csv("data/raw/activities_garmin_20251028.csv")
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
# So, I will create a new column named specific_info so that I can have just enough
# details of each activity.
# I haven't highlighted any of the activities as my favorite, then I will remove this column
# Additionally, I will split the date column in date and time, and afterwards I will split
# date into month, day, and year, using the function from the lubridate package.
# I also notices that columns that should be numerical (dbl) were recovered as characters. Therefore,
# I converted them to numeric columns

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
  mutate(date = mdy(date),
         start_time = hm(start_time),
         month = month(date),
         month_abbr = month(date, label = TRUE),
         day = day(date), .after = start_time) |> 
  mutate(across(c(distance:max_elevation, -contains(c("time", "decompression"))), as.numeric)) |> 
  mutate(avg_ground_contact_time = as.numeric(avg_ground_contact_time))


write_rds(activities_clean2, "data/processed/garmin_processed_20251028.rds")


