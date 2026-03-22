-- ============================================================
-- Honours CMS - Phase 1 Seed Data
-- South African students, supervisors, and CS Honours modules
-- Run: source this file in MySQL after USE course_management_system;
-- ============================================================

USE course_management_system;

-- ============================================================
-- CLEAN EXISTING SEED DATA (keep tables, reset data)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE courses;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- ADMIN (1)
-- password: admin123 (plain text - handled by UserDAO)
-- ============================================================
INSERT INTO users (username, password, email, first_name, last_name, role) VALUES
('admin', 'admin123', 'admin@university.ac.za', 'System', 'Administrator', 'admin');

-- ============================================================
-- SUPERVISORS / INSTRUCTORS (6)
-- All passwords: password123
-- BCrypt hash of "password123"
-- ============================================================
INSERT INTO users (username, password, email, first_name, last_name, role) VALUES
('thabo.nkosi',     'password123', 'thabo.nkosi@gmail.com',     'Thabo',     'Nkosi',     'instructor'),
('zanele.dlamini',  'password123', 'zanele.dlamini@gmail.com',  'Zanele',    'Dlamini',   'instructor'),
('sipho.ndlovu',    'password123', 'sipho.ndlovu@gmail.com',    'Sipho',     'Ndlovu',    'instructor'),
('nomsa.khumalo',   'password123', 'nomsa.khumalo@gmail.com',   'Nomsa',     'Khumalo',   'instructor'),
('lungelo.zulu',    'password123', 'lungelo.zulu@gmail.com',    'Lungelo',   'Zulu',      'instructor'),
('ayanda.mokoena',  'password123', 'ayanda.mokoena@gmail.com',  'Ayanda',    'Mokoena',   'instructor');

-- ============================================================
-- STUDENTS (12 Honours CS students)
-- All passwords: password123
-- ============================================================
INSERT INTO users (username, password, email, first_name, last_name, role) VALUES
('koketso.mengwai',    'password123', 'koketso.mengwai@gmail.com',    'Koketso',    'Mengwai',    'student'),
('amogelang.matabane', 'password123', 'amogelang.matabane@gmail.com', 'Amogelang',  'Matabane',   'student'),
('mbali.mashiyane',    'password123', 'mbali.mashiyane@gmail.com',    'Mbali',      'Mashiyane',  'student'),
('obrah.makhubele',    'password123', 'obrah.makhubele@gmail.com',    'Obrah',      'Makhubele',  'student'),
('phinah.makhudu',     'password123', 'phinah.makhudu@gmail.com',     'Phinah',     'Makhudu',    'student'),
('ayanda.mkhwanazi',   'password123', 'ayanda.mkhwanazi@gmail.com',   'Ayanda',     'Mkhwanazi',  'student'),
('nolwazi.tlale',      'password123', 'nolwazi.tlale@gmail.com',      'Nolwazi',    'Tlale',      'student'),
('thandeka.sithole',   'password123', 'thandeka.sithole@gmail.com',   'Thandeka',   'Sithole',    'student'),
('lerato.molefe',      'password123', 'lerato.molefe@gmail.com',      'Lerato',     'Molefe',     'student'),
('sifiso.shabalala',   'password123', 'sifiso.shabalala@gmail.com',   'Sifiso',     'Shabalala',  'student'),
('nokuthula.mthembu',  'password123', 'nokuthula.mthembu@gmail.com',  'Nokuthula',  'Mthembu',    'student'),
('bongani.cele',       'password123', 'bongani.cele@gmail.com',       'Bongani',    'Cele',       'student');

-- ============================================================
-- MODULES / COURSES (5 Honours CS modules)
-- Instructor IDs assigned after insert using subqueries
-- ============================================================
INSERT INTO courses (course_code, course_name, description, credits, max_students, instructor_id, schedule, room_assignment, status) VALUES

