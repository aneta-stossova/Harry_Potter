-- -----------------------------------------------------------
-- Script: Create hp_final.bridge_dialogue_emolex
-- Description: Bridge table linking dialogue lines to emotion categories.
-- Each combination of dialogue and emotion is unique.
-- Includes score and frequency of emotion occurrence.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.bridge_dialogue_emolex;

-- Create bridge table with composite primary key and foreign keys
CREATE TABLE IF NOT EXISTS hp_final.bridge_dialogue_emolex (
    id_dialogue INT,
    id_emolex INT,
    score INT,
    score_frequency DECIMAL,
    PRIMARY KEY (id_dialogue, id_emolex),
    FOREIGN KEY (id_dialogue) REFERENCES hp_final.fact_dialogue(id_dialogue),
    FOREIGN KEY (id_emolex) REFERENCES hp_final.dim_emolex(id_emolex)
);

-- Insert dummy record for unknown linkage (optional)
INSERT INTO hp_final.bridge_dialogue_emolex (
    id_dialogue, id_emolex, score, score_frequency
)
VALUES (
    -1, -1, -1, -1.000
);