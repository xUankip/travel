<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String userId = (String) session.getAttribute("userId");

    if (username == null || role == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Travel Suite</title>
    <meta charset="UTF-8">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">

<div class="flex h-screen">
    <!-- Sidebar -->
    <div class="w-64 bg-indigo-700 text-white flex flex-col">
        <div class="p-4 text-xl font-bold border-b border-indigo-600">Travel Suite</div>
        <nav class="flex-1 p-4 space-y-2">
            <a href="dashboard.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">🏠 Dashboard</a>
            <a href="search.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">🔍 Search Places</a>

            <% if ("guide".equals(role)) { %>
            <a href="guide.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">📍 Manage Places</a>
            <a href="guide.jsp#addImage" class="block py-2 px-3 rounded hover:bg-indigo-600">🖼️ Manage Images</a>
            <% } else if ("traveler".equals(role)) { %>
            <a href="traveler.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">⭐ Rate Places</a>
            <a href="traveler.jsp#reviews" class="block py-2 px-3 rounded hover:bg-indigo-600">📖 My Reviews</a>
            <% } %>

            <a href="profile.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">👤 Profile</a>
            <a href="logout.jsp" class="block py-2 px-3 rounded hover:bg-red-600 mt-6">🚪 Logout</a>
        </nav>
    </div>

    <!-- Main content -->
    <div class="flex-1 flex flex-col">
        <!-- Header -->
        <div class="bg-white shadow p-4 flex justify-between items-center">
            <h2 class="text-2xl font-bold">Dashboard</h2>
            <div class="text-right">
                <div class="text-gray-800 font-semibold"><%= username %></div>
                <div class="text-sm text-indigo-600 uppercase"><%= role %></div>
            </div>
        </div>

        <!-- Welcome section -->
        <div class="p-6">
            <div class="bg-white p-6 rounded-lg shadow text-center">
                <h3 class="text-2xl font-semibold mb-2">Welcome, <%= username %>!</h3>
                <p class="text-gray-600">You're logged in as a <strong><%= role %></strong>. Use the sidebar to navigate your tools.</p>
            </div>
        </div>
    </div>
</div>

</body>
</html>
