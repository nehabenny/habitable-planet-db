<div align="center">

# Celestial Voyager.
### An Interactive Habitable Planet Database System

![NodeJS](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=nodedotjs)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql)
![Express](https://img.shields.io/badge/Express.js-4.x-000000?style=for-the-badge&logo=express)
![Status](https://img.shields.io/badge/Status-Active_Development-success?style=for-the-badge)

<p align="center">
  <a href="#-about">About</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-system-architecture">Architecture</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a>
</p>

</div>

---

## About
**Celestial Voyager** is a full-stack web application designed to bridge the gap between complex astronomical data and public curiosity. It serves as a centralized, interactive platform where users can explore the cosmos, while researchers contribute vital data to the ongoing search for habitable worlds.

At its core, the system utilizes a custom **Habitability Algorithm** that dynamically classifies planets based on their star's luminosity and orbital distance, determining if they reside within the "Goldilocks Zone."

## Key Features

###  For Explorers (Regular Users)
- **Interactive Dashboard:** Navigate a visual library of stars and exoplanets.
- **Habitability Engine:** Instantly see if a planet is classified as "Inside HZ" (Habitable Zone) or "Outside HZ" based on real-time calculations.
- **Smart Search:** Filter celestial bodies by name, star system, or discovery method.
- **Solar System Integration:** Includes accurate, pre-calculated data for our own solar system (Mercury through Neptune).

###  For Researchers (Admin)
- **Data Contribution:** Secure interface to add, edit, or update planet and star data.
- **Automated Calculations:** Database triggers automatically compute orbital distance (AU) and habitability status upon data entry.
- **Role-Based Access Control (RBAC):** Secure login ensures only verified researchers can modify the scientific database.

---
##  Gallery

<details>
<summary> Click to view screenshots</summary>

### 1. Interactive 3D Galaxy Map
Navigable 3D view of star systems using Three.js.
![Galaxy View](assets/screenshot_galaxy.png)

### 2. Planet Analysis & Habitability Score
Real-time calculation showing a planet's potential for life (e.g., TRAPPIST-1 e).
![Habitability Score](assets/screenshot_planet_score.png)

### 3. Researcher Dashboard
Secure admin panel for adding new celestial discoveries.
![Researcher Panel](assets/screenshot_researcher.png)

### 4. Interactive Planet Viewer
A real-time 3D visualization where users can explore planets and view calculated habitability scores.
![Planet Viewer](assets/screenshot_interactive_planet_viewer.png)

### 5. Secure Login & Registration
Role-based authentication system ensuring secure access for Researchers.
![Login Screen](assets/screenshot_login_or_signin.png)


</details>

---
##  System Architecture

The application follows a classic **Three-Tier Architecture** to ensure scalability and separation of concerns.

> ![Architecture Diagram](assets/architecture.png)
> *Data flows from the Client (HTML/CSS) -> Server (Node.js) -> Database (PostgreSQL).*

### Database Schema
Our relational database is normalized to handle complex astronomical relationships efficiently.

> ![ER Diagram](assets/er_diagram.png)
> *One Star has Many Planets; One Planet has One Observation.*

---

##  Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | ![HTML5](https://img.shields.io/badge/-HTML5-E34F26?logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/-CSS3-1572B6?logo=css3&logoColor=white) ![JS](https://img.shields.io/badge/-JavaScript-F7DF1E?logo=javascript&logoColor=black) | Responsive UI with vanilla JS for API consumption. |
| **Backend** | ![Nodejs](https://img.shields.io/badge/-Node.js-339933?logo=node.js&logoColor=white) ![Express](https://img.shields.io/badge/-Express-000000?logo=express&logoColor=white) | RESTful API handling logic and authentication. |
| **Database** | ![Postgres](https://img.shields.io/badge/-PostgreSQL-4169E1?logo=postgresql&logoColor=white) | Relational database with PL/pgSQL functions & triggers. |
| **Tools** | ![Postman](https://img.shields.io/badge/-Postman-FF6C37?logo=postman&logoColor=white) ![Drawio](https://img.shields.io/badge/-Draw.io-F08705?logo=diagrams.net&logoColor=white) | API Testing and System Design. |
| **Hosting** | ![Render](https://img.shields.io/badge/-Render-46E3B7?logo=render&logoColor=white) | Cloud deployment for backend and database. |

---

##  Getting Started

Follow these steps to run the project locally.

### Prerequisites
- Node.js installed
- PostgreSQL installed and running

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/nehabenny/celestial-voyager-db.git
    cd celestial-voyager-db
    ```

2.  **Install Dependencies**
    Navigate to the backend folder and install the required packages:
    ```bash
    cd main
    npm install
    ```

3.  **🗄️ Database Setup**
    * **Create the Database**: Open your terminal or pgAdmin and run:
        ```sql
        CREATE DATABASE habitable_planet_db_a9cz;
        ```
    * **Import the Schema**: Run the included `database.sql` file (located in the root folder) to create the tables.
        ```bash
        # If using terminal (navigate back to root first):
        cd ..
        psql -U postgres -d habitable_planet_db_a9cz -f database.sql
        ```

4.  **⚙️ Configuration (.env)**
    Create a `.env` file inside the `main` folder (or root, depending on your setup) and add:
    ```env
    PORT=5000
    DATABASE_URL="postgresql://postgres:your_password@localhost:5432/habitable_planet_db_a9cz"
    JWT_SECRET="your_secret_key_here"
    ```

5.  **Run the Application**
    ```bash
    # Inside the 'main' folder:
    node index.js
    ```
    Open your browser and go to `http://localhost:5000`.

---

##  Usage & Testing

To test the **Researcher (Admin)** features, use the default credentials provided in `database.sql`:

* **Username:** `testuser`
* **Password:** `password` (or register a new user)

---

## License & Academic Integrity

This project was created for the **Database Management System Course** at **Rajagiri School of Engineering and Technology**.

It is intended for educational purposes only. Please do not copy this code for your own coursework to avoid plagiarism.