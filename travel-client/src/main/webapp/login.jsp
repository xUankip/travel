<%@ page import="com.travelclient.TravelClient" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String loginMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String result = TravelClient.login(username, password);

        if (result.startsWith("success:")) {
            String[] parts = result.split(":");
            String userId = parts[1];
            String role = parts[2];

            session.setAttribute("userId", userId);
            session.setAttribute("role", role);
            session.setAttribute("username", username);

            // Redirect based on role
            if ("guide".equals(role)) {
                response.sendRedirect("guide.jsp");
                return;
            } else if ("traveler".equals(role)) {
                response.sendRedirect("traveler.jsp");
                return;
            } else {
                loginMessage = "Unknown role: " + role;
            }
        } else {
            loginMessage = "Login failed. Please check your credentials.";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Travel Service</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">
<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold text-center mb-6">Travel Service - Login</h1>
    <div class="bg-white p-6 rounded-lg shadow-md max-w-md mx-auto">
        <form method="post">
            <h2 class="text-2xl font-semibold mb-4">Login</h2>

            <input name="username" type="text" placeholder="Username"
                   class="border p-2 mb-2 w-full rounded" required>

            <input name="password" type="password" placeholder="Password"
                   class="border p-2 mb-2 w-full rounded" required>

            <button type="submit"
                    class="bg-blue-500 text-white p-2 rounded hover:bg-blue-600 w-full">Login</button>
        </form>

        <% if (loginMessage != null) { %>
        <div class="mt-4 text-center text-red-500"><%= loginMessage %></div>
        <% } %>

        <a href="index.jsp" class="text-blue-500 hover:underline mt-4 block text-center">Back to Home</a>
    </div>
</div>
</body>
</html>
