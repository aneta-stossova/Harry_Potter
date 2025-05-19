-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_house
-- Description: Dimension table for Hogwarts houses.
-- Includes house IDs, names, and timestamps for record tracking.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_house;

-- Create table with primary key
CREATE TABLE IF NOT EXISTS hp_final.dim_house (
    id_house INT PRIMARY KEY,
    house_name VARCHAR NOT NULL,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" house
INSERT INTO hp_final.dim_house (id_house, house_name)
VALUES (-1, 'unknown');

-- Populate the table from raw_data.house
INSERT INTO hp_final.dim_house (id_house, house_name, inserted_at, updated_at)
SELECT 
    house_id,
    house,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.house;