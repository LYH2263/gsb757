package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.model.Order;
import com.bookstore.model.OrderItem;
import com.bookstore.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    /**
     * 查询指定用户的全部订单（按下单时间从最新到最早），并附带各订单的明细。
     */
    public List<Order> findByUserId(int userId) throws SQLException {
        List<Order> orders = new ArrayList<>();
        Map<Integer, Order> orderIndex = new HashMap<>();

        String orderSql = "SELECT id, user_id, total_amount, status, created_at " +
                          "FROM orders WHERE user_id = ? ORDER BY created_at DESC, id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(orderSql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setStatus(rs.getString("status"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    order.setCreatedAt(ts != null ? new java.util.Date(ts.getTime()) : null);
                    order.setItems(new ArrayList<>());
                    orders.add(order);
                    orderIndex.put(order.getId(), order);
                }
            }
        }

        if (orders.isEmpty()) {
            return orders;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < orders.size(); i++) {
            if (i > 0) placeholders.append(',');
            placeholders.append('?');
        }

        String itemSql = "SELECT oi.id, oi.order_id, oi.book_id, oi.quantity, oi.price, " +
                         "b.title, b.author, b.description, b.image_url " +
                         "FROM order_items oi JOIN books b ON oi.book_id = b.id " +
                         "WHERE oi.order_id IN (" + placeholders + ") ORDER BY oi.id ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(itemSql)) {
            int idx = 1;
            for (Order o : orders) {
                stmt.setInt(idx++, o.getId());
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book(
                        rs.getInt("book_id"),
                        rs.getString("title"),
                        rs.getString("author"),
                        rs.getBigDecimal("price"),
                        rs.getString("description"),
                        rs.getString("image_url")
                    );
                    OrderItem item = new OrderItem(
                        rs.getInt("id"),
                        rs.getInt("order_id"),
                        rs.getInt("book_id"),
                        rs.getInt("quantity"),
                        rs.getBigDecimal("price"),
                        book
                    );
                    Order parent = orderIndex.get(item.getOrderId());
                    if (parent != null) {
                        parent.getItems().add(item);
                    }
                }
            }
        }

        return orders;
    }
}
