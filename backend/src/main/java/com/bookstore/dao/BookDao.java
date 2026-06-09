package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDao {

    public List<Book> findAll() throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                books.add(mapBook(rs));
            }
        }
        return books;
    }

    public Book findById(int id) throws SQLException {
        String sql = "SELECT * FROM books WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapBook(rs);
                }
            }
        }
        return null;
    }

    private Book mapBook(ResultSet rs) throws SQLException {
        return new Book(
            rs.getInt("id"),
            rs.getString("title"),
            rs.getString("author"),
            rs.getBigDecimal("price"),
            rs.getString("description"),
            rs.getString("image_url")
        );
    }
}
