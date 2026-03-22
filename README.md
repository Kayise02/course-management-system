# Honours Course Management System

A full-stack web application for managing BSc Honours Computer Science students, supervisors, and modules. Built with Java/JSP, MySQL, and deployed on Render with Docker.

![Java](https://img.shields.io/badge/Java-21-orange) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue) ![Tomcat](https://img.shields.io/badge/Tomcat-11.0-yellow) ![Docker](https://img.shields.io/badge/Docker-enabled-blue) ![Render](https://img.shields.io/badge/Deployed-Render-purple)

---

## Live Demo

🌐 **[https://course-management-system-93x5.onrender.com](https://course-management-system-93x5.onrender.com)**

> Note: The free tier spins down after inactivity — first load may take 30–50 seconds.

### Demo Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Supervisor | `thabo.nkosi` | `password123` |
| Student | `koketso.mengwai` | `password123` |

---

## About the Project

This system was built to manage the BSc Honours Computer Science programme at university level, handling:

- **12 Honours students** across 5 specialised CS modules
- **6 supervisors** each assigned to specific modules and students
- **5 Honours modules** covering AI/ML, Cybersecurity, Distributed Systems, Software Engineering, and Advanced Algorithms
- Role-based access control for admins, supervisors, and students

---

## Features

### Admin
- Full user management — create, edit, delete users
- Module management with student capacity control
- Manual student enrolment into modules
- System-wide dashboard showing total users, modules, supervisors and students

### Supervisor
- View assigned Honours modules and supervision load
- Track students per module
- Quick access to grading, course materials and announcements

### Student
- View enrolled Honours modules and credits
- Self-enrol into available modules
- Track academic progress per semester

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java 21, JSP, Servlets |
| Server | Apache Tomcat 11.0 |
| Database | MySQL 8.0 (Aiven Cloud) |
| Security | BCrypt password hashing, session management |
| Build Tool | Apache Maven |
| Container | Docker |
| Hosting | Render.com (free tier) |
| Version Control | Git / GitHub |

---

## Honours Modules

| Code | Module | Supervisor | Schedule |
|------|--------|-----------|----------|
| HON701 | Machine Learning & AI | Thabo Nkosi | Mon/Wed 08:00–10:00 |
| HON702 | Cybersecurity & Cryptography | Zanele Dlamini | Tue/Thu 10:00–12:00 |
| HON703 | Distributed Systems | Sipho Ndlovu | Mon/Wed 12:00–14:00 |
| HON704 | Software Engineering & Web Dev | Nomsa Khumalo | Tue/Thu 14:00–16:00 |
| HON705 | Advanced Algorithms | Lungelo Zulu | Fri 08:00–12:00 |

---

## Project Structure

```
Course Management System/
├── src/
│   └── main/
│       ├── java/com/cms/
│       │   ├── controller/     # Servlets (AuthServlet)
│       │   ├── dao/            # Database access (UserDAO, CourseDAO)
│       │   ├── model/          # Java models (User, Course)
│       │   └── util/           # Database connection
│       └── webapp/
│           ├── pages/
│           │   ├── admin/      # Admin JSP pages
│           │   ├── instructor/ # Supervisor JSP pages
│           │   └── student/    # Student JSP pages
│           └── WEB-INF/
├── Dockerfile                  # Docker configuration
├── server.xml                  # Tomcat server config
├── pom.xml                     # Maven dependencies
└── seed_honours.sql            # Database seed data
```

---

## Running Locally

### Prerequisites

- Java JDK 21+
- Apache Maven 3.9+
- Apache Tomcat 11.0
- MySQL 8.0

### Step 1 — Clone the repository

```bash
git clone https://github.com/Kayise02/course-management-system.git
cd course-management-system
```

### Step 2 — Set up the database

Start MySQL and run the seed file:

```sql
mysql -u root -p
source seed_honours.sql
```

### Step 3 — Configure database credentials

Set environment variables before starting Tomcat:

```
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
DB_URL=jdbc:mysql://localhost:3306/defaultdb?useSSL=false&serverTimezone=UTC
```

### Step 4 — Build the project

```bash
mvn clean package
```

### Step 5 — Deploy to Tomcat

Copy the WAR file to your Tomcat webapps folder and start Tomcat:

```bash
copy target\CourseManagementSystem.war "C:\Program Files\Apache Software Foundation\Tomcat 11.0\webapps\"
```

### Step 6 — Access the app

```
http://localhost:8080/pages/login.jsp
```

---

## Running with Docker

```bash
docker build -t honours-cms .
docker run -p 8080:8080 \
  -e DB_USERNAME=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_URL=your_database_url \
  honours-cms
```

---

## Author

**Ntombikayise** — [@Kayise02](https://github.com/Kayise02)

BSc Honours Computer Science

---

## License

This project is open source and available under the [MIT License](LICENSE).
