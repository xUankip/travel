package com.travelclient;

import com.travelclient.generated.TravelService;
import com.travelclient.generated.TravelServiceService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        TravelServiceService service = new TravelServiceService();
        TravelService port = service.getTravelServicePort();
        HttpSession session = request.getSession();

        if ("register".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            boolean result = port.register(username, password, role);
            if (result) {
                response.sendRedirect("login.jsp?message=Registration successful");
            } else {
                response.sendRedirect("register.jsp?message=Registration failed");
            }
        } else if ("login".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String result = port.login(username, password);
            if (result.startsWith("token")) {
                String[] parts = result.split(":");
                String token = parts[0];
                String role = parts[1];
                session.setAttribute("token", token);
                session.setAttribute("role", role);
                response.sendRedirect("home.jsp");
            } else {
                response.sendRedirect("login.jsp?message=Login failed");
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}
