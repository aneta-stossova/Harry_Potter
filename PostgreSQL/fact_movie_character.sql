-- -----------------------------------------------------------
-- Script: Create hp_final.fact_movie_character using CTE
-- Description: Calculates screen time in minutes from inconsistent formats
-- and generates a fact table linking characters to movies with screen share.
-- Uses a CTE (Common Table Expression) instead of a temporary table.
-- -----------------------------------------------------------

-- Drop final fact table if it exists
DROP TABLE IF EXISTS hp_final.fact_movie_character;

-- Create fact table with character/movie links and screen time percentage
CREATE TABLE IF NOT EXISTS hp_final.fact_movie_character (
    id_movie INT,
    id_character INT,
    screen_time_min FLOAT,
    screen_time_percentage FLOAT,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_movie) REFERENCES hp_final.dim_movie(id_movie),
    FOREIGN KEY (id_character) REFERENCES hp_final.dim_character(id_character)
);

-- Use CTE to compute screen time in minutes
WITH screen_time_min AS (
    SELECT 
        movie AS movie_name,
        character AS character_name,
        CASE 
            WHEN LENGTH(screen_time) - LENGTH(REPLACE(screen_time, ':', '')) = 2 THEN
                COALESCE(NULLIF(SPLIT_PART(screen_time, ':', 1), '')::INT, 0) +           -- Minutes
                COALESCE(NULLIF(SPLIT_PART(screen_time, ':', 2), '')::INT, 0) / 60.0 +    -- Seconds to minutes
                COALESCE(NULLIF(SPLIT_PART(screen_time, ':', 3), '')::INT, 0) / 60000.0   -- Milliseconds to minutes
            WHEN LENGTH(screen_time) - LENGTH(REPLACE(screen_time, ':', '')) = 1 THEN
                COALESCE(NULLIF(SPLIT_PART(screen_time, ':', 1), '')::INT, 0) + 
                COALESCE(NULLIF(SPLIT_PART(screen_time, ':', 2), '')::INT, 0) / 60.0
            WHEN LENGTH(screen_time) - LENGTH(REPLACE(screen_time, ':', '')) = 0 THEN
                COALESCE(NULLIF(screen_time, '')::INT, 0)
            ELSE 0
        END AS screen_time_min
    FROM raw_data.screen_time
)
-- Insert data into the final fact table
INSERT INTO hp_final.fact_movie_character (
    id_movie, id_character, screen_time_min, screen_time_percentage
)
SELECT
    COALESCE(m.id_movie, -1),
    COALESCE(
        CASE
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Mr. Ollivander' THEN 43
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'The Sorting Hat' THEN 128
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Madame Hooch' THEN 50
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Sir Nicholas "Nearly-Headless Nick"' THEN 47
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Fat Lady' THEN 141
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Colin Creevy' THEN 106
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Madame Poppy Pomfrey' THEN 85
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Professor Sybil Trelawney' THEN 38
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Stan Shunpike' THEN 58
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Madame Rosmerta' THEN 66
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Bartemius Crouch Jr.' THEN 89
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Bartemius Crouch Sr.' THEN 33
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Madame Olympe Maxime' THEN 69
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Alastor "Mad-Eye" Moody' THEN 13
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Nigel' THEN 111
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Yaxley' THEN 70
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Auntie Muriel' THEN 77
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Gregorovitch' THEN 125
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Albus Severus Potter' THEN 84
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Scabbers / Peter Pettigrew' THEN 44
            WHEN c.id_character IS NULL AND TRIM(s.character_name) = 'Tom Riddle / Voldemort' THEN 24
            ELSE c.id_character
        END, -1
    ) AS id_character,
    s.screen_time_min,
    ROUND((s.screen_time_min / m.runtime) * 100, 2) AS screen_time_percentage
FROM screen_time_min AS s
LEFT JOIN hp_final.dim_character AS c 
    ON c.name = CASE
        WHEN TRIM(s.character_name) LIKE 'Professor%' THEN REPLACE(TRIM(s.character_name), 'Professor ', '')
        WHEN TRIM(s.character_name) = 'Gregorovitch' THEN 'Mykew Gregorovitch'
        ELSE TRIM(s.character_name)
    END
LEFT JOIN hp_final.dim_movie AS m
    ON m.name = CASE
        WHEN s.movie_name = 'Harry Potter and the Sorcerer''s Stone' THEN 'Harry Potter and the Philosopher''s Stone'
        WHEN s.movie_name LIKE 'Harry Potter and the Deathly Hallows: Part%' THEN REPLACE(s.movie_name, ':', '')
        ELSE s.movie_name
    END;