CREATE DATABASE netflix_project_3;

CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(25),
	description VARCHAR(250)
);

ALTER TABLE netflix
ALTER COLUMN listed_in TYPE VARCHAR(150);

UPDATE netflix
SET type = NULLIF(type,''),
	title = NULLIF(title, ''),
	director = NULLIF(director, ''),
	casts = NULLIF(casts, ''),
	country = NULLIF(country, ''),
	date_added = NULLIF(date_added, ''),
	rating = NULLIF(rating, ''),
	duration = NULLIF(duration, ''),
	listed_in = NULLIF(listed_in, '');
	

SELECT * FROM netflix;

SELECT COUNT(*) FROM netflix
WHERE type IS NULL

-- 1. count the number of movies vs tv shows
SELECT type, COUNT(*) AS total_content FROM netflix
GROUP BY type;

-- 2. find the most common reating for movies and tv shows
SELECT type, rating 
FROM 
	( SELECT type, rating, COUNT(*),
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY type, rating)
WHERE ranking = 1;

-- 3. list all movies released in a specific year(2020)
SELECT * FROM netflix
WHERE release_year = 2020

-- 4. find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS new_country, 
		COUNT(show_id) AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
		AND
		duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5;


-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
		COUNT(show_id)
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','));

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
	  casts ILIKE '%Salman Khan%'
	  AND 
	  release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
	  
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

/*
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
WITH new_table
AS
(
	SELECT 
	*,
		CASE
		WHEN
				description ILIKE '%kill%' OR
				description ILIKE '%violence%' THEN 'Bad_Content'
				ELSE 'Good_Content'
		END category
	FROM netflix
)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY category;

















