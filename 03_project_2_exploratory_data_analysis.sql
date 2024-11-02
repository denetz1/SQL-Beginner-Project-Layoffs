# MySQL Bootcamp-Project 2: Exploratory Data Analysis in SQL
-- -------------------------------------------------------------------------------------

# First, I want to look up the complete dataset
SELECT*
FROM layoffs_staging2; 

# I want to see the timeframe of the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; 

# Now I want to see, what the maximum amount of layoffs as well as the maximum percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

# Next, order the companies, which went bankrupt by the funds raised 
SELECT*
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

# Now I want to see which company had the most layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

# Next, I want to see which industry had the most layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# Next, I want to see which country had the most layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# I want to see in which year there were the most layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

# And I can look up in what stage of the company the most people were laid off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- -------------------------------------------------------------------------------------

# For a more complex query, I can create a rolling total for each month
SELECT 
	SUBSTRING(`date`,1,7) AS `MONTH`,
    SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC; 

WITH Rolling_Total AS (
	SELECT 
		SUBSTRING(`date`,1,7) AS `MONTH`,
		SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`,1,7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 ASC
	)
SELECT 
	`MONTH`, 
	total_off, 
	SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total; 

# I want to look up, which company had the most layoffs in each year
SELECT 
	company, 
	YEAR(`date`), 
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 

# And now I can create a ranking of the top5 companies who had the most layoffs in each year. 
WITH Company_Year (company, years, total_laid_off) AS (
	SELECT 
		company, 
		YEAR(`date`), 
		SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
	), 
Company_Year_Rank AS (
	SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM Company_Year
	WHERE years IS NOT NULL
    )
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;

-- -------------------------------------------------
# End of Project 2 
-- -------------------------------------------------
