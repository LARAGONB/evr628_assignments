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
# I like that the title one has shorter names for the activities, 
# but it includes relevant information for my running activities, 
# specifically the city in which I ran.
# So, I will keep just "title", but I will split this one in two columns:
# One that contains the activity_name and another called city so that I can keep
# track of my runns per city :).
# It also seems I haven't highlighted any of the activites as my favorite, then
# I will remove this column too

activities_clean |> 
  select(title) |> 
  unique(activities_clean$activity_type)

activites_clean2 <- activities_clean |> 
  select(-c(activity_type, favorite)) |> 
  relocate(title, .before = everything()) 



