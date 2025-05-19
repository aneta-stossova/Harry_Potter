-- -----------------------------------------------------------
-- Script: Create table hp_final.dim_character
-- Description: Dimension of Harry Potter characters for data mart.
-- Contains key information like names, house affiliation, patronus, etc.
-- -----------------------------------------------------------

-- Drop the table if it exists
DROP TABLE IF EXISTS hp_final.dim_character;

-- Create table with house name as text first
CREATE TABLE IF NOT EXISTS hp_final.dim_character (
    id_character INT PRIMARY KEY,
    name VARCHAR NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    nickname VARCHAR,
	species VARCHAR,
    gender VARCHAR,
    house VARCHAR,
    isgood BOOLEAN,
    ismain BOOLEAN,
    patronus VARCHAR,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert dummy record for "unknown" characters
INSERT INTO hp_final.dim_character (
    id_character, name, first_name, last_name, nickname, species, gender, house, isgood, ismain, patronus
)
VALUES (
    -1, 'unknown', 'unknown', 'unknown', 'unknown', 'unknown', 'unknown', 'unknown', FALSE, FALSE, 'unknown'
);

-- Populate table from raw_data.character
INSERT INTO hp_final.dim_character (
    id_character, name, first_name, last_name, nickname, species, gender, house, isgood, ismain, patronus, inserted_at, updated_at
)
SELECT 
    character_id,
    character_name AS name,
    split_part(character_name, ' ', 1) AS first_name,
    NULLIF(trim(substring(character_name from position(' ' in character_name) + 1)), '') AS last_name,
    NULL AS nickname,
	species,
    gender,
    house,
    NULL AS isgood,
    NULL AS ismain,
    patronus,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM raw_data.characters;

-- Set house to '-1' where missing or empty
UPDATE hp_final.dim_character
SET house = '-1'
WHERE house IS NULL OR trim(house) = '';

-- Update house column by mapping house names to house IDs from dim_house
UPDATE hp_final.dim_character AS ch
SET house = h.id_house::TEXT
FROM hp_final.dim_house AS h
WHERE ch.house = h.house_name;

-- Change column house to id_house and change type to INT
ALTER TABLE hp_final.dim_character
RENAME COLUMN house TO id_house;

ALTER TABLE hp_final.dim_character
ALTER COLUMN id_house TYPE INT USING id_house::INT;

ALTER TABLE hp_final.dim_character
ADD CONSTRAINT fk_character_house
FOREIGN KEY (id_house)
REFERENCES hp_final.dim_house (id_house);

-- Set nickname based on rules
UPDATE hp_final.dim_character
SET nickname = CASE
    WHEN last_name IN ('Hagrid', 'Snape', 'McGonagall', 'Lupin', 'Moody', 'Umbridge', 'Lockhart', 'Filch',
                       'Trelawney', 'Quirrell', 'Ollivander', 'Pettigrew', 'Karkaroff', 'Maxime', 'Fudge',
                       'Crouch Sr.', 'Greyback', 'Burbage', 'Slughorne', 'Flitwick', 'Yaxley', 'Bones',
                       'Wood', 'Crabbe', 'Flint', 'Grindelwald', 'Goyle', 'Krum', 'Gregorovitch')
         OR name = 'Albus Dumbledore' THEN last_name
    WHEN name = 'Serpent of Slitherin' THEN 'Basilisk'
    WHEN name IN ('Rolanda Hooch', 'Poppy Pomfrey', 'Pomona Sprout') THEN 'Madame ' || split_part(name, ' ', 2)
    WHEN name = 'Arabella Figg' THEN 'Mrs. Figg'
    WHEN name IN ('Mrs. Cole', 'Mrs. Granger', 'Mr. Granger', 'Tom Riddle', 'Nearly Headless Nick', 'Helena Ravenclaw', 'Bloody Baron', 'The Fat Lady') THEN name
    ELSE first_name
END;

-- Set isgood, ismain, and patronus fields in a single step
UPDATE hp_final.dim_character
SET 
    isgood = CASE
        WHEN nickname IN ('Snape', 'Umbridge', 'Filch', 'Quirrell', 'Pettigrew', 'Voldemort', 'Fudge', 'Bellatrix',
                           'Barty', 'Riddle', 'Scabior', 'Crabbe', 'Goyle', 'Basilisk', 'Karkaroff', 'Rita',
                           'Mundungus', 'Parkinson', 'Greyback', 'Griphook', 'Aragog', 'Pius', 'Tom Riddle',
                           'Yaxley', 'Flint', 'Pansy', 'Blaise', 'Alecto', 'Death')
            OR last_name IN ('Malfoy', 'Dursley') THEN FALSE
        ELSE TRUE
    END,
    ismain = CASE
        WHEN nickname IN ('Harry', 'Ron', 'Hermione', 'Dumbledore', 'Hagrid', 'Snape', 'McGonagall', 'Voldemort',
                           'Neville', 'Draco', 'Sirius', 'Luna', 'Dobby', 'Ginny', 'Molly', 'Arthur',
                           'Lupin', 'Moody', 'Bellatrix', 'Lucius') THEN TRUE
        ELSE FALSE
    END,
    patronus = CASE
        WHEN patronus IS NULL OR patronus = '' THEN 'unknown'
        ELSE patronus
    END;

-- Correct gender values
UPDATE hp_final.dim_character
SET gender = CASE
    WHEN name = 'Nearly Headless Nick' THEN 'Male'
    WHEN nickname IN ('Goblin', 'Snatcher', 'Wizard', 'Centaur', 'Waiter', 'Man', 'Boy', 'Old man', 'Station guard') THEN 'Male'
    WHEN nickname IN ('Girl', 'Woman', 'Waitress', 'Witch') OR last_name = 'Fat Lady'
         OR name = 'Trolley witch' THEN 'Female'
    WHEN name = 'Man in a painting' OR name = 'Boy 2' THEN 'Male'
    WHEN gender IS NULL OR gender = '' THEN 'Unknown'
    ELSE gender
END;

-- -----------------------------------------------------------
-- Insert missing characters and creatures into hp_final.dim_character
-- These are known from screen_time or other context but missing in the dimension table.
-- -----------------------------------------------------------

INSERT INTO hp_final.dim_character (
    id_character, name, first_name, last_name, nickname, species, gender, id_house, isgood, ismain, patronus, inserted_at, updated_at
)
VALUES 
-- Magical creatures
(200, 'Buckbeak', 'Buckbeak', NULL, 'Buckbeak', 'Hippogriff', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(201, 'Fawkes', 'Fawkes', NULL, 'Fawkes', 'Phoenix', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(202, 'Hedwig', 'Hedwig', NULL, 'Hedwig', 'Owl', 'Female', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(203, 'Nagini', 'Nagini', NULL, 'Nagini', 'Snake', 'Female', -1, FALSE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(204, 'Fang', 'Fang', NULL, 'Fang', 'Dog', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(205, 'Kreacher', 'Kreacher', NULL, 'Kreacher', 'House-elf', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(210, 'Crookshanks', 'Crookshanks', NULL, 'Crookshanks', 'Cat', 'Unknown', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Human characters
(206, 'Gabrielle Delacour', 'Gabrielle', 'Delacour', 'Gabrielle Delacour', 'Human', 'Female', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(207, 'Frank Bryce', 'Frank', 'Bryce', 'Frank Bryce', 'Human', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(209, 'Ernie Prang', 'Ernie', 'Prang', 'Ernie', 'Human', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(211, 'Romilda Vane', 'Romilda', 'Vane', 'Romilda', 'Human', 'Female', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(212, 'Reginald Cattermole', 'Reginald', 'Cattermole', 'Reginald Cattermole', 'Human', 'Male', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(213, 'Amycus Carrow', 'Amycus', 'Carrow', 'Amycus', 'Human', 'Male', -1, FALSE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(214, 'Alicia Spinnet', 'Alicia', 'Spinnet', 'Alicia', 'Human', 'Female', -1, TRUE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(215, 'Albert Runcorn', 'Albert', 'Runcorn', 'Albert', 'Human', 'Male', -1, FALSE, FALSE, 'unknown', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
