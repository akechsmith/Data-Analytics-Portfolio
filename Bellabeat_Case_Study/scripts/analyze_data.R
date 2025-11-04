# ===============================
# Step 1: Load Cleaned Data
# ===============================
library(tidyverse)
library(lubridate)
library(skimr)
library(ggplot2)
library(janitor)

cleaned_data <- read_csv("data/cleaned/fitbit_cleaned.csv", show_col_types = FALSE)

# Check structure
glimpse(cleaned_data)
skim(cleaned_data)


# ===============================
# Step 2: Descriptive Statistics
# ===============================
summary_stats <- cleaned_data %>%
  summarise(
    avg_steps = mean(total_steps),
    median_steps = median(total_steps),
    avg_sleep = mean(total_minutes_asleep),
    median_sleep = median(total_minutes_asleep),
    avg_calories = mean(calories),
    median_calories = median(calories),
    avg_sedentary = mean(sedentary_minutes)
  )

print(summary_stats)


# ===============================
# Step 3: Correlation Analysis
# ===============================
cor_steps_calories <- cor(cleaned_data$total_steps, cleaned_data$calories, use = "complete.obs")
cor_steps_sleep <- cor(cleaned_data$total_steps, cleaned_data$total_minutes_asleep, use = "complete.obs")

cat("Correlation between Steps and Calories: ", round(cor_steps_calories, 3), "\n")
cat("Correlation between Steps and Sleep: ", round(cor_steps_sleep, 3), "\n")


# ===============================
# Step 4: Weekday vs Weekend
# ===============================
weekday_summary <- cleaned_data %>%
  group_by(weekday_or_weekend) %>%
  summarise(
    avg_steps = mean(total_steps),
    avg_sleep = mean(total_minutes_asleep),
    avg_calories = mean(calories)
  )

print(weekday_summary)


# ===============================
# Step 5: Day of Week Trends
# ===============================
day_pattern <- cleaned_data %>%
  group_by(day_of_week) %>%
  summarise(
    avg_steps = mean(total_steps),
    avg_sleep = mean(total_minutes_asleep),
    avg_calories = mean(calories)
  )

print(day_pattern)


ggplot(cleaned_data, aes(x = total_steps, y = calories)) +
  geom_point(color = "#0096FF", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#FF5733", se = FALSE) +
  labs(title = "Steps vs Calories Burned",
       x = "Total Steps", y = "Calories Burned") +
  theme_minimal()

ggplot(cleaned_data, aes(x = total_steps, y = total_minutes_asleep)) +
  geom_point(color = "#8E44AD", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#F39C12", se = FALSE) +
  labs(title = "Relationship between Steps and Sleep Duration",
       x = "Total Steps", y = "Sleep (Minutes)") +
  theme_minimal()

ggplot(day_pattern, aes(x = day_of_week, y = avg_steps, fill = day_of_week)) +
  geom_col() +
  labs(title = "Average Steps by Day of Week",
       x = "", y = "Average Steps") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(day_pattern, aes(x = day_of_week, y = avg_sleep, fill = day_of_week)) +
  geom_col() +
  labs(title = "Average Sleep by Day of Week",
       x = "", y = "Sleep Duration (minutes)") +
  theme_minimal() +
  theme(legend.position = "none")

