package com.cms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL;
    private static final String USERNAME;
    private static final String PASSWORD;

    static {
        // FIX: Read from Java system properties (-D flags) first, then fall back to env vars.
        // This allows Tomcat Windows Service to pass credentials via Java Options in tomcat11w.exe.
        URL = System.getProperty("DB_URL",
              System.getenv().getOrDefault("DB_URL",
              "jdbc:mysql://localhost:3306/course_management_system?useSSL=false&serverTimezone=UTC"));

        USERNAME = System.getProperty("DB_USERNAME", System.getenv("DB_USERNAME"));
        PASSWORD = System.getProperty("DB_PASSWORD", System.getenv("DB_PASSWORD"));

        if (USERNAME == null || PASSWORD == null) {
            throw new ExceptionInInitializerError(
                "DB_USERNAME and DB_PASSWORD must be set as environment variables or -D system properties.");
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("Connection test: SUCCESS");
            System.out.println("  Database: " + conn.getCatalog());
        } catch (SQLException e) {
            System.out.println("Connection test: FAILED — " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        testConnection();
    }
}
