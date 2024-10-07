-- Exploratory Data Analysis on Layoffs Data

-- Step 1: Inspect the data 
SELECT * FROM layoffs_staging2;


-- Step 2: Check for non-numeric values in total_laid_off column to ensure smooth conversion to INT
SELECT *
FROM layoffs_staging2
WHERE total_laid_off NOT REGEXP '^[0-9]+$';

-- Step 3: Convert total_laid_off column from TEXT to INT for numerical analysis
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

-- Step 4: Find maximum values in total_laid_off and percentage_laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_staging2;

-- Step 5: Identify companies with 100% layoff percentage, sorted by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Step 6: Aggregate total layoffs by company and sort to find top layoff counts
SELECT company, SUM(total_laid_off) -- Amazon: 18150, Google: 12000, Meta: 11000
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Step 7: Identify date range in the dataset (earliest and latest dates)
SELECT MIN(date), MAX(date) -- MIN: 2020-03-11, MAX: 2023-03-06
FROM layoffs_staging2;

-- Step 8: Total layoffs by industry to determine most impacted industries
SELECT industry, SUM(total_laid_off) -- Consumer: 45182, Retail: 43613, Other: 36289
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Step 9: Aggregate total layoffs by country to see geographic distribution of layoffs
SELECT country, SUM(total_laid_off)  -- United States: 256559, India: 35993, Netherlands: 17220
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- Step 10: Analyze layoffs by year to observe annual trends
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- Step 11: Aggregate percentage of layoffs by company to find highest impacted companies
SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY 1 
ORDER BY 2 DESC;

-- Step 12: Analyze layoffs by month and aggregate totals for each month
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 ASC;


SELECT DATE_FORMAT(`date`, '%Y-%m') AS month_year, SUM(total_laid_off)
FROM layoffs_staging2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC;

-- Step 13: Calculate a rolling total of layoffs by month to show cumulative impact over time
WITH Rolling_Total AS
(
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month_year, SUM(total_laid_off) as total_laid
FROM layoffs_staging2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC
) 
SELECT month_year, total_laid, SUM(total_laid) OVER (ORDER BY month_year) as rolling_total
FROM Rolling_Total ;

-- Step 14: Aggregate total layoffs by company and year to identify top companies impacted annually
SELECT company, YEAR(date), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;

-- Step 15: Rank top companies by total layoffs within each year using CTE and RANK()
-- USING CTE 
WITH company_year(company, years, total_laid_off) AS
(
SELECT company, YEAR(date), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(date)
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS comp_rank
FROM company_year
WHERE years IS NOT NULL
)
SELECT * FROM company_year_rank WHERE comp_rank <= 5 ;

-- Another way to get the ranking
WITH Ranked_Companies AS (
    SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off,
           RANK() OVER (PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoffs_staging2
    WHERE YEAR(date) IS NOT NULL
    GROUP BY company, YEAR(date)
)
SELECT *
FROM Ranked_Companies
WHERE ranking <= 5
ORDER BY year, ranking;

























