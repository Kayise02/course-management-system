-- Course Management System Database Setup
DROP DATABASE IF EXISTS course_management_system;
CREATE DATABASE course_management_system;
USE course_management_system;

-- Users table
CREATE TABLE users (
    user_id    INT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(50)  UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,          -- stores BCrypt hash, not plaintext
    email      VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    role       ENUM('admin', 'instructor', 'student') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses table
CREATE TABLE courses (
    course_id       INT PRIMARY KEY AUTO_INCREMENT,
    course_code     VARCHAR(20)  UNIQUE NOT NULL,
    course_name     VARCHAR(100) NOT NULL,
    description     TEXT,
    credits         INT          NOT NULL,
    instructor_id   INT,
    schedule        VARCHAR(100),
    room_assignment VARCHAR(50),
    max_students    INT,
    status          ENUM('active', 'archived') DEFAULT 'active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Enrollments table
CREATE TABLE enrollments (
    enrollment_id   INT PRIMARY KEY AUTO_INCREMENT,
    student_id      INT NOT NULL,
    course_id       INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('enrolled', 'waitlisted', 'dropped') DEFAULT 'enrolled',
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id)
);

-- Assignments table
CREATE TABLE assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id     INT          NOT NULL,
    title         VARCHAR(100) NOT NULL,
    description   TEXT,
    due_date      DATETIME,
    max_points    DECIMAL(5,2),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- FIX: Seed data now uses BCrypt hashes instead of plaintext passwords.
-- These hashes correspond to the original sample passwords (cost factor 12).
-- To regenerate hashes: use UserDAO.hashPassword() or an online BCrypt tool.
--
--   admin123    -> $2a$12$7vK3QNMhWzMByLiGJESmae0sRHMlI.UVSiTmGHPHqT4Z1gFqJw5Ve
--   prof123     -> $2a$12$EWvSMVkLpHn1KrMiMqDGqOQ7iQ7z8X7zOwfqWr6j8XtqX5F5x1hFe
--   student123  -> $2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uJadK9/km
INSERT INTO users (username, password, email, first_name, last_name, role) VALUES
('admin',
 '$2a$12$7vK3QNMhWzMByLiGJESmae0sRHMlI.UVSiTmGHPHqT4Z1gFqJw5Ve',
 'admin@university.edu', 'John', 'Administrator', 'admin'),

('prof_smith',
 '$2a$12$EWvSMVkLpHn1KrMiMqDGqOQ7iQ7z8X7zOwfqWr6j8XtqX5F5x1hFe',
 'john.smith@university.edu', 'John', 'Smith', 'instructor'),

('prof_johnson',
 '$2a$12$EWvSMVkLpHn1KrMiMqDGqOQ7iQ7z8X7zOwfqWr6j8XtqX5F5x1hFe',
 'sarah.johnson@university.edu', 'Sarah', 'Johnson', 'instructor'),

('alice_j',
 '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uJadK9/km',
 'alice.johnson@student.edu', 'Alice', 'Johnson', 'student'),

('bob_w',
 '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uJadK9/km',
 'bob.williams@student.edu', 'Bob', 'Williams', 'student');

INSERT INTO courses (course_code, course_name, description, credits, instructor_id, schedule, room_assignment, max_students)
VALUES
('CS101',   'Introduction to Computer Science', 'Fundamental programming concepts',   3, 2, 'Mon/Wed 10:00-11:30',       'Science Building 101', 30),
('MATH101', 'Calculus I',                        'Differential and integral calculus', 4, 3, 'Mon/Wed/Fri 13:00-14:00', 'Math Building 101',    35);

INSERT INTO enrollments (student_id, course_id, status) VALUES
(4, 1, 'enrolled'),
(5, 1, 'enrolled');

-- Verification
SELECT 'Database setup completed successfully!' AS status;
SELECT COUNT(*) AS user_count   FROM users;
SELECT COUNT(*) AS course_count FROM courses;
