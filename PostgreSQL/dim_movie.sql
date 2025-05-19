-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_movie
-- Description: Dimension table for Harry Potter movies.
-- Includes movie ID, title, movie group (series grouping), runtime, and release year.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_movie;

-- Create table with primary key
CREATE TABLE IF NOT EXISTS hp_final.dim_movie (
	id_movie INT PRIMARY KEY,
	name VARCHAR,
	movie_group VARCHAR,
	runtime INT,
	release_year INT,
	inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" movies
INSERT INTO hp_final.dim_movie (id_movie, name, movie_group, runtime, release_year)
VALUES (-1, 'unknown', 'unknown', -1, 1111);

-- Populate the table from raw_data.movie
INSERT INTO hp_final.dim_movie (id_movie, name, movie_group, runtime, release_year, inserted_at, updated_at)
SELECT 
    movie_id AS id_movie,
    movie_title AS name,
    CASE 
        WHEN movie_title LIKE '%Part%' THEN REGEXP_REPLACE(movie_title, ' Part [12]', '')
        ELSE movie_title 
    END AS movie_group,
	release_year,
    runtime,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.movies;