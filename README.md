# Layoffs Data Cleaning (SQL Project)

## 📌 Overview
This project focuses on cleaning and standardizing a dataset of tech company layoffs using SQL and MySQL.

## 🧽 Cleaning Steps
1. **Remove duplicates** using a window function (`ROW_NUMBER()` with `PARTITION BY`).
2. **Standardize values** (e.g., trimming text, unifying industry names, formatting dates).
3. **Handle NULLs and blanks**, including self-joins to fill missing data.
4. **Drop invalid or unnecessary data**, such as rows with all key fields null.

## 🗃️ Files

```
layoffs-data-cleaning/
├── raw_data/
│   └── layoffs.csv
├── clean_data/
│   └── layoffs_cleaned.csv
├── sql/
│   └── layoffs_cleaning.sql
└── README.md
```

## 🛠️ Tools Used
- MySQL 8
- SQL (window functions, CTEs, joins, updates)

## 🧠 Skills Demonstrated
- Data profiling
- Text standardization
- Date parsing
- NULL handling
- SQL best practices
