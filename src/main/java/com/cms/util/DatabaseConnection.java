package com.cms.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL;
    private static final String USERNAME;
    private static final String PASSWORD;

    static {
        String url = System.getenv("DB_URL") != null
                   ? System.getenv("DB_URL")
                   : System.getProperty("DB_URL", "jdbc:mysql://honours-cms-mysql-ntombikayise21-8304.g.aivencloud.com:18355/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC");

        String username = System.getenv("DB_USERNAME") != null
                        ? System.getenv("DB_USERNAME")
                        : System.getProperty("DB_USERNAME", "avnadmin");

        String password = System.getenv("DB_PASSWORD") != null
                        ? System.getenv("DB_PASSWORD")
                        : System.getProperty("DB_PASSWORD", "AVNS_1C7QrSNiTEBlr8l7tff");

        URL      = url;
        USERNAME = username;
        PASSWORD = password;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}