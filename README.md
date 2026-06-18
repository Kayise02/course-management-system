# 📚 Course Management System

A full-stack web application for managing students, instructors, and modules. Built with Java/JSP, MySQL, and deployed on Render with Docker.

![Java](https://img.shields.io/badge/Java-21-orange) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue) ![Tomcat](https://img.shields.io/badge/Tomcat-11.0-yellow) ![Docker](https://img.shields.io/badge/Docker-✓-blue) ![Render](https://img.shields.io/badge/Render-Deployed-green)

---

## 🌐 Live Demo

**https://course-management-system-93x5.onrender.com**

> Note: The free tier spins down after inactivity — first load may take 30–50 seconds.

### Demo Credentials

| Role       | Username          | Password    |
|------------|-------------------|-------------|
| Admin      | admin             | admin123    |
| Instructor | thabo.nkosi       | password123 |
| Student    | koketso.mengwai   | password123 |

---

## 📌 About the Project

This system manages a university course programme, handling:

- Students across multiple modules
- Instructors assigned to specific modules and students
- Role-based access control for admins, instructors, and students

---

## ✨ Features

### Admin
- Full user management — create, edit, delete users
- Module management with student capacity control
- Manual student enrolment into modules
- System-wide dashboard showing total users, modules, instructors and students

### Instructor
- View assigned modules and supervision load
- Track students per module
- Quick access to grading, course materials and announcements

### Student
- View enrolled modules and credits
- Self-enrol into available modules
- Track academic progress per semester

---

## 🛠 Tech Stack

| Layer           | Technology                                  |
|-----------------|---------------------------------------------|
| Backend         | Java 21, JSP, Servlets                      |
| Server          | Apache Tomcat 11.0                          |
| Database        | MySQL 8.0 (Aiven Cloud)                     |
| Security        | BCrypt password hashing, session management |
| Build Tool      | Apache Maven                                |
| Container       | Docker                                      |
| Hosting         | Render.com (free tier)                      |
| Version Control | Git / GitHub                                |

---

## 📁 Project Structure

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
│           │   ├── instructor/ # Instructor JSP pages
│           │   └── student/    # Student JSP pages
│           └── WEB-INF/
├── Dockerfile                  # Docker configuration
├── server.xml                  # Tomcat server config
├── pom.xml                     # Maven dependencies
└── seed_honours.sql            # Database seed data
```

---

## 🚀 Running Locally

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

```bash
mysql -u root -p
source seed_honours.sql
```

### Step 3 — Configure database credentials

```bash
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
DB_URL=jdbc:mysql://localhost:3306/defaultdb?useSSL=false&serverTimezone=UTC
```

### Step 4 — Build the project

```bash
mvn clean package
```

### Step 5 — Deploy to Tomcat

```bash
copy target\CourseManagementSystem.war "C:\Program Files\Apache Software Foundation\Tomcat 11.0\webapps\"
```

### Step 6 — Access the app

```
http://localhost:8080/pages/login.jsp
```

---

## 🐳 Running with Docker

```bash
docker build -t course-management-system .
docker run -p 8080:8080 \
  -e DB_USERNAME=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_URL=your_database_url \
  course-management-system
```

---

## 👤 Author

**Ntombikayise** — [@Kayise02](https://github.com/Kayise02)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
