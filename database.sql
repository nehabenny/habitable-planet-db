-- 1. CLEANUP (Reset database to start fresh)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- 2. CREATE TABLES

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('researcher', 'viewer'))
);

CREATE TABLE stars (
    star_id SERIAL PRIMARY KEY,
    star_name VARCHAR(255) NOT NULL,
    distance_ly FLOAT NOT NULL,
    spectral_type VARCHAR(50),
    luminosity FLOAT NOT NULL
);

CREATE TABLE planets (
    planet_id SERIAL PRIMARY KEY,
    star_id INTEGER REFERENCES stars(star_id) ON DELETE CASCADE,
    planet_name VARCHAR(255) NOT NULL,
    planet_type VARCHAR(50) NOT NULL,
    angular_separation_arcsec FLOAT,
    UNIQUE(star_id, planet_name)
);

CREATE TABLE observations (
    observation_id SERIAL PRIMARY KEY,
    planet_id INTEGER REFERENCES planets(planet_id) ON DELETE CASCADE,
    observation_date DATE DEFAULT CURRENT_DATE,
    orbital_distance_au FLOAT,
    
    -- We keep the text classification AND add the percentage score
    habitability_classification VARCHAR(50), 
    habitability_score FLOAT DEFAULT 0.0, 
    
    angular_separation_as FLOAT,
    user_id INTEGER REFERENCES Users(user_id),
    UNIQUE(planet_id, observation_date)
);


-- ========================================================
-- 3. THE "BRAIN" (ADVANCED HABITABILITY ALGORITHM)
-- ========================================================

CREATE OR REPLACE FUNCTION calculate_habitability()
RETURNS TRIGGER AS $$
DECLARE
    star_lum FLOAT;
    sqrt_lum FLOAT;
    inner_hz FLOAT;
    outer_hz FLOAT;
    hz_center FLOAT;
    hz_radius FLOAT;
    dist_from_center FLOAT;
BEGIN
    -- 1. Get the luminosity of the star
    SELECT s.luminosity INTO star_lum
    FROM stars s
    JOIN planets p ON p.star_id = s.star_id
    WHERE p.planet_id = NEW.planet_id;

    IF star_lum IS NOT NULL AND NEW.orbital_distance_au IS NOT NULL THEN
        -- 2. Define the Habitable Zone (HZ) boundaries
        sqrt_lum := SQRT(star_lum);
        inner_hz := 0.95 * sqrt_lum; -- Inner edge (Hot)
        outer_hz := 1.70 * sqrt_lum; -- Outer edge (Cold)

        -- 3. Determine Text Classification
        IF NEW.orbital_distance_au >= inner_hz AND NEW.orbital_distance_au <= outer_hz THEN
            NEW.habitability_classification := 'Inside HZ';
        ELSIF NEW.orbital_distance_au < inner_hz THEN
            NEW.habitability_classification := 'Too Hot';
        ELSE
            NEW.habitability_classification := 'Too Cold';
        END IF;

        -- 4. Calculate Percentage Score (The "Perfect Center" Logic)
        --    - Center of HZ = 100% Score
        --    - Edges of HZ = 0% Score
        --    - Outside HZ = 0% Score
        
        hz_center := (inner_hz + outer_hz) / 2;
        hz_radius := (outer_hz - inner_hz) / 2;
        dist_from_center := ABS(NEW.orbital_distance_au - hz_center);

        IF dist_from_center >= hz_radius THEN
            -- Planet is outside the zone
            NEW.habitability_score := 0.0;
        ELSE
            -- Planet is inside: Calculate score based on proximity to center
            -- Formula: 100 * (1 - (distance_from_center / radius))
            NEW.habitability_score := 100.0 * (1.0 - (dist_from_center / hz_radius));
            
            -- Round to 2 decimal places for neatness
            NEW.habitability_score := ROUND(NEW.habitability_score::numeric, 2);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Connect the Function to the Table
CREATE TRIGGER trigger_update_habitability
BEFORE INSERT OR UPDATE ON observations
FOR EACH ROW
EXECUTE FUNCTION calculate_habitability();

