# Cyclistic Bike-Share Case Study: Converting Casual Riders to Annual Members

**Author:** Akech Dau Atem  
**Role:** Junior Data Analyst, Cyclistic Marketing Analytics Team  
**Date:** November 2025  

---

## 1. Executive Summary

The primary goal of this analysis was to design marketing strategies to convert **casual riders** into more profitable **annual members** by understanding their distinct usage patterns.

The analysis established a clear split in behavior: **Annual members are commuters (functional use)**, while **casual riders are leisure users (recreational use)**.

| Key Insight | Casual Riders | Annual Members | Marketing Focus |
| :--- | :--- | :--- | :--- |
| **Trip Duration** | Significantly longer (Avg: 20.9 min) | Shorter, functional (Avg: 12.2 min) | **Value Proposition** for cost/convenience |
| **Timing** | Heavily concentrated on **weekends and midday** | Consistent on **weekdays**, peaking during rush hours (8 AM/5 PM) | **Incentivize** weekday use |

---

## 2. Project Scope and Methodology

### Business Task Statement
Analyze Cyclistic's historical trip data to identify key behavioral differences between casual riders and annual members, providing insights that can guide marketing strategies to convert casual riders into members.

### Data Preparation Summary
* **Data Source:** 12 months (Oct 2023 – Sept 2024) of Cyclistic's publicly available trip data [https://divvy-tripdata.s3.amazonaws.com/index.html](https://divvy-tripdata.s3.amazonaws.com/index.html).  
* **Tools:** R (Tidyverse, ggplot2, lubridate).  
* **Cleaning:** Approximately 5.8 million records were combined, cleaned, and filtered to remove trips with negative or excessively long durations (> 24 hours/1440 minutes). New features (`ride_length`, `day_of_week`, `hour`) were calculated.

---

## 3. Process: Data Cleaning and Transformation (R Code)

```r
# Load required libraries
library(tidyverse)
library(lubridate)
library(janitor)

# 1. Read all 12 CSV files
files <- list.files("data/raw", pattern = "*.csv", full.names = TRUE)
trips <- files %>% map_df(read_csv)

# 2. Clean column names
trips <- clean_names(trips)

# 3. Convert start and end time columns and calculate new features
trips_cleaned <- trips %>%
  mutate(
    started_at = ymd_hms(started_at),
    ended_at = ymd_hms(ended_at),
    ride_length = as.numeric(difftime(ended_at, started_at, units = "mins")),
    day_of_week = wday(started_at, label = TRUE, abbr = FALSE),
    hour = hour(started_at)
  ) %>%
  # 4. Filter invalid rides
  filter(ride_length > 0 & ride_length < 1440)
```

---

## 4. Analyze: Summary Statistics

### 4.1. Overall Ride Duration and Frequency

```r
# Summary statistics for members vs casual riders
summary_stats <- trips_cleaned %>%
  group_by(member_casual) %>%
  summarise(
    total_rides = n(),
    average_ride_length = mean(ride_length),
    median_ride_length = median(ride_length),
    max_ride_length = max(ride_length),
    .groups = "drop"
  )
print(summary_stats)
```

| member_casual | total_rides | average_ride_length | median_ride_length | max_ride_length |
|----------------|-------------|----------------------|---------------------|----------------|
| casual | 2,124,292 | 20.86 | 11.97 | 1439.92 |
| member | 3,721,367 | 12.20 | 8.67 | 1439.92 |

**Interpretation:** Casual riders take rides that are nearly double the average duration of member rides, confirming a leisure-based usage pattern. Members ride shorter distances more frequently.

---

### 4.2. Temporal Usage (Day of Week)

```r
# Average ride length and total rides by day of week
avg_by_day <- trips_cleaned %>%
  group_by(member_casual, day_of_week) %>%
  summarise(
    avg_length = mean(ride_length),
    rides = n(),
    .groups = "drop"
  )
print(avg_by_day)
```

| member_casual | day_of_week | avg_length | rides |
|----------------|--------------|-------------|--------|
| casual | Sunday | 24.18 | 365,235 |
| casual | Monday | 20.23 | 253,959 |
| casual | Saturday | 23.59 | 428,762 |
| member | Sunday | 13.57 | 421,565 |
| member | Monday | 11.66 | 539,929 |
| member | Wednesday | 11.90 | 612,828 |

**Interpretation:** Casual rider volume and average ride length peak significantly on weekends (Sat/Sun), contrasting sharply with members' consistent, short-duration weekday usage.

---

## 5. Share: Visualizations (R Code & Output)

### A. Ride Volume by Day of Week

```r
ggplot(avg_by_day, aes(x = day_of_week, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Ride Volume: Casual Riders Spike on Weekends",
       x = "", y = "Number of Rides", fill = "User Type") +
  theme_minimal()
```

### B. Average Ride Length by Day of Week

```r
ggplot(avg_by_day, aes(x = day_of_week, y = avg_length, color = member_casual, group = member_casual)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  labs(title = "Average Ride Length: Casual Trips Are Consistently Longer",
       y = "Avg Ride Length (min)", x = "") +
  theme_minimal()
```

### C. Ride Volume by Hour of Day

```r
rides_by_hour <- trips_cleaned %>%
  group_by(member_casual, hour) %>%
  summarise(rides = n(), .groups = "drop")
```

**Key Visual Insight:** The hourly plot clearly shows members peaking during rush hour (8 AM/5 PM), while casual riders are most active throughout the midday (10 AM - 4 PM), reinforcing the commuter vs. leisure distinction.

---

## 6. Act: Top Three Recommendations

### 1. Weekend-to-Weekday Conversion Campaign
Offer frequent weekend casual riders a highly discounted "Commuter-Styled 7-Day Weekday Trial Pass" to experience weekday functional usage.

### 2. Targeted Cost-Savings Promotion
Deploy in-app and digital ads near leisure/tourist zones that directly show how much cheaper annual membership is compared to per-ride costs.

### 3. "Adventure Tier" Soft Conversion
Introduce a loyalty tier that rewards high-usage casual riders (e.g., after 5 passes) with perks like free electric bike upgrades or discounted membership.

---

**End of Report**
