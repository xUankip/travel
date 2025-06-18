<%@ page import="com.travelclient.TravelClient" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String userId = (String) session.getAttribute("userId");

    if (username == null || !"guide".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        try {
            switch (action) {
                case "addPlace":
                    boolean added = TravelClient.addPlace(
                            request.getParameter("placeName"),
                            request.getParameter("placeDescription"),
                            Long.parseLong(userId));
                    message = added ? "✅ Place added successfully." : "❌ Failed to add place.";
                    break;
                case "updatePlace":
                    boolean updated = TravelClient.updatePlace(
                            Long.parseLong(request.getParameter("updatePlaceId")),
                            request.getParameter("updatePlaceName"),
                            request.getParameter("updatePlaceDescription"),
                            Long.parseLong(userId));
                    message = updated ? "✅ Place updated." : "❌ Failed to update.";
                    break;
                case "deletePlace":
                    boolean deleted = TravelClient.deletePlace(
                            Long.parseLong(request.getParameter("deletePlaceId")),
                            Long.parseLong(userId));
                    message = deleted ? "✅ Place deleted." : "❌ Failed to delete.";
                    break;
                case "addImage":
                    boolean imageAdded = TravelClient.addImage(
                            Long.parseLong(request.getParameter("imagePlaceId")),
                            request.getParameter("imageUrl"),
                            request.getParameter("imageDescription"),
                            Long.parseLong(userId));
                    message = imageAdded ? "✅ Image added." : "❌ Failed to add image.";
                    break;
            }
        } catch (Exception e) {
            message = "⚠️ Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Guide - Manage Places</title>
    <meta charset="UTF-8">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">

<div class="flex h-screen">
    <!-- Sidebar -->
    <div class="w-64 bg-indigo-700 text-white p-4 space-y-4">
        <h2 class="text-xl font-bold">Travel Suite</h2>
        <nav class="space-y-2">
            <a href="dashboard.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">🏠 Dashboard</a>
            <a href="search.jsp" class="block py-2 px-3 rounded hover:bg-indigo-600">🔍 Search Places</a>
            <a href="addPlace.jsp" class="block py-2 px-3 bg-indigo-600 rounded">📍 Manage Places</a>
            <a href="addPlace.jsp#addImage" class="block py-2 px-3 rounded hover:bg-indigo-600">🖼️ Manage Images</a>
            <a href="logout.jsp" class="block py-2 px-3 rounded hover:bg-red-500 mt-4">🚪 Logout</a>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="flex-1">
        <div class="bg-white shadow p-4 flex justify-between items-center">
            <h2 class="text-2xl font-semibold">Manage Places & Images</h2>
            <div class="text-right">
                <div class="font-semibold"><%= username %></div>
                <div class="text-sm text-indigo-600 uppercase"><%= role %></div>
            </div>
        </div>

        <div class="p-6 space-y-6">
            <% if (message != null) { %>
            <div class="bg-green-100 text-green-800 px-4 py-2 rounded"><%= message %></div>
            <% } %>

            <!-- Add Place -->
            <form method="post" class="bg-white p-4 rounded shadow space-y-2">
                <input type="hidden" name="action" value="addPlace"/>
                <h3 class="text-xl font-bold mb-2">➕ Add Place</h3>
                <input name="placeName" type="text" placeholder="Place Name" class="w-full border p-2 rounded" required>
                <textarea name="placeDescription" placeholder="Description" class="w-full border p-2 rounded" required></textarea>
                <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Add Place</button>
            </form>

            <!-- Update Place -->
            <form method="post" class="bg-white p-4 rounded shadow space-y-2">
                <input type="hidden" name="action" value="updatePlace"/>
                <h3 class="text-xl font-bold mb-2">✏️ Update Place</h3>
                <input name="updatePlaceId" type="number" placeholder="Place ID" class="w-full border p-2 rounded" required>
                <input name="updatePlaceName" type="text" placeholder="New Name" class="w-full border p-2 rounded" required>
                <textarea name="updatePlaceDescription" placeholder="New Description" class="w-full border p-2 rounded" required></textarea>
                <button type="submit" class="bg-yellow-500 text-white px-4 py-2 rounded hover:bg-yellow-600">Update</button>
            </form>

            <!-- Delete Place -->
            <form method="post" class="bg-white p-4 rounded shadow space-y-2">
                <input type="hidden" name="action" value="deletePlace"/>
                <h3 class="text-xl font-bold mb-2">🗑️ Delete Place</h3>
                <input name="deletePlaceId" type="number" placeholder="Place ID" class="w-full border p-2 rounded" required>
                <button type="submit" class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">Delete</button>
            </form>

            <!-- Add Image -->
            <form method="post" class="bg-white p-4 rounded shadow space-y-2" id="addImage">
                <input type="hidden" name="action" value="addImage"/>
                <h3 class="text-xl font-bold mb-2">🖼️ Add Image</h3>
                <input name="imagePlaceId" type="number" placeholder="Place ID" class="w-full border p-2 rounded" required>
                <input name="imageUrl" type="text" placeholder="Image URL" class="w-full border p-2 rounded" required>
                <textarea name="imageDescription" placeholder="Description" class="w-full border p-2 rounded" required></textarea>
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Add Image</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>