-- 4. SEED DATA (Insertions so the app isn't empty)

-- A. Create a Test Researcher (Password: 'password')
INSERT INTO Users (username, password_hash, role) 
VALUES ('testuser', '$2b$10$YourHashedPasswordHereOrJustUseRegister', 'researcher');

-- B. Create our Solar System (The Sun)
INSERT INTO stars (star_name, distance_ly, spectral_type, luminosity)
VALUES ('Sun', 0.00001581, 'G2V', 1.0);

-- C. Create Planets (Earth and Mars)
-- We need to grab the Sun's ID dynamically
DO $$
DECLARE
    sun_id INTEGER;
BEGIN
    SELECT star_id INTO sun_id FROM stars WHERE star_name = 'Sun';

    -- Earth
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (sun_id, 'Earth', 'Terrestrial', 0.0); -- 0 because we are ON it

    -- Mars
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (sun_id, 'Mars', 'Terrestrial', 0.5); -- Example value
END $$;

-- D. Create Observations (This triggers the calculation!)
DO $$
DECLARE
    earth_id INTEGER;
    mars_id INTEGER;
    user_id INTEGER;
BEGIN
    SELECT planet_id INTO earth_id FROM planets WHERE planet_name = 'Earth';
    SELECT planet_id INTO mars_id FROM planets WHERE planet_name = 'Mars';
    SELECT user_id INTO user_id FROM Users WHERE username = 'testuser';

    -- Insert Earth Observation (1.0 AU) -> Should become 'Inside HZ'
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (earth_id, 1.0, user_id);

    -- Insert Mars Observation (1.52 AU) -> Should become 'Inside HZ'
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (mars_id, 1.52, user_id);
END $$;

-- E. SEED DATA: Proxima Centauri (Closest Star)
INSERT INTO stars (star_name, distance_ly, spectral_type, luminosity)
VALUES ('Proxima Centauri', 4.2465, 'M5.5Ve', 0.0017);

-- F. SEED DATA: TRAPPIST-1 System (Famous for multiple Earth-like planets)
INSERT INTO stars (star_name, distance_ly, spectral_type, luminosity)
VALUES ('TRAPPIST-1', 39.46, 'M8V', 0.000553);

--other observations from the trappist-1 system
DO $$
DECLARE
    prox_id INTEGER;
    trap_id INTEGER;
    user_id INTEGER;
    
    -- Planet IDs to capture after insertion
    prox_b_id INTEGER;
    trap_e_id INTEGER;
    trap_f_id INTEGER;
    trap_b_id INTEGER;
BEGIN
    SELECT star_id INTO prox_id FROM stars WHERE star_name = 'Proxima Centauri';
    SELECT star_id INTO trap_id FROM stars WHERE star_name = 'TRAPPIST-1';
    SELECT user_id INTO user_id FROM Users WHERE username = 'testuser';

    -- 1. Proxima Centauri b (Potentially Habitable)
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (prox_id, 'Proxima Centauri b', 'Super Earth', 0.037)
    RETURNING planet_id INTO prox_b_id;

    -- 2. TRAPPIST-1 e (Habitable)
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (trap_id, 'TRAPPIST-1 e', 'Terrestrial', 0.028)
    RETURNING planet_id INTO trap_e_id;

    -- 3. TRAPPIST-1 f (Habitable)
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (trap_id, 'TRAPPIST-1 f', 'Terrestrial', 0.037)
    RETURNING planet_id INTO trap_f_id;

    -- 4. TRAPPIST-1 b (Too Hot)
    INSERT INTO planets (star_id, planet_name, planet_type, angular_separation_arcsec)
    VALUES (trap_id, 'TRAPPIST-1 b', 'Terrestrial', 0.011)
    RETURNING planet_id INTO trap_b_id;


    -- === INSERT OBSERVATIONS (Triggers the Calculation) ===

    -- Proxima b at 0.0485 AU
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (prox_b_id, 0.0485, user_id);

    -- TRAPPIST-1 e at 0.028 AU (Prime HZ)
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (trap_e_id, 0.028, user_id);
    
    -- TRAPPIST-1 f at 0.037 AU (Outer Edge of HZ)
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (trap_f_id, 0.037, user_id);

    -- TRAPPIST-1 b at 0.011 AU (Too Hot)
    INSERT INTO observations (planet_id, orbital_distance_au, user_id)
    VALUES (trap_b_id, 0.011, user_id);
    
END $$;