-- Fix incorrect place references in fact_spell table
-- -----------------------------------------------------------
-- Script: Create hp_final.fact_spell
-- Description: Fact table tracking spell usage in dialogues.
-- Includes spell frequency and linkage to character, place, scene, and dialogue.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.fact_spell;

-- Create fact table for spells
CREATE TABLE IF NOT EXISTS hp_final.fact_spell (
    id_spell INT REFERENCES hp_final.dim_spell(id_spell),
    id_character INT REFERENCES hp_final.dim_character(id_character),
    id_place INT REFERENCES hp_final.dim_place(id_place),
    id_dialogue INT REFERENCES raw_data.dialogues(dialogue_id),
    id_scene INT REFERENCES hp_final.dim_scene(id_scene),
    spell_frequency INT,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Insert data by matching incantations in dialogue text
INSERT INTO hp_final.fact_spell (
    id_spell, id_character, id_place, id_dialogue, id_scene, spell_frequency
)
SELECT 
    COALESCE(s.id_spell, -1), 
    COALESCE(c.id_character, -1), 
    COALESCE(p.id_place, -1), 
    COALESCE(d.dialogue_id, -1), 
    COALESCE(d.chapter_id, -1), 
    COUNT(*) AS spell_frequency
FROM raw_data.dialogues d
INNER JOIN hp_final.dim_character c ON d.character_id = c.id_character
INNER JOIN hp_final.dim_place p ON d.place_id = p.id_place
INNER JOIN hp_final.dim_spell s ON LOWER(d.dialogue) LIKE CONCAT('%', LOWER(s.incantation), '%')
GROUP BY s.id_spell, c.id_character, p.id_place, d.dialogue_id, d.chapter_id;

-- Updating id_place
UPDATE hp_final.fact_spell
SET id_place = CASE
    WHEN id_place = 74 THEN 68
    ELSE id_place
END;