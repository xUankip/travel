
<%@ page import="com.travelclient.TravelClient" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String searchResults = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String keyword = request.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            searchResults = TravelClient.searchPlaces(keyword.trim());
        } else {
            searchResults = "Please enter a keyword.";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Places - Travel Service</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">
<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold text-center mb-6">Travel Service - Search Places</h1>
    <div class="bg-white p-6 rounded-lg shadow-md max-w-md mx-auto">
        <form method="post">
            <h2 class="text-2xl font-semibold mb-4">Search Places</h2>
            <input name="keyword" type="text" placeholder="Enter keyword (e.g., beach)"
                   class="border p-2 mb-2 w-full rounded" required>
            <button type="submit"
                    class="bg-blue-500 text-white p-2 rounded hover:bg-blue-600 w-full">Search</button>
        </form>

        <% if (searchResults != null) { %>
        <pre class="mt-4 bg-gray-100 p-4 rounded text-sm"><%= searchResults %></pre>
        <% } %>

        <a href="index.jsp" class="text-blue-500 hover:underline mt-4 block text-center">Back to Home</a>
    </div>
</div>
</body>
</html>
