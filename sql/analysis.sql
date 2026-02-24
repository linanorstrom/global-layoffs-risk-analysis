-- =====================================================
-- Global Layoffs Risk Analysis
-- Exploratory Data Analysis (EDA)
-- =====================================================

-- Business Questions:
-- 1. Which industries are most affected?
-- 2. Which countries show the highest layoff exposure?
-- 3. How have layoffs evolved over time?
-- 4. Which company stages are most impacted?
-- 5. Which companies experienced the largest total layoffs?
-- 6. Which companies had the largest layoffs per year?
-- 7. Which industries had the highest layoffs per year?
-- 8. What were the largest single layoff events?
-- =====================================================



-- =====================================================
-- 1. Which industries are most affected?
-- =====================================================

SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;



-- =====================================================
-- 2. Which countries show the highest layoff exposure?
-- =====================================================

SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;



-- =====================================================
-- 3. How have layoffs evolved over time?
-- =====================================================

-- 3.1 Monthly layoffs trend
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY month
ORDER BY month ASC;


-- 3.2 Rolling cumulative layoffs
WITH Monthly_Layoffs AS (
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY month
)
SELECT
    month,
    total_layoffs,
    SUM(total_layoffs) OVER (ORDER BY month) AS rolling_total
FROM Monthly_Layoffs;



-- =====================================================
-- 4. Which company stages are most impacted?
-- =====================================================

SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;



-- =====================================================
-- 5. Which companies experienced the largest total layoffs?
-- =====================================================

SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;



-- =====================================================
-- 6. Which companies had the largest layoffs per year?
-- =====================================================

WITH Company_Year AS (
    SELECT
        company,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, year
),
Company_Rank AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
    FROM Company_Year
)
SELECT *
FROM Company_Rank
WHERE ranking <= 5;



-- =====================================================
-- 7. Which industries had the highest layoffs per year?
-- =====================================================

WITH Industry_Year AS (
    SELECT
        industry,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY industry, year
),
Industry_Rank AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
    FROM Industry_Year
)
SELECT *
FROM Industry_Rank
WHERE ranking <= 5;



-- =====================================================
-- 8. What were the largest single layoff events?
-- =====================================================

SELECT
    company,
    total_laid_off,
    country,
    `date`
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 10;
