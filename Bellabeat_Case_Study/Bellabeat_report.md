# Bellabeat Case Study: How Can a Wellness Technology Company Play It Smart?

**Focus Product:** Bellabeat App (Core Digital Platform)  
**Author:** Akech Dau Atem  
**Role:** Junior Data Analyst, Bellabeat Marketing Analytics Team  
**Date:** November 2025

---

## 1️ ASK — Define the Business Task

### Business Objective

Bellabeat, a high-tech manufacturer of health-focused smart products for women, wants to understand **how consumers use smart devices** to inform its **marketing and app engagement strategies**.  
The company aims to leverage insights from **FitBit smart device data** to grow the user base of the **Bellabeat App**.

### Business Task

> Identify trends in smart device usage (activity, sleep, calories, and steps) to understand how women use health-tracking technology — and apply these insights to improve Bellabeat app engagement and membership growth.

### Key Stakeholders

- **Urška Sršen** – Bellabeat Cofounder and Chief Creative Officer
- **Sando Mur** – Cofounder and Mathematician
- **Bellabeat Marketing Analytics Team** – Responsible for data insights and strategy

### Deliverable

A complete analytical report showing:

- Behavioral differences and correlations between activity, sleep, and calories
- Actionable insights for improving Bellabeat app user engagement
- Strategic recommendations for marketing and app features

---

## 2️ PREPARE — Gather and Validate Data

### Data Source

- **Dataset:** FitBit Fitness Tracker Data (30 users)
- **Provider:** Kaggle – [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit)
- **Files Used:**
  - `dailyActivity_merged.csv`
  - `sleepDay_merged.csv`
  - `weightLogInfo_merged.csv`
- **License:** CC0 Public Domain
- **Time Frame:** March–May 2016

### Data ROCCC Evaluation

| Criterion         | Evaluation  | Notes                                               |
| ----------------- | ----------- | --------------------------------------------------- |
| **Reliable**      | Moderate    | Real FitBit data but small sample (30 users)        |
| **Original**      | Third-party | Not collected by Bellabeat                          |
| **Comprehensive** | Partial     | Covers daily activity, sleep, calories              |
| **Current**       | Dated       | 2016 dataset, still useful for behavioral patterns  |
| **Cited**         |             | Publicly available and used for analytics education |

### Privacy & Ethics

- No personally identifiable information (PII).
- Data anonymized and shared publicly with user consent.
- Used strictly for educational and analytical purposes.

---

## 3️ PROCESS — Data Cleaning and Transformation

### Tools Used

- **RStudio** for data manipulation, merging, and cleaning.
- **Libraries:** `tidyverse`, `lubridate`, `janitor`, `skimr`.

### Cleaning Steps Summary

1. **Loaded** raw CSV files from `/data/raw/`
2. **Standardized** column names and date formats
3. **Removed** duplicates and invalid data
4. **Created** new derived columns:
   - `day_of_week`
   - `total_activity_minutes`
   - `weekday_or_weekend`
5. **Merged** `dailyActivity` and `sleepDay` datasets on `id` + `date`
6. **Filtered** out invalid values (steps = 0 or sleep = 0)
7. **Saved** clean dataset: `data/cleaned/fitbit_cleaned.csv`

### Process Output Summary

| Dataset                       | Rows    | Unique IDs | Notes                          |
| ----------------------------- | ------- | ---------- | ------------------------------ |
| `dailyActivity`               | 940     | 33         | Complete                       |
| `sleepDay`                    | 410     | 24         | Duplicates removed             |
| `weightLogInfo`               | 67      | 8          | Excluded (date parsing issues) |
| **Merged (Activity + Sleep)** | **410** | **24**     | Final analytical dataset       |

### Quality Check

- Total rows: 410
- Columns: 13
- Median `total_activity_minutes` ≈ 1440 (expected daily total)

### Key Descriptive Metrics

| Metric                  | Value            | Interpretation                |
| ----------------------- | ---------------- | ----------------------------- |
| Average Steps           | 8,515            | Slightly below the 10k target |
| Average Sleep           | 419 min (~7 hrs) | Healthy sleep duration        |
| Average Calories Burned | 2,389            | Indicates active sample       |
| Sedentary Minutes       | 712 (~11.9 hrs)  | Users sit for half the day    |

---

## 4️ ANALYZE — Identify Patterns and Trends

### Descriptive Summary

```r
summary_stats <- cleaned_data %>%
  summarise(
    avg_steps = mean(total_steps),
    avg_sleep = mean(total_minutes_asleep),
    avg_calories = mean(calories)
  )
```

**Results:**
| Metric | Average | Median | Note |
|---------|----------|--------|------|
| Steps | 8,515 | 7,890 | Moderate activity |
| Sleep | 419 min | 412 min | 7 hours typical |
| Calories | 2,389 | 2,356 | High energy burn |

---

### Correlation Analysis

```r
cor_steps_calories <- cor(cleaned_data$total_steps, cleaned_data$calories)
cor_steps_sleep <- cor(cleaned_data$total_steps, cleaned_data$total_minutes_asleep)
```

| Relationship     | Correlation (r) | Interpretation              |
| ---------------- | --------------- | --------------------------- |
| Steps ↔ Calories | **0.78**        | Strong positive correlation |
| Steps ↔ Sleep    | **0.23**        | Weak positive correlation   |

