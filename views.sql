-- Views 


-- 1. Industries most affected
	-- View: v_layoffs_by_industry	

CREATE OR REPLACE VIEW v_layoffs_by_industry AS
SELECT
    industry,
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry;

SELECT * FROM v_layoffs_by_industry;


-- 2. Layoffs by country (market risk)
	-- View: v_layoffs_by_country
    
    CREATE OR REPLACE VIEW v_layoffs_by_country AS
SELECT
    country,
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL
GROUP BY country;

SELECT * FROM v_layoffs_by_country;

-- 3a. Layoffs over time (economic trend)
	-- 3a. Monthly layoffs
	-- View: v_layoffs_by_month

CREATE OR REPLACE VIEW v_layoffs_by_month AS
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY month;

SELECT * FROM v_layoffs_by_month;

-- View: Layoffs over time (industry filter)

CREATE OR REPLACE VIEW v_filters_layoff1 AS
SELECT
    DATE(date - INTERVAL DAY(date)-1 DAY) AS month,
    COALESCE(industry, 'Unknown') AS industry,
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY 
    DATE(date - INTERVAL DAY(date)-1 DAY),
    COALESCE(industry, 'Unknown');
    
    SELECT * FROM v_filters_layoff1;

-- 3b. Rolling total layoffs
	-- View: v_layoffs_rolling_total

CREATE OR REPLACE VIEW v_layoffs_rolling_total AS
SELECT
    month,
    total_layoffs,
    SUM(total_layoffs) OVER (ORDER BY month) AS rolling_total
FROM v_layoffs_by_month;

SELECT * FROM v_layoffs_rolling_total;

-- 4. Top 5 companies by layoffs per year
	-- View: v_top_companies_layoffs_by_year
    
    CREATE OR REPLACE VIEW v_top_companies_layoffs_by_year AS
WITH company_year AS (
    SELECT
        company,
        YEAR(`date`) AS year,
        SUM(COALESCE(total_laid_off, 0)) AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM company_year
)
SELECT *
FROM ranked
WHERE ranking <= 5;

SELECT * FROM v_top_companies_layoffs_by_year;

-- 5. Top 5 industries by layoffs per year
	-- View: v_top_industries_layoffs_by_year

CREATE OR REPLACE VIEW v_top_industries_layoffs_by_year AS
WITH industry_year AS (
    SELECT
        industry,
        YEAR(`date`) AS year,
        SUM(COALESCE(total_laid_off, 0)) AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY industry, YEAR(`date`)
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM industry_year
)
SELECT *
FROM ranked
WHERE ranking <= 5;

SELECT * FROM v_top_industries_layoffs_by_year;

-- 6. Riskiest company stages
	-- View: v_layoffs_by_stage

CREATE OR REPLACE VIEW v_layoffs_by_stage AS
SELECT
    stage,
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage;

SELECT * FROM v_layoffs_by_stage;

-- 7. Largest single layoffs (company impact)
	-- View: v_largest_single_layoffs

CREATE OR REPLACE VIEW v_largest_single_layoffs AS
SELECT
    company,
    country,
    stage,
    `date`,
    CAST(total_laid_off AS UNSIGNED) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

SELECT * FROM v_largest_single_layoffs;

-- 8. 
-- This one powers Executive Overview KPIs.
-- View: v_executive_kpis

CREATE OR REPLACE VIEW v_executive_kpis AS
SELECT
    SUM(COALESCE(total_laid_off, 0)) AS total_layoffs,
    COUNT(DISTINCT company) AS companies_affected,
    COUNT(DISTINCT country) AS countries_impacted
FROM layoffs_staging2;

SELECT * FROM v_executive_kpis;

