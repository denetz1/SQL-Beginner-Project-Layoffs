# MySQL Bootcamp-Project 1: Data cleaning in SQL 
-- -------------------------------------------------------------------------------------
# Step 1: Create a new database
# In this tutorial this is not done by query, but we imported a csv-Excel file called "layoffs"

USE world_layoffs;
SELECT*
FROM layoffs;

# Steps for data cleaning: 
-- 0. Create staging dataset (we do not want to changee the raw dataset, so we keep all the information, in case we make a mistake)
-- 1. Remove duplicates
-- 2. Standardize data 
-- 3. Dealing with NULL values or blank salues
-- 4. Remove any columns which are not needed

-- -------------------------------------------------------------------------------------
# Step 0: Create staging data-set

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT*
FROM layoffs;

-- -------------------------------------------------------------------------------------
# Step 1: Remove duplicates

# This step is a bit more complicated, because we do not have a row_id. So the plan now is to create a row number by partitioning by every column
SELECT *, 
ROW_NUMBER () OVER (
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

# We translate this select statement into a CTE
WITH duplicate_cte AS (
SELECT *, 
ROW_NUMBER () OVER (
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT*
FROM duplicate_cte
WHERE row_num > 1;

# Double Check, if the above query works as intended: 
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

# Now I can delete the duplicates: For the showcase of this project I create a copy of the staging table 
# and delete every entry with a row number greater than 1.
# In a real-life situation the layoff_staging table should be updated, of course. 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Copying the data from the first staging table
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER () OVER (
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

# Deleting the Duplicates:
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT*
FROM layoffs_staging2;
# Note: The row_num column has to be deleted later because it holds no information.
# This is normally step 4, but for better readability I moved the query up:
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- -------------------------------------------------------------------------------------
# Step 2: Standardizing Data

# Now I look at the columns ans search for errors
SELECT DISTINCT company
FROM layoffs_staging2;

# I find that some have spaces in front or at the end, so I test my intended update first:  
SELECT company, TRIM(company)
FROM layoffs_staging2;
# And then UPDATE the dataset accordingly
UPDATE layoffs_staging2
SET company = TRIM(company);

# Next is the industry column: 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

# In the industry column there is "crypto", "cryptoCurrency" and "Crypto Currency" which should be identical
SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

# Now I search the country column for errors.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

# I found that the United States have two entrys, because one entry has a period at the end. 
# So I write a query that trims all periods from the entrys 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1; 

# And update the dataset accordingly
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# Now I adjust the datatype for the date column, which is currently text.
# To do so I first convert the text into the right format. 
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

# Now we have the correct format and only need to change the datatype next 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

-- -------------------------------------------------------------------------------------
# Step 3: Dealing with NULLs and Blanks

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

# We found 4 companys with blanks or NULLs in the Dataset. Because some companies have multiple entries we can check, 
# if other entries contain the industry of the company

SELECT *
FROM layoffs_staging2
WHERE company = 'airbnb'; 

# In this dataset airbnb is populated with travel. 
# So now I can write a query that checks all companies, but I need to remove the blanks first and turn them into NULLS

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT 
	t1.company,
    t1.industry,
    t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

# And then rewrite that query into an UPDATE query
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

# Now we only have one company left, which I can not fill in with the information in our data set alone
# The same goes for the total_laid_off, percentage_laid_off and funds_raised_millions columns

-- -------------------------------------------------------------------------------------
# Step 4: Removing columns (and in this case entries) 

# We now can cleanse the layoff dataset from information, we do not need. This next step is not required.
# There are entrys in the "layoff" table, with companies, who had no layoffs and also have no percentage_laid_off. 
# Note: Deleting data is often not recommended but this next query serves as an example how to do it. 

SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

-- -------------------------------------------------------------------------------------
# END of Project
-- -------------------------------------------------------------------------------------