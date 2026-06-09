package com.bookstore.web;

import com.bookstore.dao.UserDao;
import com.bookstore.model.User;
import com.bookstore.util.ResponseUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/api/login", "/api/register", "/api/logout", "/api/me"})
public class AuthServlet extends HttpServlet {

    private UserDao userDao = new UserDao();
    private Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            if ("/api/login".equals(path)) {
                handleLogin(req, resp);
            } else if ("/api/register".equals(path)) {
                handleRegister(req, resp);
            } else if ("/api/logout".equals(path)) {
                handleLogout(req, resp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, "Database error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/api/me".equals(req.getServletPath())) {
             HttpSession session = req.getSession(false);
             if (session != null && session.getAttribute("user") != null) {
                 ResponseUtil.sendJson(resp, session.getAttribute("user"));
             } else {
                 ResponseUtil.sendError(resp, 401, "Not logged in");
             }
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        User credentials = gson.fromJson(req.getReader(), User.class);
        User user = userDao.findByUsername(credentials.getUsername());

        if (user != null && user.getPassword().equals(credentials.getPassword())) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            ResponseUtil.sendJson(resp, user);
        } else {
            ResponseUtil.sendError(resp, 401, "Invalid username or password");
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        User newUser = gson.fromJson(req.getReader(), User.class);
        if (userDao.findByUsername(newUser.getUsername()) != null) {
            ResponseUtil.sendError(resp, 400, "Username already exists");
            return;
        }
        newUser.setRole("USER");
        userDao.save(newUser);
        ResponseUtil.sendSuccess(resp, "Registration successful");
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        ResponseUtil.sendSuccess(resp, "Logged out");
    }
}
