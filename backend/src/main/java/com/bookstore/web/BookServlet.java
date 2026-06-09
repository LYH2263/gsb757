package com.bookstore.web;

import com.bookstore.dao.BookDao;
import com.bookstore.model.Book;
import com.bookstore.util.ResponseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/books")
public class BookServlet extends HttpServlet {
    private BookDao bookDao = new BookDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Book> books = bookDao.findAll();
            ResponseUtil.sendJson(resp, books);
        } catch (SQLException e) {
            e.printStackTrace();
            ResponseUtil.sendError(resp, 500, "Database error");
        }
    }
}
