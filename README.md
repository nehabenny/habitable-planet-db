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

##  System Architecture

The application follows a classic **Three-Tier Architecture** to ensure scalability and separation of concerns.

> **[Insert your Architecture Diagram image here]**
> *Data flows from the Client (HTML/CSS) -> Server (Node.js) -> Database (PostgreSQL).*

### Database Schema
Our relational database is normalized to handle complex astronomical relationships efficiently.

> **[Insert your ER Diagram image here]**
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

1. **Clone the Repository**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/celestial-voyager-db.git](https://github.com/YOUR_USERNAME/celestial-voyager-db.git)
   cd celestial-voyager-db