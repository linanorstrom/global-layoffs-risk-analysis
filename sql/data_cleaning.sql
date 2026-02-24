
-- =====================================================
-- Global Layoffs Risk Analysis
-- Data Cleaning Script
-- =====================================================

-- Steps:
-- 0. Preparation
-- 1. Remove duplicates
-- 2. Standardize text fields
-- 3. Handle null and blank values
-- 4. Fix data types
-- =====================================================


-- =====================================================
-- 0. Preparation
-- =====================================================

-- 0.1 Create staging table to preserve raw data
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;


-- =====================================================
-- 1. Remove Duplicates
-- =====================================================

-- 1.1 Identify duplicates using ROW_NUMBER()
CREATE TABLE layoffs_staging2 AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry,
                        total_laid_off, percentage_laid_off,
                        `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- 1.2 Remove duplicate rows
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- 1.3 Drop helper column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- =====================================================
-- 2. Standardize Text Fields
-- =====================================================

-- 2.1 Trim whitespace in company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2.2 Standardize industry naming (Crypto variations)
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 2.3 Remove trailing punctuation in country field
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- =====================================================
-- 3. Handle Null and Blank Values
-- =====================================================

-- 3.1 Replace 'None' in date column with NULL
UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'None';

-- 3.2 Fill missing industry values using company matches
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry = '' OR t1.industry = 'NONE')
  AND t2.industry NOT IN ('', 'NONE');

-- 3.3 Remove rows with no layoff information
DELETE FROM layoffs_staging2
WHERE total_laid_off IN ('NONE', '')
  AND percentage_laid_off IN ('NONE', '');


-- =====================================================
-- 4. Fix Data Types
-- =====================================================

-- 4.1 Convert date column from TEXT to DATE
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
