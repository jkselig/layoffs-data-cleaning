/*
  Project: Data Cleaning and Standardization

  Objective:
  Clean and standardize a raw dataset to prepare it for reliable analysis.
  This includes removing duplicates, formatting inconsistent data, handling NULLs,
  and dropping unnecessary or unusable data.

  Overview of Steps:
  1. Identify and remove duplicate records.
  2. Standardize text and date formats across key columns.
  3. Normalize NULLs and fill in missing values where possible.
  4. Remove unnecessary columns and rows with incomplete or invalid data.
*/

Select *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

/*
REMOVE DUPLICATES

  Step 1: Use a window function with ROW_NUMBER() in a CTE 
  to assign a row number to each record based on all columns 
  using PARTITION BY to group duplicates.
  
  Note: If you're using a column named `date`, wrap it in backticks (`date`) 
  since DATE is a reserved keyword in SQL.
  
  Step 2: Filter for rows where row_num > 1 to identify duplicates.
  Manually validate that these are truly duplicates.
  
  Step 3: MySQL does not allow deleting from a CTE, 
  so you need to materialize the CTE by inserting the result 
  into a new table with the row_num column included.
  
  Step 4: Create the duplicate-marked table by doing:
    INSERT INTO new_table 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY col1, col2, ..., colN ORDER BY id) AS row_num
    FROM original_table;
*/


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date` ,stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT *
FROM layoffs_staging
WHERE company = 'Yahoo';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date` ,stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- VALIDATE it worked
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- DELETE DUPLICATES
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

/*
  Data Standardization Steps:

  1. Remove leading and trailing spaces from text fields (e.g., TRIM industry names, company names, etc.).
  2. Review and update inconsistent or incorrect industry names.
  3. Pay close attention to all industry values related to "Crypto"—look for typos, inconsistent formatting, or naming variations.
  4. Standardize similar industry names (e.g., "FinTech" vs. "Financial Technology", "Blockchain" vs. "Crypto").
  5. Convert date columns from text/string format to proper DATE data type.
*/

SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States.';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country = 'United States.';

SELECT distinct country
from layoffs_staging2
Order by 1;

select `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
From layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

/*
  3.  Handling NULLs and Blank Values:

  1. Convert blank strings ('') to NULL values to ensure consistency in comparisons.
  2. Perform a self-join on the table to identify rows where:
     - One row has NULL in a given column, and
     - Another row (with the same key or identifying values) has a valid (NOT NULL) value.
  3. Use this result to update the NULL values with the corresponding NOT NULL values.
*/


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

select *
FROM layoffs_staging2
WHERE industry IS NULL;

/*
  Final Cleanup:

  1. Remove unnecessary columns that do not add value or are no longer needed after transformation.
  2. Remove rows where key data is missing or the row is deemed unusable for analysis.
     - Example: Rows where critical fields like 'total_laid_off' or 'percentage_laid_off' are both NULL.
*/

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;

SELECT COUNT(*) as null_count
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;