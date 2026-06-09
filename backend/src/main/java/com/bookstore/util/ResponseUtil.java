package com.bookstore.util;

import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class ResponseUtil {
    private static final Gson gson = new Gson();

    public static void sendJson(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    public static void sendError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        Map<String, String> error = new HashMap<>();
        error.put("error", message);
        sendJson(response, error);
    }

    public static void sendSuccess(HttpServletResponse response, String message) throws IOException {
        Map<String, String> success = new HashMap<>();
        success.put("message", message);
        sendJson(response, success);
    }
}
