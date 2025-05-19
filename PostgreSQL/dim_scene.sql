-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_scene
-- Description: Dimension table for Harry Potter scenes (chapters).
-- Includes scene ID, scene name, associated movie ID, and timestamps.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_scene;

-- Create table with primary key and foreign key to dim_movie
CREATE TABLE IF NOT EXISTS hp_final.dim_scene (
    id_scene INT PRIMARY KEY,
    scene_name VARCHAR,
    id_movie INT REFERENCES hp_final.dim_movie(id_movie),
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" scenes
INSERT INTO hp_final.dim_scene (
    id_scene, scene_name, id_movie
)
VALUES (
    -1, 'unknown', -1
);

-- Populate the table from raw_data.chapter
INSERT INTO hp_final.dim_scene (
    id_scene, scene_name, id_movie, inserted_at, updated_at
)
SELECT 
    chapter_id,
    chapter_name,
    movie_id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.chapters;