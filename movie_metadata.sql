SELECT * FROM movies_data.movie_metadata
LIMIT 10; -- You can adjust the limit as needed
-- How many records are there in the dataset?
SELECT COUNT(*) AS total_records
FROM movies_data.movie_metadata;
-- Top 10 Highest-Grossing Movies:
SELECT movie_title, gross
FROM movies_data.movie_metadata
ORDER BY gross DESC
LIMIT 10;
-- Average IMDb Score of Movies:
SELECT AVG(imdb_score) AS average_imdb_score
FROM movies_data.movie_metadata;

-- Average IMDb Score of Movies Directed by Each Director
SELECT director_name, AVG(imdb_score) AS avg_imdb_score
FROM movies_data.movie_metadata
GROUP BY director_name;

-- Correlation between Director's Facebook Likes and IMDb Score:
SELECT 
    (
        SUM((director_facebook_likes - director_fb_likes_mean) * (imdb_score - imdb_score_mean)) /
        (SQRT(SUM(POW(director_facebook_likes - director_fb_likes_mean, 2)) * SUM(POW(imdb_score - imdb_score_mean, 2))))
    ) AS correlation
FROM (
    SELECT 
        AVG(director_facebook_likes) AS director_fb_likes_mean,
        AVG(imdb_score) AS imdb_score_mean
    FROM movies_data.movie_metadata
) AS mean_values,
movies_data.movie_metadata;

-- Top 10 Most Popular Actors/Actresses Based on Facebook Likes:
SELECT 
    actor_1_name AS actor_name, 
    SUM(actor_1_facebook_likes) AS total_facebook_likes
FROM 
    movies_data.movie_metadata
GROUP BY 
    actor_1_name
UNION ALL
SELECT 
    actor_2_name AS actor_name, 
    SUM(actor_2_facebook_likes) AS total_facebook_likes
FROM 
    movies_data.movie_metadata
GROUP BY 
    actor_2_name
UNION ALL
SELECT 
    actor_3_name AS actor_name, 
    SUM(actor_3_facebook_likes) AS total_facebook_likes
FROM 
    movies_data.movie_metadata
GROUP BY 
    actor_3_name
ORDER BY 
    total_facebook_likes DESC
LIMIT 10;

-- Average IMDb Score for Movies Featuring Different Actors in the Top 10:
CREATE TEMPORARY TABLE top_actors_temp AS
    SELECT actor_name, SUM(total_facebook_likes) AS total_likes
    FROM (
        SELECT actor_1_name AS actor_name, actor_1_facebook_likes AS total_facebook_likes FROM movies_data.movie_metadata
        UNION ALL
        SELECT actor_2_name AS actor_name, actor_2_facebook_likes AS total_facebook_likes FROM movies_data.movie_metadata
        UNION ALL
        SELECT actor_3_name AS actor_name, actor_3_facebook_likes AS total_facebook_likes FROM movies_data.movie_metadata
    ) AS all_actors
    GROUP BY actor_name
    ORDER BY total_likes DESC
    LIMIT 10;

SELECT 
    actor_name, 
    AVG(imdb_score) AS avg_imdb_score
FROM (
    SELECT 
        actor_1_name AS actor_name, 
        imdb_score
    FROM 
        movies_data.movie_metadata
    UNION ALL
    SELECT 
        actor_2_name AS actor_name, 
        imdb_score
    FROM 
        movies_data.movie_metadata
    UNION ALL
    SELECT 
        actor_3_name AS actor_name, 
        imdb_score
    FROM 
        movies_data.movie_metadata
) AS actors_imdb_scores
WHERE 
    actor_name IN (SELECT actor_name FROM top_actors_temp)
GROUP BY 
    actor_name;

DROP TEMPORARY TABLE top_actors_temp;

-- Top 5 Most Common Genres:
SELECT genres, COUNT(*) AS genre_count
FROM movies_data.movie_metadata
GROUP BY genres
ORDER BY genre_count DESC
LIMIT 5;

