package com.bookstore.web;

import com.bookstore.dao.CartDao;
import com.bookstore.dao.OrderDao;
import com.bookstore.model.CartItem;
import com.bookstore.model.Order;
import com.bookstore.model.User;
import com.bookstore.util.ResponseUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/orders/*")
public class OrderServlet extends HttpServlet {
    private CartDao cartDao = new CartDao();
    private OrderDao orderDao = new OrderDao();
    private Gson gson = new Gson();

    private User getSessionUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            return (User) session.getAttribute("user");
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getSessionUser(req);
        if (user == null) {
            ResponseUtil.sendError(resp, 401, "Not logged in");
            return;
        }

        try {
            List<Order> orders = orderDao.findByUserId(user.getId());
            ResponseUtil.sendJson(resp, orders);
        } catch (SQLException e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getSessionUser(req);
        if (user == null) {
            ResponseUtil.sendError(resp, 401, "Not logged in");
            return;
        }

        String path = req.getPathInfo();

        if ("/checkout".equals(path)) {
            handleCheckout(req, resp, user);
        } else {
            ResponseUtil.sendError(resp, 404, "Not found");
        }
    }

    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        try {
            List<CartItem> cartItems = cartDao.findByUserId(user.getId());
            if (cartItems.isEmpty()) {
                ResponseUtil.sendError(resp, 400, "Cart is empty");
                return;
            }

            BigDecimal total = BigDecimal.ZERO;
            for (CartItem item : cartItems) {
                BigDecimal itemTotal = item.getBook().getPrice().multiply(new BigDecimal(item.getQuantity()));
                total = total.add(itemTotal);
            }

            int orderId = orderDao.createOrder(user.getId(), total);

            for (CartItem item : cartItems) {
                orderDao.createOrderItem(orderId, item.getBookId(), item.getQuantity(), item.getBook().getPrice());
            }

            cartDao.clear(user.getId());

            JsonObject result = new JsonObject();
            result.addProperty("orderId", orderId);
            result.addProperty("message", "Order placed successfully");
            ResponseUtil.sendJson(resp, result);

        } catch (SQLException e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, "Database error");
        }
    }
}
