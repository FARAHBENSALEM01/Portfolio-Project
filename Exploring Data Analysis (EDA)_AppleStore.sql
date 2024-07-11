CREATE TABLE appleStore_description_combined AS

SELECT *
FROM appleStore_description

UNION ALL

SELECT *
FROM appleStore_description1

UNION ALL

SELECT *
FROM appleStore_description2

UNION ALL

SELECT *
FROM appleStore_description3

UNION ALL

SELECT *
FROM appleStore_description4

-- 1) check the the number of unique ids in both tables (appleApple_Store & appleappleStore_description_combined)

-- Apple_Store:

SELECT COUNT(DISTINCT id) AS UNIQUEAPPIDS
FROM Apple_Store;

-- appleStore_description_combined:

SELECT COUNT(DISTINCT id) AS UNIQUEAPPIDS
FROM appleStore_description_combined;

-- 2) check for any missin values in key columnsApple_Store

-- Apple_Store:

SELECT COUNT(*) AS MISSINGVALUES
FROM Apple_Store
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL;

-- appleStore_description_combined:

SELECT COUNT(*) AS MISSINGVALUES
FROM appleStore_description_combined
WHERE track_name IS NULL OR app_desc IS NULL;

-- 3) LOOKING FOR THE NUMBER OF APPS PER GENRE

-- Apple_Store:

SELECT prime_genre, COUNT(*) AS Countapps
FROM Apple_Store
GROUP BY prime_genre
ORDER BY Countapps DESC;

-- 4) MAX, MIN, AVG of Rating

SELECT
	MAX(user_rating) AS MAX_rating,
    MIN(user_rating) AS MIN_rating,
    AVG(user_rating) AS AVG_rating
FROM Apple_Store;  
  
-- Insights

-- 1) determine whether the paid apps rating is higher than the free apps 

SELECT 
CASE
    WHEN price > 0 THEN 'Paid'
    ELSE 'free'
END AS APPS_RATING,
    AVG(user_rating) AS Avg_rating
FROM Apple_Store
GROUP BY APPS_RATING;

-- 2) looking if Apps with more supported languages have higher ratings 

SELECT 
CASE
    WHEN lang_num < 10 THEN '< 10 languages'
    WHEN lang_num between 10 and 30 THEN '10 - 30 languages'
    ELSE '>30 languages'
END AS Supp_Languages,
    AVG(user_rating) AS Avg_rating
FROM Apple_Store
GROUP BY Supp_Languages
order by Avg_rating DESC;

-- 3) looking for genres with low ratings 

SELECT prime_genre, AVG(user_rating) as AVG_Rating
FROM Apple_Store
GROUP BY prime_genre
ORDER BY AVG_Rating ASC;

/* users gave bad rating for some categories like catalogs, finance meaning that they are not satisfied 
so there might be good opportunity to create an app in this categories */ 

-- 4) looking if there is a correlation between the Length of the App Description and the user_ratings 

SELECT 
CASE
	WHEN length(app_desc) < 500 THEN 'Short'
    WHEN length(app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
    ELSE 'Long' 
END AS DESC_LENGTH, 
    AVG(user_rating) AS AVG_Rating
FROM Apple_Store
JOIN appleStore_description_combined
ON Apple_Store.id = appleStore_description_combined.id
GROUP BY DESC_LENGTH
ORDER BY AVG_Rating ASC;

/* THE LONGER THE DESCRIPTION THE HIGHER THE RATING*/ 

-- 5) looking for the top_rated App for each genre, which mean we need the rank


/**/

WITH TOP_RATED_APPS AS
(
SELECT
	prime_genre, 
	track_name,
	user_rating,
   RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC) AS Rank
FROM Apple_Store
  ) 
SELECT   	
	prime_genre,
	track_name,
	user_rating 
FROM TOP_RATED_APPS
WHERE RANK = 1
GROUP BY prime_genre;