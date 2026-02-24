-- =====================================================
-- Global Layoffs Risk Analysis
-- BI Views for Tableau Integration
-- =====================================================

-- These views are designed to support the Tableau dashboards.
-- Each view corresponds to a specific business question
-- and visualization component.

-- =====================================================
-- Business Question 1:
-- Which countries show the highest layoff exposure?
-- View: v_layoffs_by_country
-- =====================================================

CREATE OR REPLACE VIEW v_layoffs_by_country AS
SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL
GROUP BY country;



-- =====================================================
-- Business Question 2:
-- What are the executive-level KPIs?
-- View: v_executive_kpis
-- =====================================================

CREATE OR REPLACE VIEW v_executive_kpis AS
SELECT
    SUM(total_laid_off) AS total_layoffs,
    COUNT(DISTINCT company) AS companies_affected,
    COUNT(DISTINCT country) AS countries_impacted
FROM layoffs_staging2;



-- =====================================================
-- Business Question 3:
-- How have layoffs evolved over time?
-- View: v_layoffs_by_month
-- =====================================================

CREATE OR REPLACE VIEW v_layoffs_by_month AS
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY month;



-- =====================================================
-- Business Question 4:
-- How can layoffs be analyzed by industry over time?
-- View: v_filters_layoff1
-- =====================================================

CREATE OR REPLACE VIEW v_filters_layoff1 AS
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    COALESCE(industry, 'Unknown') AS industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY month, industry;



-- =====================================================
-- Business Question 5:
-- Which industries are most affected?
-- View: v_layoffs_by_industry
-- =====================================================

CREATE OR REPLACE VIEW v_layoffs_by_industry AS
SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry;



-- =====================================================
-- Business Question 6:
-- Which company stages are most impacted?
-- View: v_layoffs_by_stage
-- =====================================================

CREATE OR REPLACE VIEW v_layoffs_by_stage AS
SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage;



-- =====================================================
-- Business Question 7:
-- Which industries had the highest layoffs per year?
-- View: v_top_industries_layoffs_by_year
-- =====================================================

CREATE OR REPLACE VIEW v_top_industries_layoffs_by_year AS
WITH industry_year AS (
    SELECT
        industry,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY industry, year
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_layoffs DESC
        ) AS ranking
    FROM industry_year
)
SELECT *
FROM ranked
WHERE ranking <= 5;


-- =====================================================
-- Business Question 8:
-- What were the largest single layoff events?
-- View: v_largest_single_layoffs
-- =====================================================

CREATE OR REPLACE VIEW v_largest_single_layoffs AS
SELECT
    company,
    country,
    stage,
    `date`,
    total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;
