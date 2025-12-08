// --- Imports ---
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('./db');

// --- App Initialization ---
const app = express();
const PORT = process.env.PORT || 5000;

// --- Middleware ---
app.use(cors());
app.use(express.json()); // Middleware to parse JSON bodies

// --- Authentication Middleware (Security Guard) ---
const isResearcher = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) {
        return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (decoded.role !== 'researcher') {
            return res.status(403).json({ message: 'Access forbidden. Researcher access required.' });
        }
        req.user = decoded;
        next();
    } catch (err) {
        res.status(400).json({ message: 'Invalid token.' });
    }
};


//============================================
// --- AUTHENTICATION ENDPOINTS ---
//============================================

app.post('/api/auth/register', async (req, res) => {
    try {
        const { username, password, role } = req.body;
        if (!username || !password || !role) {
            return res.status(400).json({ message: 'Username, password, and role are required.' });
        }

        const salt = await bcrypt.genSalt(10);
        const password_hash = await bcrypt.hash(password, salt);

        const newUserQuery = `INSERT INTO Users (username, password_hash, role) VALUES ($1, $2, $3) RETURNING user_id, username, role;`;
        const newUser = await db.query(newUserQuery, [username, password_hash, role]);
        res.status(201).json(newUser.rows[0]);
    } catch (err) {
        console.error("Error registering user:", err.message);
        res.status(500).send('Server Error');
    }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        const result = await db.query('SELECT * FROM Users WHERE username = $1', [username]);
        const user = result.rows[0];
        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials.' });
        }

        const isValid = await bcrypt.compare(password, user.password_hash);
        if (!isValid) {
            return res.status(400).json({ message: 'Invalid credentials.' });
        }

        const token = jwt.sign(
            { userId: user.user_id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );
        res.json({ token });
    } catch (err) {
        console.error("Error logging in:", err.message);
        res.status(500).send('Server Error');
    }
});


//============================================
// --- PUBLIC ENDPOINTS (For All Users) ---
//============================================

app.get('/api/stars', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM stars ORDER BY star_name');
        res.status(200).json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/stars/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const starPromise = db.query('SELECT * FROM stars WHERE star_id = $1', [id]);
        const planetsPromise = db.query('SELECT * FROM planets WHERE star_id = $1', [id]);
        const [starResult, planetResult] = await Promise.all([starPromise, planetsPromise]);
        
        if (starResult.rows.length === 0) return res.status(404).json({ message: 'Star not found' });
        
        res.status(200).json({ star: starResult.rows[0], planets: planetResult.rows });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/planets/:id/observations', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await db.query('SELECT * FROM observations WHERE planet_id = $1', [id]);
        res.status(200).json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});


//==================================================
// --- PROTECTED ENDPOINTS (For Researchers Only) ---
//==================================================

// UPDATED to handle all required fields
app.post('/api/stars', isResearcher, async (req, res) => {
    try {
        const { star_name, distance_ly, effective_temperature_k, spectral_type, luminosity, radius_solar } = req.body;

        if (!star_name || !luminosity || !distance_ly) {
            return res.status(400).json({ message: 'Star name, luminosity, and distance are required.' });
        }

        const newStarQuery = `
            INSERT INTO stars (star_name, distance_ly, effective_temperature_k, spectral_type, luminosity, radius_solar) 
            VALUES ($1, $2, $3, $4, $5, $6) 
            RETURNING *; 
        `;
        
        const newStar = await db.query(newStarQuery, [star_name, distance_ly, effective_temperature_k, spectral_type, luminosity, radius_solar]);
        res.status(201).json(newStar.rows[0]);
    } catch (err) { 
        console.error("Error creating star:", err.message);
        res.status(500).json({ error: err.message }); 
    }
});

app.post('/api/planets', isResearcher, async (req, res) => {
    try {
        // Updated to accept all fields from the frontend form
        const { star_id, planet_name, planet_type, planet_radius_earth, angular_separation_arcsec } = req.body;

        // Validation to ensure required fields are present
        if (!star_id || !planet_name || !planet_type || !planet_radius_earth || !angular_separation_arcsec) {
            return res.status(400).json({ message: 'All fields are required to add a planet.' });
        }

        // The INSERT query now includes all the necessary columns
        const newPlanetQuery = `
            INSERT INTO planets (star_id, planet_name, planet_type, planet_radius_earth, angular_separation_arcsec, discovery_method, discovery_date) 
            VALUES ($1, $2, $3, $4, $5, 'User Submission', CURRENT_DATE) 
            RETURNING *;
        `;

        const newPlanet = await db.query(newPlanetQuery, [star_id, planet_name, planet_type, parseFloat(planet_radius_earth), parseFloat(angular_separation_arcsec)]);

        // The database trigger will automatically create the observation.
        res.status(201).json(newPlanet.rows[0]);
    } catch (err) { 
        console.error("Error creating planet:", err.message);
        res.status(500).json({ error: 'Server error while creating planet.' }); 
    }
});

app.post('/api/planets/:id/calculate', isResearcher, async (req, res) => {
    try {
        const { id } = req.params;
        const researcherId = req.user.userId;

        const dataQuery = `SELECT p.angular_separation_arcsec, s.distance_ly, s.luminosity FROM planets p JOIN stars s ON p.star_id = s.star_id WHERE p.planet_id = $1;`;
        const dataResult = await db.query(dataQuery, [id]);
        if (dataResult.rows.length === 0) return res.status(404).json({ message: 'Planet not found.' });
        
        const data = dataResult.rows[0];
        const distance_parsecs = data.distance_ly / 3.26156;
        const orbital_distance_au = (distance_parsecs * data.angular_separation_arcsec).toFixed(4);
        const inner_hz = Math.sqrt(data.luminosity / 1.1);
        const outer_hz = Math.sqrt(data.luminosity / 0.53);
        let habitability_classification = 'Outside HZ';
        if (orbital_distance_au >= inner_hz && orbital_distance_au <= outer_hz) {
            habitability_classification = 'Inside HZ';
        }
        
        const saveResultQuery = `INSERT INTO observations (planet_id, observation_date, orbital_distance_au, habitability_classification, user_id) VALUES ($1, CURRENT_DATE, $2, $3, $4) RETURNING *;`;
        const savedResult = await db.query(saveResultQuery, [id, orbital_distance_au, habitability_classification, researcherId]);
        res.status(201).json(savedResult.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});


// --- Server Startup ---
app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
});

