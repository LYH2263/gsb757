package com.bookstore.web;

import com.bookstore.dao.CartDao;
import com.bookstore.model.CartItem;
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
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/cart/*")
public class CartServlet extends HttpServlet {
    private CartDao cartDao = new CartDao();
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
            List<CartItem> items = cartDao.findByUserId(user.getId());
            ResponseUtil.sendJson(resp, items);
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

        try {
            JsonObject json = gson.fromJson(req.getReader(), JsonObject.class);
            int bookId = json.get("bookId").getAsInt();
            int quantity = json.has("quantity") ? json.get("quantity").getAsInt() : 1;

            cartDao.addOrUpdate(user.getId(), bookId, quantity);
            ResponseUtil.sendSuccess(resp, "Added to cart");
        } catch (Exception e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, e.getMessage());
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getSessionUser(req);
        if (user == null) {
            ResponseUtil.sendError(resp, 401, "Not logged in");
            return;
        }

        try {
            // Path Info: /item/{id}
            String pathInfo = req.getPathInfo();
            if (pathInfo != null && pathInfo.startsWith("/item/")) {
                int itemId = Integer.parseInt(pathInfo.substring(6));
                JsonObject json = gson.fromJson(req.getReader(), JsonObject.class);
                int quantity = json.get("quantity").getAsInt();

                cartDao.updateQuantity(itemId, quantity);
                ResponseUtil.sendSuccess(resp, "Cart updated");
            } else {
                ResponseUtil.sendError(resp, 400, "Invalid URL");
            }
        } catch (Exception e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, e.getMessage());
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getSessionUser(req);
        if (user == null) {
            ResponseUtil.sendError(resp, 401, "Not logged in");
            return;
        }

        try {
            String pathInfo = req.getPathInfo();
            if (pathInfo != null && pathInfo.startsWith("/item/")) {
                int itemId = Integer.parseInt(pathInfo.substring(6));
                cartDao.remove(itemId);
                ResponseUtil.sendSuccess(resp, "Item removed");
            } else {
                // Clear all
                cartDao.clear(user.getId());
                ResponseUtil.sendSuccess(resp, "Cart cleared");
            }
        } catch (Exception e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, e.getMessage());
        }
    }
}