**Insight:** Active users burn more calories but don’t necessarily sleep more.  
 **App Opportunity:** Personalize wellness insights by linking activity to rest balance.

---

### Weekday vs Weekend Behavior

```r
weekday_summary <- cleaned_data %>%
  group_by(weekday_or_weekend) %>%
  summarise(avg_steps = mean(total_steps),
            avg_sleep = mean(total_minutes_asleep),
            avg_calories = mean(calories))
```

| Type    | Avg Steps | Avg Sleep (min) | Avg Calories |
| ------- | --------- | --------------- | ------------ |
| Weekday | 8,900     | 400             | 2,420        |
| Weekend | 7,800     | 440             | 2,260        |

**Insight:** Users are slightly more active during weekdays and sleep longer on weekends.

---

### Day of Week Trends

```r
day_pattern <- cleaned_data %>%
  group_by(day_of_week) %>%
  summarise(
    avg_steps = mean(total_steps),
    avg_sleep = mean(total_minutes_asleep),
    avg_calories = mean(calories)
  )
```

| Day    | Steps | Sleep (min) | Calories |
| ------ | ----- | ----------- | -------- |
| Monday | 8,900 | 410         | 2,420    |
| Friday | 9,200 | 400         | 2,430    |
| Sunday | 7,700 | 450         | 2,200    |

**Insight:** Activity peaks midweek and drops over weekends — consistent with workday routines.

---

## 5️ SHARE — Visualize Findings

### A. Steps vs Calories Burned

```r
ggplot(cleaned_data, aes(x = total_steps, y = calories)) +
  geom_point(color = "#0096FF", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#FF5733", se = FALSE) +
  labs(title = "Steps vs Calories Burned",
       x = "Total Steps", y = "Calories Burned")
```

**Interpretation:** The linear relationship confirms that increasing daily activity directly increases calorie expenditure.

---

### B. Steps vs Sleep Duration

```r
ggplot(cleaned_data, aes(x = total_steps, y = total_minutes_asleep)) +
  geom_point(color = "#8E44AD", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#F39C12", se = FALSE) +
  labs(title = "Steps vs Sleep Duration",
       x = "Total Steps", y = "Sleep Duration (minutes)")
```

**Interpretation:** Minimal correlation — suggesting separate wellness drivers for physical and rest behavior.

---

### C. Average Steps by Day of Week

```r
ggplot(day_pattern, aes(x = day_of_week, y = avg_steps, fill = day_of_week)) +
  geom_col() +
  labs(title = "Average Steps by Day of Week", y = "Average Steps")
```

**Observation:** Steps increase during weekdays, especially Fridays, aligning with pre-weekend activity peaks.

---

## 6️ ACT — Insights and Recommendations

### Final Insights Summary

| Category             | Insight                                                     | Implication                                                  |
| -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **Activity**         | Users are moderately active (avg 8.5k steps/day).           | Introduce in-app goals to push users toward 10k steps.       |
| **Sleep**            | Average sleep is 7 hrs; weekend sleep increases by ~40 min. | Suggest bedtime reminders and recovery insights on weekends. |
| **Calories**         | Calories and steps strongly correlated.                     | Link calorie awareness to step-based achievements.           |
| **Behavior Pattern** | Weekday activity higher than weekend.                       | Push challenges during weekends to sustain engagement.       |

---

### Strategic Recommendations for the Bellabeat App

#### 1. Personalized Wellness Insights

- Integrate dynamic dashboards that connect daily activity to personalized sleep and calorie feedback.
- Use predictive notifications (e.g., “You sleep better on days you walk more than 7,000 steps”).

#### 2. Gamified Activity Challenges

- Create weekday vs weekend step challenges in the Bellabeat app.
- Offer badges, streaks, or wellness points to maintain engagement during low-activity periods.

#### 3. Smart Reminders & Sleep Coaching

- Implement app-based alerts for consistent bedtime routines.
- Use aggregated trends to provide “Smart Sleep Health Scores”.

#### 4. Subscription-Based Premium Features

- Offer advanced analytics and recommendations in the Bellabeat app’s premium plan.
- Use free data insights (steps, calories) to upsell deeper health insights (heart rate, recovery trends).

---

## 7️ Summary of Deliverables

| Phase       | Tool Used          | Deliverable                               |
| ----------- | ------------------ | ----------------------------------------- |
| **Ask**     | Docs/Spreadsheet   | Clear business objective and stakeholders |
| **Prepare** | SQL/Spreadsheet    | Data collection and ROCCC validation      |
| **Process** | R (tidyverse)      | Cleaned and merged dataset                |
| **Analyze** | R + ggplot2        | Correlations, trends, and visualizations  |
| **Share**   | RMarkdown / Slides | Presentation visuals and narratives       |
| **Act**     | Report / Portfolio | Final recommendations and insights        |

---

## Final Summary

- **Clean dataset prepared:** 410 valid daily activity–sleep records from 24 users.
- **Core insights:** Strong steps–calories link, moderate weekday bias, weekend recovery trend.
- **Outcome:** Clear behavioral insights guiding personalized, data-driven app features.
- **Next step:** Integrate findings into the Bellabeat app roadmap — focusing on habit formation, engagement gamification, and holistic health feedback.

---