-- Distribution of IMDb Scores Across Different Genres
SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(m.genres, '|', n.n), '|', -1) AS genre,
    AVG(m.imdb_score) AS avg_imdb_score,
    COUNT(*) AS movie_count
FROM 
    movies_data.movie_metadata m
JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
    ON CHAR_LENGTH(m.genres) - CHAR_LENGTH(REPLACE(m.genres, '|', '')) >= n.n - 1
GROUP BY 
    genre;
    
   -- Correlation between Facebook Likes and IMDb Score:
  SELECT 
    (
        SUM((movie_facebook_likes - facebook_likes_mean) * (imdb_score - imdb_score_mean)) /
        (SQRT(SUM(POW(movie_facebook_likes - facebook_likes_mean, 2)) * SUM(POW(imdb_score - imdb_score_mean, 2))))
    ) AS correlation
FROM (
    SELECT 
        AVG(movie_facebook_likes) AS facebook_likes_mean,
        AVG(imdb_score) AS imdb_score_mean
    FROM movies_data.movie_metadata
) AS mean_values,
movies_data.movie_metadata;

-- Relationship between Facebook Likes and Box Office Gross:
SELECT 
    AVG(gross) AS avg_gross,
    AVG(movie_facebook_likes) AS avg_facebook_likes
FROM 
    movies_data.movie_metadata;

-- Correlation between Production Budget and Box Office Gross:
SELECT 
    (
        SUM((budget - budget_mean) * (gross - gross_mean)) /
        (SQRT(SUM(POW(budget - budget_mean, 2)) * SUM(POW(gross - gross_mean, 2))))
    ) AS correlation
FROM (
    SELECT 
        AVG(budget) AS budget_mean,
        AVG(gross) AS gross_mean
    FROM movies_data.movie_metadata
) AS mean_values,
movies_data.movie_metadata;

-- Relationship between Aspect Ratio and IMDb Score:
SELECT 
    aspect_ratio,
    AVG(imdb_score) AS avg_imdb_score
FROM 
    movies_data.movie_metadata
GROUP BY 
    aspect_ratio;
    
  --  Evolution of Average IMDb Score Over the Years:
  SELECT 
    title_year,
    AVG(imdb_score) AS avg_imdb_score
FROM 
    movies_data.movie_metadata
GROUP BY 
    title_year
ORDER BY 
    title_year;
    
   -- Trends in Content Rating Distribution Over the Years:
   SELECT 
    title_year,
    content_rating,
    COUNT(*) AS count
FROM 
    movies_data.movie_metadata
GROUP BY 
    title_year, 
    content_rating
ORDER BY 
    title_year, 
    count DESC;
    
  --  Most Common Languages in the Dataset:
  SELECT 
    language,
    COUNT(*) AS language_count
FROM 
    movies_data.movie_metadata
GROUP BY 
    language
ORDER BY 
    language_count DESC;
    
  --  Distribution of IMDb Scores Across Different Countries:
  SELECT 
    country,
    AVG(imdb_score) AS avg_imdb_score,
    COUNT(*) AS movie_count
FROM 
    movies_data.movie_metadata
GROUP BY 
    country
ORDER BY 
    avg_imdb_score DESC;
    
 -- Correlation between Genre and Director:
SELECT 
    director_name,
    genres,
    AVG(imdb_score) AS avg_imdb_score
FROM 
    movies_data.movie_metadata
GROUP BY 
    director_name,
    genres
ORDER BY 
    avg_imdb_score DESC;
    
  --  Relationship between Actor and Language:
  SELECT 
    actor_1_name,
    language,
    AVG(imdb_score) AS avg_imdb_score
FROM 
    movies_data.movie_metadata
GROUP BY 
    actor_1_name,
    language
ORDER BY 
    avg_imdb_score DESC;


















