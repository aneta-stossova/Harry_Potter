-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_spell
-- Description: Dimension table for spells from the Harry Potter universe.
-- Includes spell ID, incantation (magic word), and spell name.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_spell;

-- Create table with primary key
CREATE TABLE IF NOT EXISTS hp_final.dim_spell (
    id_spell INT PRIMARY KEY,
    incantation VARCHAR,
    spell_name VARCHAR,
	effect VARCHAR,
	light VARCHAR,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" spells
INSERT INTO hp_final.dim_spell (
    id_spell, incantation, spell_name, effect, light
)
VALUES (
    -1, 'unknown', 'unknown', 'unknown', 'unknown'
);

-- Populate the table from raw_data.spells, excluding invalid incantations
INSERT INTO hp_final.dim_spell (
    id_spell, incantation, spell_name, effect, light, inserted_at, updated_at
)
SELECT 
    spell_id,
    incantation,
    spell_name,
	effect,
    CASE
        WHEN light IS NULL THEN 'unknown'
        ELSE light
    END AS light,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.spells;