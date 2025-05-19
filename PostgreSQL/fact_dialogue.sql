-- -----------------------------------------------------------
-- Script: Create table hp_final.fact_dialogue
-- Description: Final fact table for dialogue analysis.
-- Includes character, scene, place, dialogue ID, dialogue length,
-- love word count and results of sentiment analysis (Afinn).
-- NRC sentiment is modeled separately via bridge_dialogue_emolex.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.fact_dialogue;

-- Create final fact table
CREATE TABLE IF NOT EXISTS hp_final.fact_dialogue (
    id_dialogue INT PRIMARY KEY,
    id_character INT REFERENCES hp_final.dim_character(id_character),
    id_scene INT REFERENCES hp_final.dim_scene(id_scene),
    id_place INT REFERENCES hp_final.dim_place(id_place),
    sentiment_afinn DECIMAL,
    dialogue_length INT,
    love_count INT,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);