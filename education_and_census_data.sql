# 1. How many public high schools are in each state?

SELECT state_code AS State, COUNT(*) AS Quantity
FROM public_hs_data
WHERE school_name LIKE '% public%'
GROUP BY state_code
ORDER BY 2 DESC;

# 2. How many public high schools are in each zip code?
SELECT zip_code, COUNT(*) AS Quantity
FROM public_hs_data
WHERE school_name LIKE '% public%'
GROUP BY zip_code
ORDER BY 2 DESC;

# 3. Use the CASE statement to display the corresponding locale_text and locale_size in your query result.
SELECT *,
	CASE
		WHEN locale_code = 11 THEN 'Large City'
		WHEN locale_code = 12 THEN 'Midsize City'
		WHEN locale_code = 13 THEN 'Small City'
		WHEN locale_code = 21 THEN 'Large Suburb'
		WHEN locale_code = 22 THEN 'Midsize Suburb'
		WHEN locale_code = 23 THEN 'Small Suburb'
		WHEN locale_code = 31 THEN 'Fringe Town'
		WHEN locale_code = 32 THEN 'Distant Town'
		WHEN locale_code = 33 THEN 'Remote Town'
		WHEN locale_code = 41 THEN 'Fringe Rural'
		WHEN locale_code = 42 THEN 'Distant Rural'
		ELSE 'Remote Rural'
	END AS locale_text
FROM public_hs_data;

# 4. What is the minimum, maximum, and average median_household_income of the nation?
UPDATE census_data
SET median_household_income = NULL
WHERE median_household_income = 'NULL';

SELECT MIN(median_household_income) AS 'Min Median Income',
MAX(median_household_income) AS 'Max Median Income',
ROUND(AVG(median_household_income),2) AS 'Avg Median Income'
FROM census_data;

# 5. And for each state?
SELECT MIN(median_household_income) AS 'Min Median Income',
MAX(median_household_income) AS 'Max Median Income',
ROUND(AVG(median_household_income),2) AS 'Avg Median Income', state_code AS 'State Code'
FROM census_data
GROUP BY state_code
ORDER BY 3 DESC;

# 6. Do characteristics of the zip-code area, such as median household income, influence students’ performance in high school?
SELECT
	CASE
		WHEN median_household_income > 100000 THEN 'Very high income'
		WHEN median_household_income > 50000 AND median_household_income < 100000 THEN 'High income'
		WHEN median_household_income > 25000 AND median_household_income < 50000 THEN 'Average income'
		ELSE 'Low income'
	END AS 'Income Ranges',
ROUND(AVG(pct_proficient_math),2) AS 'Avg Math Prof', ROUND(AVG(pct_proficient_reading),2) AS 'Avg Read Prof'
FROM (SELECT *
FROM census_data
JOIN public_hs_data
	ON census_data.zip_code = public_hs_data.zip_code
WHERE pct_proficient_math NOT NULL)
GROUP BY 1
ORDER BY 2 DESC;

# 7. On average, do students perform better on the math or reading exam? Find the number of states where students do better on the math exam, and vice versa.
UPDATE public_hs_data
SET pct_proficient_math = NULL
WHERE pct_proficient_math = 'NULL';
UPDATE public_hs_data
SET pct_proficient_reading = NULL
WHERE pct_proficient_reading = 'NULL';

SELECT ROUND(AVG(pct_proficient_math),2) AS 'Avg Math Prof', ROUND(AVG(pct_proficient_reading),2) AS 'Avg Read Prof', state_code,
CASE
	WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading) THEN 'Better in Math'
	WHEN AVG(pct_proficient_math) < AVG(pct_proficient_reading) THEN 'Better in Reading'
END AS 'Math vs. Reading'
FROM (SELECT *
FROM census_data
JOIN public_hs_data
	ON census_data.zip_code = public_hs_data.zip_code
WHERE pct_proficient_math NOT NULL)
GROUP BY 3;

# 8. What is the average proficiency on state assessment exams for each zip code, and how do they compare to other zip codes in the same state?
WITH df AS(
SELECT
ROUND(AVG(pct_proficient_math),2) AS state_avg_math,
ROUND(AVG(pct_proficient_reading),2) AS state_avg_read,
ROUND(MIN(pct_proficient_math),2) AS state_min_math,
ROUND(MIN(pct_proficient_reading),2) AS state_min_read,
ROUND(MAX(pct_proficient_math),2) AS state_max_math,
ROUND(MAX(pct_proficient_reading),2) AS state_max_read,
state_code
FROM public_hs_data
WHERE pct_proficient_math NOT NULL
GROUP BY state_code
)
SELECT public_hs_data.zip_code, df.state_code, df.state_avg_math, df.state_avg_read, df.state_min_math, df.state_min_read, df.state_max_math, df.state_max_read,
ROUND(AVG(pct_proficient_math),2) AS zip_avg_math,
ROUND(AVG(pct_proficient_reading),2) AS zip_avg_read,
ROUND(MIN(pct_proficient_math),2) AS zip_min_math,
ROUND(MIN(pct_proficient_reading),2) AS zip_min_read,
ROUND(MAX(pct_proficient_math),2) AS zip_max_math,
ROUND(MAX(pct_proficient_reading),2) AS zip_max_read
FROM public_hs_data
JOIN df
ON public_hs_data.state_code = df.state_code
GROUP BY 1
ORDER BY df.state_code;
