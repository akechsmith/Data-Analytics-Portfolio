
# ===============================
# Step 1: Load Required Libraries
# ===============================
library(tidyverse)
library(lubridate)
library(janitor)
library(skimr)

# ===============================
# Step 2: Load Raw Datasets
# ===============================
activity <- read_csv("data/raw/dailyActivity_merged.csv", show_col_types = FALSE)
sleep    <- read_csv("data/raw/sleepDay_merged.csv", show_col_types = FALSE)
weight   <- read_csv("data/raw/weightLogInfo_merged.csv", show_col_types = FALSE)

# ===============================
# Step 3: Clean Column Names and Standardize Dates
# ===============================
activity <- clean_names(activity)
sleep <- clean_names(sleep)
weight <- clean_names(weight)

activity <- activity %>%
  rename(date = activity_date) %>%
  mutate(date = mdy(date))

sleep <- sleep %>%
  rename(date = sleep_day) %>%
  mutate(date = mdy_hms(date)) %>%
  mutate(date = as_date(date))

weight <- weight %>%
  mutate(date = as_date(date))

# Check data structure
glimpse(activity)
glimpse(sleep)
glimpse(weight)

# ===============================
# Step 4: Handle Duplicates and Missing Data
# ===============================
activity <- distinct(activity)
sleep <- distinct(sleep)
weight <- distinct(weight)

# Count missing values per dataset
cat("\nMissing Values Summary:\n")
print(sapply(activity, function(x) sum(is.na(x))))
print(sapply(sleep, function(x) sum(is.na(x))))
print(sapply(weight, function(x) sum(is.na(x))))

# ===============================
# Step 5: Create Derived Columns
# ===============================
activity <- activity %>%
  mutate(
    day_of_week = wday(date, label = TRUE, abbr = FALSE),
    total_activity_minutes = very_active_minutes + fairly_active_minutes +
      lightly_active_minutes + sedentary_minutes,
    weekday_or_weekend = ifelse(day_of_week %in% c("Saturday", "Sunday"), 
                                "Weekend", "Weekday")
  )

# Validate total minutes (should be near 1440)
summary(activity$total_activity_minutes)

# ===============================
# Step 6: Merge Activity and Sleep Datasets
# ===============================
merged_data <- merge(activity, sleep, by = c("id", "date"), all.x = TRUE)

# Row counts before and after merge
cat("\nRow counts check:\n")
cat("Activity rows: ", nrow(activity), "\n")
cat("Sleep rows: ", nrow(sleep), "\n")
cat("Merged rows: ", nrow(merged_data), "\n")

# ===============================
# Step 7: Clean and Filter Merged Dataset
# ===============================
merged_data <- merged_data %>%
  select(
    id, date, total_steps, total_distance, calories,
    total_minutes_asleep, total_time_in_bed,
    very_active_minutes, lightly_active_minutes, sedentary_minutes,
    total_activity_minutes, day_of_week, weekday_or_weekend
  ) %>%
  filter(total_steps > 0, total_minutes_asleep > 0)

# Preview cleaned data
head(merged_data)
skim(merged_data)

# ===============================
# Step 8: Save the Cleaned Dataset
# ===============================
dir.create("data/cleaned", showWarnings = FALSE)
write_csv(merged_data, "data/cleaned/fitbit_cleaned.csv")

cat("\n Data cleaning complete. Clean file saved to data/cleaned/fitbit_cleaned.csv\n")

# ===============================
# Step 9: Document Key Stats (for report)
# ===============================
cat("\nSummary for documentation:\n")
cat("Rows in cleaned dataset: ", nrow(merged_data), "\n")
cat("Columns in cleaned dataset: ", ncol(merged_data), "\n")

summary_stats <- merged_data %>%
  summarise(
    avg_steps = mean(total_steps, na.rm = TRUE),
    avg_sleep = mean(total_minutes_asleep, na.rm = TRUE),
    avg_calories = mean(calories, na.rm = TRUE)
  )

print(summary_stats)
##############################################
# End of PROCESS Script
##############################################

