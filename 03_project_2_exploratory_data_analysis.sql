# MySQL Bootcamp-Project 2: Exploratory Data Analysis in SQL 14.08.2024
-- -------------------------------------------------------------------------------------

# First, I want to look up the complete dataset
SELECT*
FROM layoffs_staging2; 

# I want to see the timeframe of the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; 

# Now I want to see, what the maximum of the people laid off, and the maximum percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

# Next, let's order the companies, which went bankrupt by the funds raised 
SELECT*
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

# Now I want to see which company laid off the most people
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

# Next, I want to see which industry laid off the most people
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# Next, I want to see which country laid off the most people
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# I want to get a feeling of in which year the most people were laid off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

# And I can look up in what stage of a company the most people were laid off
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

# I want to look up, which company laid the most people of in each year
SELECT 
	company, 
	YEAR(`date`), 
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 

# And now we can create a ranking of the top5 companies who laid the most people off in each year. 
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