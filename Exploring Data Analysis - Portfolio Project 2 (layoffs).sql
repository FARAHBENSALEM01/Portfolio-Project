-- Exploratory Data Analysis
-- Here we are going to explore the Data and see what will help us to analyse 

SELECT *
FROM layoffs_copy2;

-- First we will look at the MAX and MIN of the Total_laid-off

SELECT MAX(total_laid_off)
FROM layoffs_copy2;

SELECT MIN(total_laid_off)
FROM layoffs_copy2; 

-- Looking at Percentage to see how big these layoffs were

SELECT percentage_laid_off
FROM layoffs_copy2
ORDER BY 1 DESC;

-- So apparentely 1 represent 100 percent of the company laid off

SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_copy2
WHERE  percentage_laid_off IS NOT NULL;

SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = 1;

-- total employees

WITH employee_CTE AS
(
SELECT company, YEAR(`date`) Year , total_laid_off, percentage_laid_off, (total_laid_off/(percentage_laid_off/100)) Total_employees
FROM layoffs_copy2
where (total_laid_off IS NOT NULL
AND percentage_laid_off IS NOT NULL)
AND YEAR(date) IS NOT NULL
ORDER BY YEAR(`date`) ASC, total_laid_off DESC
)
SELECT company, Year, total_laid_off, percentage_laid_off, ROUND(Total_employees, 0) AS rounded_Total_employees
FROM employee_CTE
where ROUND(Total_employees, 0) IS NOT NULL
ORDER BY rounded_Total_employees;


-- These Companies must be Startups to lay off all these employees,
-- We can say also that those Companies faced a difficult time during that period.
-- Looking at funds_raised and we can order by companies to see how big some of these companies were

SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- So we can see that for example Britishvolt in the transportation industry raised like 2 Billion Dollars and then laid off 100% of the employees, and many other Companies in different industries faced the same problem in that time



-- Now let's look for the top 5 Companies with the highest Layoff

SELECT company, total_laid_off
FROM layoffs_copy2
where total_laid_off IS NOT NULL
ORDER BY 2 DESC
limit 5;

-- Companies with the most Total Layoffs

SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
where total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC
limit 20;	

-- by location

SELECT location, SUM(total_laid_off)
FROM layoffs_copy2
where total_laid_off IS NOT NULL
GROUP BY location
ORDER BY 2 DESC
limit 20;

-- by Industry

SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
where total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC
limit 20;

-- by Country

SELECT country, SUM(total_laid_off)
FROM layoffs_copy2
where total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC
limit 20;

-- Per Year

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_copy2
WHERE YEAR(date) IS NOT NULL
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- by Stage

SELECT stage, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC
limit 20;

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year and ranking them.

WITH Company_Year AS
(SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_copy2
GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Time-Series Analysis (Rolling Monthly Total Layoffs)
-- Calculate rolling totals of layoffs per month

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_copy2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC;

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_copy2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, total_laid_off, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
  















