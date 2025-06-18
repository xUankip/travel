<%@ page import="com.travelclient.TravelClient" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");
  String userId = (String) session.getAttribute("userId");

  if (username == null || !"traveler".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }

  String message = null;
  String imageResult = null;

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");

    try {
      switch (action) {
        case "ratePlace":
          boolean rated = TravelClient.ratePlace(
                  Long.parseLong(request.getParameter("placeId")),
                  Long.parseLong(userId),
                  Integer.parseInt(request.getParameter("rating")),
                  request.getParameter("comment"));
          message = rated ? "✅ Rating submitted." : "❌ Failed to rate place.";
          break;

        case "viewImages":
          imageResult = TravelClient.getImagesByPlace(
                  Long.parseLong(request.getParameter("viewPlaceId")));
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
  <title>Traveler - Rate & View</title>
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
      <a href="traveler.jsp" class="block py-2 px-3 bg-indigo-600 rounded">⭐ Rate Places</a>
      <a href="traveler.jsp#reviews" class="block py-2 px-3 rounded hover:bg-indigo-600">📖 My Reviews</a>
      <a href="logout.jsp" class="block py-2 px-3 rounded hover:bg-red-500 mt-4">🚪 Logout</a>
    </nav>
  </div>

  <!-- Main Content -->
  <div class="flex-1">
    <div class="bg-white shadow p-4 flex justify-between items-center">
      <h2 class="text-2xl font-semibold">Traveler Actions</h2>
      <div class="text-right">
        <div class="font-semibold"><%= username %></div>
        <div class="text-sm text-indigo-600 uppercase"><%= role %></div>
      </div>
    </div>

    <div class="p-6 space-y-6">
      <% if (message != null) { %>
      <div class="bg-green-100 text-green-800 px-4 py-2 rounded"><%= message %></div>
      <% } %>

      <!-- Rate Place -->
      <form method="post" class="bg-white p-4 rounded shadow space-y-2">
        <input type="hidden" name="action" value="ratePlace"/>
        <h3 class="text-xl font-bold mb-2">⭐ Rate & Comment Place</h3>
        <input name="placeId" type="number" placeholder="Place ID" class="w-full border p-2 rounded" required>
        <input name="rating" type="number" min="1" max="5" placeholder="Rating (1-5)" class="w-full border p-2 rounded" required>
        <textarea name="comment" placeholder="Comment" class="w-full border p-2 rounded" required></textarea>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Submit Rating</button>
      </form>

      <!-- View Images -->
      <form method="post" class="bg-white p-4 rounded shadow space-y-2">
        <input type="hidden" name="action" value="viewImages"/>
        <h3 class="text-xl font-bold mb-2">🖼️ View Images by Place ID</h3>
        <input name="viewPlaceId" type="number" placeholder="Place ID" class="w-full border p-2 rounded" required>
        <button type="submit" class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">View Images</button>
      </form>

      <% if (imageResult != null) { %>
      <div class="bg-white p-4 rounded shadow">
        <h4 class="text-lg font-semibold mb-2">📸 Image Results:</h4>
        <pre class="bg-gray-100 p-4 rounded text-sm"><%= imageResult %></pre>
      </div>
      <% } %>
    </div>
  </div>
</div>
</body>
</html>
