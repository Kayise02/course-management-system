package com.cms.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL;
    private static final String USERNAME;
    private static final String PASSWORD;

    static {
        URL = System.getProperty("DB_URL",
              System.getenv().getOrDefault("DB_URL",
              "jdbc:mysql://honours-cms-mysql-ntombikayise21-8304.g.aivencloud.com:18355/defaultdb?ssl-mode=REQUIRED&useSSL=true&requireSSL=true&serverTimezone=UTC"));

        USERNAME = System.getProperty("DB_USERNAME",
                   System.getenv().getOrDefault("DB_USERNAME", "avnadmin"));

        PASSWORD = System.getProperty("DB_PASSWORD",
                   System.getenv().getOrDefault("DB_PASSWORD", ""));

        if (PASSWORD == null || PASSWORD.isEmpty()) {
            throw new ExceptionInInitializerError(
                "DB_PASSWORD must be set as an environment variable or -D system property.");
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
}
