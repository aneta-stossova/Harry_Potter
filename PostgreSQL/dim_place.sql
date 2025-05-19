-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_place
-- Description: Dimension table for Harry Potter places.
-- Includes place ID, place name, and place category.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_place;

-- Create table with primary key
CREATE TABLE IF NOT EXISTS hp_final.dim_place (
    id_place INT PRIMARY KEY,
    place_name VARCHAR,
    place_category VARCHAR,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" places
INSERT INTO hp_final.dim_place (
    id_place, place_name, place_category
)
VALUES (-1, 'unknown', 'unknown');

-- Populate the table from raw_data.place
INSERT INTO hp_final.dim_place (
    id_place, place_name, place_category, inserted_at, updated_at
)
SELECT 
    place_id,
    place_name,
    place_category,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.place;