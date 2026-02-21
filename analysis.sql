
-- For Analysis (Answering business questions)

-- 1. Which industries are most affected?

SELECT industry,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 2. Layoffs by country (market risk)
 
SELECT country,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


-- 3. Layoffs over time (economic trend)

SELECT 
	SUBSTRING(`date`,1,7) AS `MONTH`, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


WITH Rolling_Total AS
(
SELECT 
	SUBSTRING(`date`,1,7) AS `MONTH`, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT 
	`MONTH`, 
    total_layoffs,
    SUM(total_layoffs) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT
    company,
    SUM(COALESCE(total_laid_off, 0)) AS total_laid_off_sum
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off_sum DESC;

SELECT
    company,
    YEAR(`date`),
    SUM(COALESCE(total_laid_off, 0)) AS total_laid_off_sum
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off_sum DESC;

-- Top five companies that laid people off per year

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT
    company,
    YEAR(`date`),
    SUM(COALESCE(total_laid_off, 0)) AS total_laid_off_sum
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- Top five industries that laid people off per year

WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT
    industry,
    YEAR(`date`),
    SUM(COALESCE(total_laid_off, 0)) AS total_laid_off_sum
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <= 5
;

-- 4. Which company stages are the riskiest?

SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- 5. Largest single layoffs (company impact)

SELECT company,
       total_laid_off,
       country,
       date
FROM layoffs_staging2
ORDER BY CAST(total_laid_off AS UNSIGNED) DESC
LIMIT 10;