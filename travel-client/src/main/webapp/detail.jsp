<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.*" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.List" %>
<%
  response.setCharacterEncoding("UTF-8");
  Long placeId = Long.parseLong(request.getParameter("placeId"));
  String token = (String) session.getAttribute("token");
  String role = (String) session.getAttribute("role");
  String name = "", description = "", guideName = "";
  String statusMessage = null, errorMessage = "", successMessage = "";
  String imageUrl = "";
  String commentsRaw = "", imagesRaw = "";

  try {
    URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
    QName qName = new QName("http://service.travel.com/", "TravelServiceService");
    Service service = Service.create(wsdlURL, qName);
    TravelService travelService = service.getPort(TravelService.class);

    // Fetch place details
    String detail = travelService.getPlaceDetails(placeId);
    if (detail != null && !detail.startsWith("error")) {
      String[] fields = detail.split(",");
      for (String field : fields) {
        if (field.startsWith("name:")) name = field.substring(5);
        else if (field.startsWith("description:")) description = field.substring(12);
        else if (field.startsWith("guide:")) guideName = field.substring(6);
      }
    }

    // Submit comment
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") == null) {
      String ratingStr = request.getParameter("rating");
      String comment = request.getParameter("comment");
      if (token != null) {
        try {
          int rating = Integer.parseInt(ratingStr);
          if (rating < 1 || rating > 5) errorMessage = "Rating must be between 1 and 5.";
          else if (comment == null || comment.trim().isEmpty()) errorMessage = "Comment cannot be empty.";
          else {
            boolean added = travelService.addComment(placeId, token, rating, comment);
            if (added) successMessage = "Comment added successfully!";
            else errorMessage = "Failed to add comment.";
          }
        } catch (Exception e) {
          errorMessage = "Invalid rating.";
        }
      } else {
        errorMessage = "Login required to comment.";
      }
    }

    // Handle update/delete
    if ("POST".equalsIgnoreCase(request.getMethod()) && "guide".equals(role) && request.getParameter("action") != null) {
      List<Place> places = travelService.getAllPlaces();
      Long guideId = null;
      for (Place p : places) {
        if (p.getId().equals(placeId) && p.getGuide() != null) {
          guideId = p.getGuide().getId();
          break;
        }
      }

      if (guideId != null) {
        if ("update".equals(request.getParameter("action"))) {
          String newName = request.getParameter("name");
          String newDescription = request.getParameter("description");
          String imageData = request.getParameter("imageData");

          boolean updated = travelService.updatePlace(token, placeId, newName, newDescription, guideId);
          if (updated && imageData != null && !imageData.trim().isEmpty()) {
            travelService.addImage(placeId, imageData, "Updated image", guideId, token);
          }
          statusMessage = updated ? "Place updated successfully." : "Failed to update place.";
        } else if ("delete".equals(request.getParameter("action"))) {
          boolean deleted = travelService.deletePlace(placeId, guideId, token);
          if (deleted) {
            response.sendRedirect("index.jsp?message=Place deleted successfully");
            return;
          } else {
            statusMessage = "Failed to delete place.";
          }
        }
      } else {
        statusMessage = "Guide ID not found.";
      }
    }

    imageUrl = travelService.getImageUrlForPlace(placeId);
    commentsRaw = travelService.getCommentsByPlace(placeId);
    imagesRaw = travelService.getImagesByPlace(placeId);

  } catch (Exception e) {
    statusMessage = "Error: " + e.getMessage();
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Place Details</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    .star-rating {
      display: flex;
      flex-direction: row-reverse;
      justify-content: flex-end;
    }

    .star-rating input {
      display: none;
    }

    .star-rating label {
      cursor: pointer;
      width: 30px;
      height: 30px;
      display: block;
      color: #ddd;
      font-size: 24px;
      transition: all 0.3s;
    }

    .star-rating label:before {
      content: '\2605';
    }

    .star-rating input:checked ~ label,
    .star-rating label:hover,
    .star-rating label:hover ~ label {
      color: #fbbf24;
    }

    .star-rating input:checked ~ label:hover,
    .star-rating input:checked ~ label:hover ~ label,
    .star-rating label:hover ~ input:checked ~ label {
      color: #f59e0b;
    }
  </style>
</head>
<body class="bg-gray-100 p-10 font-sans">
<div class="max-w-4xl mx-auto bg-white shadow-xl rounded-xl p-8">
  <h1 class="text-3xl font-bold text-indigo-600 mb-6"><%= name %></h1>
  <p class="text-gray-700 mb-2"><strong>Description:</strong> <%= description %></p>
  <p class="text-gray-700 mb-4"><strong>Guide:</strong> <%= guideName %></p>

  <% if (statusMessage != null) { %>
  <div class="mb-4 p-3 rounded text-white <%= statusMessage.contains("success") ? "bg-green-500" : "bg-red-500" %>">
    <%= statusMessage %>
  </div>
  <% } %>

  <!-- Image Section -->
  <div class="mb-6">
    <h2 class="text-xl font-semibold text-gray-800 mb-2">Images</h2>
    <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
    <img src="<%= imageUrl %>" class="rounded w-64 h-64 object-cover">
    <% } else { %>
    <p class="text-gray-400 italic">No image available.</p>
    <% } %>
  </div>

  <!-- Guide Edit Form -->
  <% if ("guide".equals(role)) { %>
  <form method="post" class="space-y-4">
    <input type="hidden" name="action" value="update">
    <div>
      <label>Name</label>
      <input name="name" value="<%= name %>" class="w-full border px-4 py-2 rounded" required>
    </div>
    <div>
      <label>Description</label>
      <textarea name="description" class="w-full border px-4 py-2 rounded" rows="3" required><%= description %></textarea>
    </div>
    <div>
      <label>Optional Image (URL or base64)</label>
      <input name="imageData" class="w-full border px-4 py-2 rounded">
    </div>
    <div class="flex gap-4">
      <button class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700" type="submit">Update</button>
    </div>
  </form>
  <form method="post" onsubmit="return confirm('Are you sure?')">
    <input type="hidden" name="action" value="delete">
    <button class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700" type="submit">Delete</button>
  </form>
</div>
<% } %>

