package com.bookstore.web;

import com.bookstore.dao.CartDao;
import com.bookstore.dao.OrderDao;
import com.bookstore.model.CartItem;
import com.bookstore.model.User;
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

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private CartDao cartDao = new CartDao();
    private OrderDao orderDao = new OrderDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if ("/checkout".equals(path)) {
            handleCheckout(req, resp);
        } else {
            resp.sendError(404);
        }
    }

    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<CartItem> cartItems = cartDao.findByUserId(user.getId());
            if (cartItems.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/cart.jsp?error=empty");
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

            // Redirect to success page (or simple confirmation)
            req.setAttribute("message", "Order placed successfully! Order ID: " + orderId);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/cart.jsp?error=db");
        }
    }
}