('HON701',
 'Machine Learning & AI',
 'Deep learning, neural networks, NLP, and computer vision. Students build AI-powered applications and explore automated grading, sentiment analysis, and predictive modelling systems.',
 20, 3,
 (SELECT user_id FROM users WHERE username = 'thabo.nkosi'),
 'Mon/Wed 08:00-10:00',
 'Lab A - CS Building',
 'active'),

('HON702',
 'Cybersecurity & Cryptography',
 'Network security, blockchain, penetration testing and cryptographic protocols. Students implement secure systems, code plagiarism detectors, and blockchain-based submission logs.',
 20, 3,
 (SELECT user_id FROM users WHERE username = 'zanele.dlamini'),
 'Tue/Thu 10:00-12:00',
 'Lab B - CS Building',
 'active'),

('HON703',
 'Distributed Systems',
 'Cloud technologies, parallel computing, distributed databases and network algorithms. Students design cloud-based code runners and distributed performance dashboards.',
 20, 2,
 (SELECT user_id FROM users WHERE username = 'sipho.ndlovu'),
 'Mon/Wed 12:00-14:00',
 'Lab C - CS Building',
 'active'),

('HON704',
 'Software Engineering & Web Dev',
 'Agile engineering, software quality, advanced web technologies and HCI. Students build full-stack systems including this CMS — drag-and-drop planners and collaborative code-review tools.',
 20, 2,
 (SELECT user_id FROM users WHERE username = 'nomsa.khumalo'),
 'Tue/Thu 14:00-16:00',
 'Lab D - CS Building',
 'active'),

('HON705',
 'Advanced Algorithms',
 'Algorithm complexity, quantum computing simulation, and algorithmic game theory. Students build visualisation tools, competitive programming judges, and complexity analysers.',
 20, 2,
 (SELECT user_id FROM users WHERE username = 'lungelo.zulu'),
 'Fri 08:00-12:00',
 'Lab E - CS Building',
 'active');

-- ============================================================
-- INITIAL ENROLMENTS (12 students across 5 modules)
-- 3 students in HON701, 3 in HON702, 2 in HON703, 2 in HON704, 2 in HON705
-- ============================================================
INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'koketso.mengwai'    AND c.course_code = 'HON701';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'amogelang.matabane' AND c.course_code = 'HON701';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'mbali.mashiyane'    AND c.course_code = 'HON701';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'obrah.makhubele'    AND c.course_code = 'HON702';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'phinah.makhudu'     AND c.course_code = 'HON702';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'ayanda.mkhwanazi'   AND c.course_code = 'HON702';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'nolwazi.tlale'      AND c.course_code = 'HON703';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'thandeka.sithole'   AND c.course_code = 'HON703';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'lerato.molefe'      AND c.course_code = 'HON704';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'sifiso.shabalala'   AND c.course_code = 'HON704';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'nokuthula.mthembu'  AND c.course_code = 'HON705';

INSERT INTO enrollments (student_id, course_id, status)
SELECT u.user_id, c.course_id, 'enrolled'
FROM users u, courses c
WHERE u.username = 'bongani.cele'       AND c.course_code = 'HON705';

-- ============================================================
-- SUPERVISOR PREFERENCES (which modules each supervisor can supervise)
-- Stored as additional course assignments for supervisors 5 & 6
-- ayanda.mokoena covers HON701 as co-supervisor
-- ============================================================

-- Verify data loaded correctly
SELECT CONCAT('Users: ', COUNT(*)) AS summary FROM users
UNION ALL
SELECT CONCAT('Courses: ', COUNT(*)) FROM courses
UNION ALL
SELECT CONCAT('Enrollments: ', COUNT(*)) FROM enrollments;

SELECT u.first_name, u.last_name, u.role, u.email
FROM users u ORDER BY u.role, u.last_name;

SELECT c.course_code, c.course_name, CONCAT(u.first_name,' ',u.last_name) AS supervisor
FROM courses c LEFT JOIN users u ON c.instructor_id = u.user_id;