<!-- Comments Table -->
<div class="mt-10">
  <h2 class="text-xl font-bold mb-3">Comments</h2>
  <table class="w-full border bg-white text-sm rounded shadow">
    <thead>
    <tr class="bg-gray-100">
      <th class="p-2">User</th>
      <th class="p-2">Rating</th>
      <th class="p-2">Comment</th>
    </tr>
    </thead>
    <tbody>
    <% if (commentsRaw != null && !commentsRaw.equals("No comments")) {
      String[] lines = commentsRaw.split("\n");
      for (String line : lines) {
        String user = line.split("traveler:")[1].split(",rating:")[0];
        int stars = Integer.parseInt(line.split("rating:")[1].split(",comment:")[0]);
        String comment = line.split("comment:")[1];
    %>
    <tr>
      <td class="p-2"><%= user %></td>
      <td class="p-2 text-yellow-400">
        <% for (int i = 1; i <= 5; i++) { %>
        <i class="fas fa-star <%= i <= stars ? "" : "text-gray-300" %>"></i>
        <% } %>
      </td>
      <td class="p-2"><%= comment %></td>
    </tr>
    <% }} else { %>
    <tr><td colspan="3" class="text-center text-gray-400 p-4">No comments</td></tr>
    <% } %>
    </tbody>
  </table>
</div>

<!-- Comment Form -->
<div class="mt-8">
  <h3 class="text-lg font-medium mb-2">Leave a comment</h3>
  <form method="post" class="space-y-3">
    <div>
      <label class="block mb-2">Rating</label>
      <div class="star-rating">
        <input type="radio" id="star5" name="rating" value="5" />
        <label for="star5" title="5 stars"></label>
        <input type="radio" id="star4" name="rating" value="4" />
        <label for="star4" title="4 stars"></label>
        <input type="radio" id="star3" name="rating" value="3" />
        <label for="star3" title="3 stars"></label>
        <input type="radio" id="star2" name="rating" value="2" />
        <label for="star2" title="2 stars"></label>
        <input type="radio" id="star1" name="rating" value="1" />
        <label for="star1" title="1 star"></label>
      </div>
    </div>
    <div>
      <label>Comment</label>
      <textarea name="comment" class="w-full px-3 py-2 rounded border" rows="3" required></textarea>
    </div>
    <% if (!errorMessage.isEmpty()) { %>
    <p class="text-red-500"><%= errorMessage %></p>
    <% } %>
    <% if (!successMessage.isEmpty()) { %>
    <p class="text-green-500"><%= successMessage %></p>
    <% } %>
    <button class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Submit</button>
  </form>
</div>

<div class="mt-6">
  <a href="index.jsp" class="text-indigo-600 hover:underline">&larr; Back to Home</a>
</div>
</div>

<script>
  // Optional: Add some visual feedback when stars are clicked
  document.addEventListener('DOMContentLoaded', function() {
    const starInputs = document.querySelectorAll('input[name="rating"]');

    starInputs.forEach(input => {
      input.addEventListener('change', function() {
        // You can add additional feedback here if needed
        console.log('Rating selected:', this.value);
      });
    });
  });
</script>

</body>
</html>