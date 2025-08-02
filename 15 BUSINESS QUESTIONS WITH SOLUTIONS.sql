-- Netflix Data Analysis using SQL
-- Solving 15 business problems

1. Count the number of Movies vs TV Shows

SELECT type_of_show,
COUNT (*) as total
FROM netflix
GROUP BY  type_of_show;

2. Find the most common rating for movies and TV shows

WITH ratingcounts as
(
	SELECT type_of_show, rating,
	COUNT (*) as rating_count
	FROM netflix
	GRoup by 1,2
),
rankedratings as (
SELECT type_of_show, rating,rating_count,
RANK()OVER(PARTITION BY type_of_show ORDER BY rating_count DESC) as rank
FROM ratingcounts
)
SELECT type_of_show, rating 
FROM rankedratings
where rank=1

3. List all movies released in a specific year (e.g., 2020)

select *
from netflix
where type_of_show= 'Movie' AND release_year = 2020

4. Find the top 5 countries with the most content on Netflix

SELECT* FROM
(
	SELECT country,
	unnest(STRING_TO_ARRAY (country, ',')) as newcountry,
	count(*) as totalcontent
	from netflix
	group by country
)
where country is not null
order by totalcontent desc
limit 5

SELECT unnest(STRING_TO_ARRAY (country, ',')) as newcountry
from netflix

5. Identify the longest movie

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC

6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(
	SELECT *,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
	FROM netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'

8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1

10. Find each year and the average numbers of content release by India on netflix. 
return top 5 year with highest avg content release !

SELECT country,release_year,
COUNT(show_id) as total_release,
ROUND
	(
		COUNT(show_id)::numeric/
		(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100,2
	) as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'

12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL

13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

SELECT category, type_of_show,
    COUNT(*) AS content_count
FROM
(
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;
