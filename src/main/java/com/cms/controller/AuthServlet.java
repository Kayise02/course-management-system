package com.cms.controller;

import com.cms.dao.UserDAO;
import com.cms.dao.CourseDAO;
import com.cms.model.User;
import com.cms.model.Course;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private UserDAO userDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() throws ServletException {
        userDAO   = new UserDAO();
        courseDAO = new CourseDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";
        switch (action) {
            case "login":        login(request, response);        break;
            case "logout":       logout(request, response);       break;
            case "register":     register(request, response);     break;
            case "addUser":      addUser(request, response);      break;
            case "updateUser":   updateUser(request, response);   break;
            case "deleteUser":   deleteUser(request, response);   break;
            case "addCourse":    addCourse(request, response);    break;
            case "updateCourse": updateCourse(request, response); break;
            case "deleteCourse": deleteCourse(request, response); break;
            case "enroll":       enroll(request, response);       break;
            case "adminEnroll":  adminEnroll(request, response);  break;
            default:
                response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
        }
    }

    // ── LOGIN ──────────────────────────────────────────────────────────────
    private void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("pages/login.jsp").forward(request, response);
            return;
        }
        try {
            User user = userDAO.authenticate(username, password);
            if (user != null) {
                HttpSession old = request.getSession(false);
                if (old != null) old.invalidate();
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60);
                switch (user.getRole()) {
                    case "admin":
                        response.sendRedirect(request.getContextPath() + "/pages/admin/dashboard.jsp"); break;
                    case "instructor":
                        response.sendRedirect(request.getContextPath() + "/pages/instructor/dashboard.jsp"); break;
                    case "student":
                        response.sendRedirect(request.getContextPath() + "/pages/student/dashboard.jsp"); break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
                }
            } else {
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("pages/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            throw new ServletException("Login failed", e);
        }
    }

    // ── LOGOUT ─────────────────────────────────────────────────────────────
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
        response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
    }

    // ── REGISTER ───────────────────────────────────────────────────────────
    private void register(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String username  = request.getParameter("username");
        String email     = request.getParameter("email");
        String password  = request.getParameter("password");
        String role      = request.getParameter("role");
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("pages/register.jsp").forward(request, response);
            return;
        }
        if (role == null || (!role.equals("student") && !role.equals("instructor"))) {
            role = "student";
        }
        String sql = "INSERT INTO users (username, password, email, first_name, last_name, role) VALUES (?,?,?,?,?,?)";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, UserDAO.hashPassword(password));
            stmt.setString(3, email);
            stmt.setString(4, firstName);
            stmt.setString(5, lastName);
            stmt.setString(6, role);
            stmt.executeUpdate();
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
        } catch (SQLIntegrityConstraintViolationException e) {
            request.setAttribute("error", "Username or email already exists.");
            request.getRequestDispatcher("pages/register.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Registration failed", e);
        }
    }

    // ── ADD USER (admin) ───────────────────────────────────────────────────
    private void addUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String username  = request.getParameter("username");
        String email     = request.getParameter("email");
        String password  = request.getParameter("password");
        String role      = request.getParameter("role");
        String sql = "INSERT INTO users (username, password, email, first_name, last_name, role) VALUES (?,?,?,?,?,?)";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, UserDAO.hashPassword(password));
            stmt.setString(3, email);
            stmt.setString(4, firstName);
            stmt.setString(5, lastName);
            stmt.setString(6, role != null ? role : "student");
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Add user failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/users.jsp");
    }

    // ── UPDATE USER (admin) ────────────────────────────────────────────────
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String userId    = request.getParameter("userId");
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String username  = request.getParameter("username");
        String email     = request.getParameter("email");
        String role      = request.getParameter("role");
        String sql = "UPDATE users SET username=?, email=?, first_name=?, last_name=?, role=? WHERE user_id=?";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, email);
            stmt.setString(3, firstName);
            stmt.setString(4, lastName);
            stmt.setString(5, role);
            stmt.setInt(6, Integer.parseInt(userId));
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Update user failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/users.jsp");
    }

    // ── DELETE USER (admin) ────────────────────────────────────────────────
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String userId = request.getParameter("userId");
        String sql = "DELETE FROM users WHERE user_id=?";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Integer.parseInt(userId));
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Delete user failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/users.jsp");
    }

    // ── ADD COURSE (admin) ─────────────────────────────────────────────────
    private void addCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String courseCode    = request.getParameter("courseCode");
        String courseName    = request.getParameter("courseName");
        String description   = request.getParameter("description");
        String credits       = request.getParameter("credits");
        String maxStudents   = request.getParameter("maxStudents");
        String instructorId  = request.getParameter("instructorId");
        String schedule      = request.getParameter("schedule");
        String roomAssignment = request.getParameter("roomAssignment");
        String sql = "INSERT INTO courses (course_code, course_name, description, credits, max_students, instructor_id, schedule, room_assignment, status) VALUES (?,?,?,?,?,?,?,?,'active')";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseCode);
            stmt.setString(2, courseName);
            stmt.setString(3, description);
            stmt.setInt(4, parseInt(credits, 3));
            stmt.setInt(5, parseInt(maxStudents, 30));
            if (instructorId != null && !instructorId.isBlank()) {
                stmt.setInt(6, Integer.parseInt(instructorId));
            } else {
                stmt.setNull(6, java.sql.Types.INTEGER);
            }
            stmt.setString(7, schedule);
            stmt.setString(8, roomAssignment);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Add course failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/courses.jsp");
    }

    // ── UPDATE COURSE (admin) ──────────────────────────────────────────────
    private void updateCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String courseId      = request.getParameter("courseId");
        String courseCode    = request.getParameter("courseCode");
        String courseName    = request.getParameter("courseName");
        String credits       = request.getParameter("credits");
        String maxStudents   = request.getParameter("maxStudents");
        String schedule      = request.getParameter("schedule");
        String roomAssignment = request.getParameter("roomAssignment");
        String sql = "UPDATE courses SET course_code=?, course_name=?, credits=?, max_students=?, schedule=?, room_assignment=? WHERE course_id=?";
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseCode);
            stmt.setString(2, courseName);
            stmt.setInt(3, parseInt(credits, 3));
            stmt.setInt(4, parseInt(maxStudents, 30));
            stmt.setString(5, schedule);
            stmt.setString(6, roomAssignment);
            stmt.setInt(7, Integer.parseInt(courseId));
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("Update course failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/courses.jsp");
    }

    // ── DELETE COURSE (admin) ──────────────────────────────────────────────
    private void deleteCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String courseId = request.getParameter("courseId");
        try (Connection conn = com.cms.util.DatabaseConnection.getConnection()) {
            try (PreparedStatement s = conn.prepareStatement("DELETE FROM enrollments WHERE course_id=?")) {
                s.setInt(1, Integer.parseInt(courseId));
                s.executeUpdate();
            }
            try (PreparedStatement s = conn.prepareStatement("DELETE FROM courses WHERE course_id=?")) {
                s.setInt(1, Integer.parseInt(courseId));
                s.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException("Delete course failed", e);
        }
        response.sendRedirect(request.getContextPath() + "/pages/admin/courses.jsp");
    }

    // ── ENROLL (student self-enrol) ────────────────────────────────────────
    private void enroll(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        String courseId = request.getParameter("courseId");
        try {
            boolean ok = courseDAO.enrollStudent(user.getUserId(), Integer.parseInt(courseId));
            if (ok) {
                session.setAttribute("enrollMessage", "Successfully enrolled!");
            } else {
                session.setAttribute("enrollError", "Enrolment failed — module may be full or you are already enrolled.");
            }
        } catch (SQLException e) {
            session.setAttribute("enrollError", "Database error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/pages/student/dashboard.jsp");
    }

    // ── ADMIN ENROLL ───────────────────────────────────────────────────────
    private void adminEnroll(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        requireAdmin(request, response);
        String studentId = request.getParameter("studentId");
        String courseId  = request.getParameter("courseId");
        try {
            boolean ok = courseDAO.enrollStudent(
                Integer.parseInt(studentId),
                Integer.parseInt(courseId)
            );
            if (ok) {
                request.setAttribute("message", "Student enrolled successfully.");
            } else {
                request.setAttribute("error", "Enrolment failed — course may be full or student already enrolled.");
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("pages/admin/enrollments.jsp").forward(request, response);
    }

    // ── HELPERS ────────────────────────────────────────────────────────────
    private void requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
        }
    }

    private int parseInt(String value, int defaultVal) {
        try { return Integer.parseInt(value); }
        catch (Exception e) { return defaultVal; }
    }
}
