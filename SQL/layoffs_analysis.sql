/* GLOBAL LAYOFFS ANALYSIS PROJECT */

CREATE DATABASE world_layoffs;
USE world_layoffs;

/* INITIAL DATA INSPECTION */

SELECT COUNT(*)
FROM layoffs;

SELECT * FROM layoffs LIMIT 10;

SELECT *
FROM layoffs
WHERE industry IS NULL
   OR industry = '';

UPDATE layoffs
SET company = TRIM(company);

UPDATE layoffs
SET country = TRIM(TRAILING '.' FROM country);

UPDATE layoffs
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs
MODIFY COLUMN date DATE;

DELETE
FROM layoffs
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

UPDATE layoffs t1
JOIN layoffs t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


/* EXPLORATORY DATA ANALYSIS (EDA) */

/* Top 10 Companies with Highest Layoffs */

SELECT company,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;


/* Industries with Highest Layoffs */

SELECT industry,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY industry
ORDER BY total_layoffs DESC;


/* Countries with Highest Layoffs */

SELECT country,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY country
ORDER BY total_layoffs DESC;


/* TIME-BASED ANALYSIS */

/* Year-wise Layoff Trend */

SELECT YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY YEAR(date)
ORDER BY year;


/* Month-wise Layoff Trend */

SELECT YEAR(date) AS year,
       MONTH(date) AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month;


/* Largest Single Layoff Events */

SELECT company,
       date,
       total_laid_off
FROM layoffs
ORDER BY total_laid_off DESC
LIMIT 10;


/* Companies with 100% Layoffs */

SELECT company,
       industry,
       total_laid_off,
       percentage_laid_off
FROM layoffs
WHERE percentage_laid_off = '1';

/* Industry Layoffs by Year */

SELECT industry,
       YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY industry, YEAR(date)
ORDER BY industry, total_layoffs DESC;


/* Companies with Highest Funding and Layoffs */

SELECT company,
       funds_raised_millions,
       total_laid_off
FROM layoffs
ORDER BY funds_raised_millions DESC
LIMIT 20;


/* Layoffs by Company Stage */

SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY stage
ORDER BY total_layoffs DESC;


/* Rolling Total Layoffs Over Time */

SELECT date,
       SUM(total_laid_off) OVER(
           ORDER BY date
       ) AS rolling_total
FROM layoffs;


/* TOP COMPANIES BY YEAR */

WITH company_year AS (

    SELECT company,
           YEAR(date) AS year,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs
    GROUP BY company, YEAR(date)

),

company_rank AS (

    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY year
               ORDER BY total_layoffs DESC
           ) AS ranking
    FROM company_year

)

SELECT *
FROM company_rank
WHERE ranking <= 5;


/* KPI QUERIES */

/* Total Layoffs Worldwide */

SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs;


/* Total Companies Affected */

SELECT COUNT(DISTINCT company) AS total_companies
FROM layoffs;


/* Total Countries Affected */

SELECT COUNT(DISTINCT country) AS total_countries
FROM layoffs;


/* Biggest Single Layoff Event */

SELECT company,
       MAX(total_laid_off) AS biggest_layoff
FROM layoffs
GROUP BY company
ORDER BY biggest_layoff DESC
LIMIT 1;

/* THE END */