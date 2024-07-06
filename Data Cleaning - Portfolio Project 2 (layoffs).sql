-- Data Cleaning using (MySQL workbench 8.0 CE)
-- 1 Remove Duplicates
-- 2 Standardize the Data
-- 3 Null Values or Blank Values
-- 4 Remove any unecessary Columns

CREATE TABLE layoffs_Copy
LIKE layoffs;

SELECT *
FROM layoffs_Copy;

INSERT layoffs_Copy
SELECT *
FROM layoffs;

-- Remove Duplicate

# First let's check for duplicates


SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
					company,
                    location,
                    industry,
                    total_laid_off,
                    percentage_laid_off,
                   `date`,
                    stage,
                    country,
                    funds_raised_millions
                    ) as Row_num
FROM layoffs_Copy;

WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
			company,
                    location,
                    industry,
                    total_laid_off,
                    percentage_laid_off,
                   `date`,
                    stage,
                    country,
                    funds_raised_millions
                    ) as Row_num
FROM layoffs_Copy)
SELECT *
FROM duplicate_CTE
WHERE ROW_NUM > 1;

-- let's just look at Casper to confirm

SELECT *
FROM layoffs_copy
WHERE company = 'Casper';

-- Adding a new column (row_num) to help delete the duplicates
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_copy2;

INSERT INTO layoffs_copy2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
					company,
                    location,
                    industry,
                    total_laid_off,
                    percentage_laid_off,
                   `date`,
                    stage,
                    country,
                    funds_raised_millions
                    ) as Row_num
FROM layoffs_Copy;

SELECT *
FROM layoffs_copy2
WHERE Row_num > 1;

-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

DELETE
FROM layoffs_copy2
WHERE Row_num > 1;

-- Standardize the Data

-- Trim the space in company column

SELECT company, TRIM(company)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company = TRIM(company);

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these

SELECT DISTINCT(industry)
FROM layoffs_copy2
order by 1;

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

SELECT *
FROM layoffs_copy2
WHERE industry like 'Crypto%';

UPDATE layoffs_copy2
SET industry = 'Crypto'
where industry like 'Crypto%';

SELECT DISTINCT(location)
FROM layoffs_copy2
ORDER BY 1;

SELECT DISTINCT(country)
FROM layoffs_copy2
ORDER BY 1;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

UPDATE layoffs_copy2
SET country = 'United States'
where country like 'United%';

-- fix the data type of the date column from text to datetime
-- we can use str to date to update this field

UPDATE layoffs_copy2
SET `date` = str_to_date (`date`, '%m/%d/%Y');

ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` Date;

-- Null Values or Blank Values

SELECT *
FROM layoffs_copy2
where total_laid_off IS NULL;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these

SELECT DISTINCT(industry)
FROM layoffs_copy2
ORDER BY 1;

-- we should set the blanks to nulls since those are typically easier to work with

UPDATE layoffs_copy2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_copy2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_copy2
WHERE company like 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- now we need to populate those nulls if possible

SELECT t1.industry, t2.industry
FROM layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values

SELECT *
FROM layoffs_copy2
WHERE company like 'Bally%';

--  Remove any unecessary Columns

SELECT*
FROM layoffs_copy2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use

DELETE
FROM layoffs_copy2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_copy2
DROP COLUMN row_num;

SELECT *
FROM layoffs_copy2;
	



