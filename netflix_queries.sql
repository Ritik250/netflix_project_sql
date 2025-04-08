select * from netflix;


select count(*) from netflix where description is null;


-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows
select 
	type,
	count(*) 
from 
	netflix 
group by 
	type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
select * 
from netflix 
where release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
select * 
from
(select 
unnest(string_to_array(country,',')) as country,
count(*) as total_content
from netflix 
group by 1) as t1
where country is not null
order by total_content desc 
limit 5

-- 5. Identify the longest movie
select * from netflix
where type = 'Movie'
order by split_part(duration,' ',1):: int desc


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from(
select * , unnest(string_to_array(director,',')) as director_name from netflix) where director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
select * from netflix 
where type = 'TV Show' and 
	split_part(duration,' ',1)::int > 5

-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as genre,
	count(*) 
from netflix 
group by 1;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5



-- 11. List all movies that are documentaries
select * 
from netflix 
where type ='Movie' and
	listed_in like '%Documentaries%';


-- 12. Find all content without a director
select * from netflix where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where 
	casts like '%Salman Khan%'
	and release_year> extract(year from current_date) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts,',')) as actor,
	count(*)
	from netflix 
where country = 'India'
group by 1
order by 2 desc
limit 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


select category, 
	type, 
	count(*) as content_count 
from 
	(select *, 
	case 
		when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
	else 'Good'
	end as category
from netflix) as categorized_content group by 1,2 order by 2 
    