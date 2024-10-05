-- Data Cleaning 

 
SELECT * FROM layoffs;

-- STEP 1: COPYING DATA INTO A STAGING TABLE
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- select * from layoffs_staging
-- where company = 'Oda' and percentage_laid_off = 0.18 and country = "Sweden";

-- STEP 2: HANDLING DUPLICATES

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;
        
INSERT INTO layoffs_staging2
SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, 
       NULLIF(funds_raised_millions, 'None') AS funds_raised_millions,
       ROW_NUMBER() OVER(
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2 WHERE row_num > 1;


-- STEP 3: STANDARDIZING DATA

SELECT company, TRIM(company) FROM layoffs_staging2;
UPDATE layoffs_staging2 SET company = TRIM(company);

SELECT DISTINCT industry FROM layoffs_staging2 ORDER by 1;

SELECT * FROM layoffs_staging2 WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';


-- STEP 4: HANDLING DATES
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoffs_staging2;
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y') WHERE `date` != 'None' AND `date` IS NOT NULL;
UPDATE layoffs_staging2 SET `date` = NULL WHERE `date` = 'None';
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;


-- STEP 5: HANDLING MISSING OR INVALID VALUES

SELECT * FROM layoffs_staging2 WHERE total_laid_off = 'None' AND percentage_laid_off = 'None';
SELECT * FROM layoffs_staging2 WHERE industry = 'None';
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Bally%';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
      ON t1.company = t2.company 
      AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
and t2.industry IS NOT NULL;

UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = 'None';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
and t2.industry IS NOT NULL;


SELECT * FROM layoffs_staging2 WHERE total_laid_off IS NULL;
UPDATE layoffs_staging2 SET total_laid_off = NULL WHERE total_laid_off = 'None' ;

UPDATE layoffs_staging2 SET percentage_laid_off = NULL WHERE percentage_laid_off = 'None';
SELECT * FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2 WHERE funds_raised_millions = 'None';
UPDATE layoffs_staging2 SET stage = NULL WHERE stage = 'None';

-- STEP 6 REMOVING UNNECESSARY COLUMNS AND ROWS
DELETE  FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

-- STEP 7: FINAL QUERIES (Used to further inspect the cleaned data.)

SELECT DISTINCT location,country FROM layoffs_staging2 ORDER BY 1;



























