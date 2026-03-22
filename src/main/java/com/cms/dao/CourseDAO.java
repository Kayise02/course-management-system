package com.cms.dao;
import com.cms.model.Course;
import com.cms.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAO {

    public List<Course> getAllCourses() throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT c.*, u.first_name, u.last_name " +
                     "FROM courses c LEFT JOIN users u ON c.instructor_id = u.user_id " +
                     "WHERE c.status = 'active'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                courses.add(mapRow(rs));
            }
        }
        return courses;
    }

    // Returns only the courses a specific student is enrolled in
    public List<Course> getEnrolledCourses(int studentId) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT c.*, u.first_name, u.last_name " +
                     "FROM courses c " +
                     "JOIN enrollments e ON e.course_id = c.course_id " +
                     "LEFT JOIN users u ON c.instructor_id = u.user_id " +
                     "WHERE e.student_id = ? AND e.status = 'enrolled' AND c.status = 'active'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        }
        return courses;
    }

    // Enrols a student with capacity check and duplicate check
    public boolean enrollStudent(int studentId, int courseId) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection()) {

            // Check if already enrolled
            String dupSql = "SELECT COUNT(*) FROM enrollments " +
                            "WHERE student_id = ? AND course_id = ? AND status = 'enrolled'";
            try (PreparedStatement dup = conn.prepareStatement(dupSql)) {
                dup.setInt(1, studentId);
                dup.setInt(2, courseId);
                ResultSet rs = dup.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // already enrolled
                }
            }

            // Check capacity
            String checkSql =
                "SELECT c.max_students, COUNT(e.enrollment_id) AS enrolled " +
                "FROM courses c " +
                "LEFT JOIN enrollments e ON e.course_id = c.course_id AND e.status = 'enrolled' " +
                "WHERE c.course_id = ? " +
                "GROUP BY c.course_id";
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, courseId);
                ResultSet rs = check.executeQuery();
                if (!rs.next()) return false; // course not found
                int max     = rs.getInt("max_students");
                int current = rs.getInt("enrolled");
                if (current >= max) return false; // course full
            }

            // Insert enrolment
            String insertSql =
                "INSERT INTO enrollments (student_id, course_id, status) VALUES (?, ?, 'enrolled')";
            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setInt(1, studentId);
                insert.setInt(2, courseId);
                insert.executeUpdate();
                return true;
            }
        }
    }

    private Course mapRow(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setCourseId(rs.getInt("course_id"));
        course.setCourseCode(rs.getString("course_code"));
        course.setCourseName(rs.getString("course_name"));
        course.setDescription(rs.getString("description"));
        course.setCredits(rs.getInt("credits"));
        course.setInstructorId(rs.getInt("instructor_id"));
        course.setInstructorName(rs.getString("first_name") + " " + rs.getString("last_name"));
        course.setSchedule(rs.getString("schedule"));
        course.setRoomAssignment(rs.getString("room_assignment"));
        course.setMaxStudents(rs.getInt("max_students"));
        course.setStatus(rs.getString("status"));
        return course;
    }
}
