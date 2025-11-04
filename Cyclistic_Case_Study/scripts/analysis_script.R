# Load required libraries
library(tidyverse)   # for data wrangling and visualization
library(lubridate)   # for working with dates
library(janitor)     # for cleaning column names

# 1. Read all 12 CSV files
files <- list.files("data/raw", pattern = "*.csv", full.names = TRUE)
trips <- files %>% map_df(read_csv)

# 2. Clean column names
trips <- clean_names(trips)

# 3. Convert start and end time columns
trips <- trips %>%
  mutate(
    started_at = ymd_hms(started_at),
    ended_at = ymd_hms(ended_at)
  )

# 4. Calculate ride length (in minutes)
trips <- trips %>%
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins")))

# 5. Filter invalid rides
trips <- trips %>%
  filter(ride_length > 0 & ride_length < 1440)

# 6. Add day_of_week column
trips <- trips %>%
  mutate(day_of_week = wday(started_at, label = TRUE, abbr = FALSE))

# 7. Check first few rows
head(trips)

# Summary statistics for members vs casual riders
summary_stats <- trips %>%
  group_by(member_casual) %>%
  summarise(
    total_rides = n(),
    average_ride_length = mean(ride_length),
    median_ride_length = median(ride_length),
    max_ride_length = max(ride_length)
  )

print(summary_stats)


# Average ride length and total rides by day of week
avg_by_day <- trips %>%
  group_by(member_casual, day_of_week) %>%
  summarise(
    avg_length = mean(ride_length),
    rides = n(),
    .groups = "drop"
  )

print(avg_by_day)


# Add hour of day column
trips <- trips %>% mutate(hour = hour(started_at))

# Count rides per hour
rides_by_hour <- trips %>%
  group_by(member_casual, hour) %>%
  summarise(rides = n(), .groups = "drop")

print(rides_by_hour)


library(ggplot2)

# 1. Ride count by day of week
ggplot(avg_by_day, aes(x = day_of_week, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Ride Volume by Day of Week", x = "", y = "Number of Rides", fill = "User Type") +
  theme_minimal()

# 2. Average ride length by day of week
ggplot(avg_by_day, aes(x = day_of_week, y = avg_length, color = member_casual, group = member_casual)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(title = "Average Ride Length by Day of Week", y = "Avg Ride Length (min)", x = "") +
  theme_minimal()

# Save 
write_csv(summary_stats, "data/cleaned/summary_stats.csv")
write_csv(avg_by_day, "data/cleaned/avg_by_day.csv")

# (a) Average ride length by user type
avg_length_plot <- summary_stats %>%
  ggplot(aes(x = member_casual, y = average_ride_length, fill = member_casual)) +
  geom_col(width = 0.5) +
  labs(title = "Average Ride Length: Members vs Casual Riders",
       x = "User Type", y = "Average Ride Length (minutes)") +
  theme_minimal() +
  theme(legend.position = "none")

avg_length_plot
# save plot
ggsave("plots/Average_ride_length_by_user_type.png", width = 8, height = 5)


# (b) Average ride length by day of week
ggplot(avg_by_day, aes(x = day_of_week, y = avg_length, color = member_casual, group = member_casual)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(title = "Average Ride Length by Day of Week",
       y = "Average Duration (minutes)", x = "") +
  theme_minimal()

# Save 
ggsave("plots/Average_Ride_Length_by_Day_of_Week.png", width = 8, height = 5)


# (c) Rides by hour of day
ggplot(rides_by_hour, aes(x = hour, y = rides, color = member_casual)) +
  geom_line(size = 1.2) +
  labs(title = "Ride Frequency by Hour of Day",
       x = "Hour (0–23)", y = "Number of Rides") +
  theme_minimal()

# Save 
ggsave("plots/Rides_by_hour_of_day.png", width = 8, height = 5)

