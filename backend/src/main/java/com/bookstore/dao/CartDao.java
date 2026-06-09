package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.model.CartItem;
import com.bookstore.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDao {

    public List<CartItem> findByUserId(int userId) throws SQLException {
        List<CartItem> items = new ArrayList<>();
        // Join with books to get book details
        String sql = "SELECT c.*, b.title, b.author, b.price, b.description, b.image_url " +
                     "FROM cart_items c " +
                     "JOIN books b ON c.book_id = b.id " +
                     "WHERE c.user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    items.add(mapCartItem(rs));
                }
            }
        }
        return items;
    }

    public void addOrUpdate(int userId, int bookId, int quantity) throws SQLException {
        // Check if item exists
        String checkSql = "SELECT id, quantity FROM cart_items WHERE user_id = ? AND book_id = ?";
        String insertSql = "INSERT INTO cart_items (user_id, book_id, quantity) VALUES (?, ?, ?)";
        String updateSql = "UPDATE cart_items SET quantity = quantity + ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            int existingId = -1;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, bookId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("id");
                    }
                }
            }

            if (existingId != -1) {
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, quantity);
                    updateStmt.setInt(2, existingId);
                    updateStmt.executeUpdate();
                }
            } else {
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setInt(1, userId);
                    insertStmt.setInt(2, bookId);
                    insertStmt.setInt(3, quantity);
                    insertStmt.executeUpdate();
                }
            }
        }
    }

    public void updateQuantity(int itemId, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, itemId);
            stmt.executeUpdate();
        }
    }

    public void remove(int itemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemId);
            stmt.executeUpdate();
        }
    }

    public void clear(int userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }

    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        Book book = new Book(
            rs.getInt("book_id"),
            rs.getString("title"),
            rs.getString("author"),
            rs.getBigDecimal("price"),
            rs.getString("description"),
            rs.getString("image_url")
        );

        return new CartItem(
            rs.getInt("id"),
            rs.getInt("user_id"),
            rs.getInt("book_id"),
            rs.getInt("quantity"),
            book
        );
    }
}
