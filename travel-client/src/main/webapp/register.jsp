<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<%@ page import="com.travelclient.TravelClient" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Travel Service</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">
<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold text-center mb-6">Travel Service - Register</h1>
    <div class="bg-white p-6 rounded-lg shadow-md max-w-md mx-auto">
        <form method="post">
            <h2 class="text-2xl font-semibold mb-4">Register</h2>

            <input name="username" type="text" placeholder="Username"
                   class="border p-2 mb-2 w-full rounded" required>

            <input name="password" type="password" placeholder="Password"
                   class="border p-2 mb-2 w-full rounded" required>

            <select name="role" class="border p-2 mb-2 w-full rounded" required>
                <option value="">Select Role</option>
                <option value="traveler">Traveler</option>
                <option value="guide">Guide</option>
            </select>

            <button type="submit"
                    class="bg-green-500 text-white p-2 rounded hover:bg-green-600 w-full">
                Register
            </button>
        </form>

        <%-- Result Message --%>
        <%
            if (request.getMethod().equalsIgnoreCase("POST")) {
                TravelService service = TravelClient.getPort();
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String role = request.getParameter("role");

                boolean result = false;
                if (username != null && password != null && role != null && !role.isEmpty()) {
                    result = service.register(username, password, role);
                }
        %>
        <div class="mt-4 text-center text-<%= result ? "green" : "red" %>-500">
            <%= result ? "Registration successful!" : "Registration failed (user may already exist)." %>
        </div>
        <% } %>

        <a href="index.jsp" class="text-blue-500 hover:underline mt-4 block text-center">Back to Home</a>
    </div>
</div>
</body>
</html>
