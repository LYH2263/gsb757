package com.bookstore.dao;

import com.bookstore.model.Order;
import com.bookstore.model.OrderItem;
import com.bookstore.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;

public class OrderDao {

    public int createOrder(int userId, BigDecimal totalAmount) throws SQLException {
        String sql = "INSERT INTO orders (user_id, total_amount, status) VALUES (?, ?, 'COMPLETED')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, userId);
            stmt.setBigDecimal(2, totalAmount);
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Failed to create order");
    }

    public void createOrderItem(int orderId, int bookId, int quantity, BigDecimal price) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, book_id, quantity, price) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.setInt(2, bookId);
            stmt.setInt(3, quantity);
            stmt.setBigDecimal(4, price);
            stmt.executeUpdate();
        }
    }
}
