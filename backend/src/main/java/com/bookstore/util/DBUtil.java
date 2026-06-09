package com.bookstore.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    // These should match the Env vars or default to localhost for local testing if needed
    // But in Docker, we strictly rely on Env vars passed by docker-compose

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String url = System.getenv("DB_URL");
            String user = System.getenv("DB_USER");
            String password = System.getenv("DB_PASSWORD");

            // Fallback for local testing (optional, but good for safety)
            if (url == null) url = "jdbc:mysql://localhost:3306/bookstore?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            if (user == null) user = "root";
            if (password == null) password = "root";

            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
    }
}
