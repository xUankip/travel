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
  Long guideId = null;

  try {
    URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
    QName qName = new QName("http://service.travel.com/", "TravelServiceService");
    Service service = Service.create(wsdlURL, qName);
    TravelService travelService = service.getPort(TravelService.class);

    // Fetch details
    String detail = travelService.getPlaceDetails(placeId);
    if (detail != null && !detail.startsWith("error")) {
      String[] fields = detail.split(",");
      for (String field : fields) {
        if (field.startsWith("name:")) name = field.substring(5);
        else if (field.startsWith("description:")) description = field.substring(12);
        else if (field.startsWith("guide:")) guideName = field.substring(6);
      }
    }

    // Get guideId for this place
    List<Place> allPlaces = travelService.getAllPlaces();
    for (Place p : allPlaces) {
      if (p.getId().equals(placeId) && p.getGuide() != null) {
        guideId = p.getGuide().getId();
        break;
      }
    }

    // Comment submit
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

    // Update / Delete
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null && "guide".equals(role)) {
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

    // Get image & comments
    imageUrl = travelService.getImageUrlForPlace(placeId);
    commentsRaw = travelService.getCommentsByPlace(placeId);
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
    .star-rating input { display: none; }
    .star-rating label {
      cursor: pointer;
      width: 30px;
      height: 30px;
      display: block;
      color: #ddd;
      font-size: 24px;
      transition: all 0.3s;
    }
    .star-rating label:before { content: '\2605'; }
    .star-rating input:checked ~ label,
    .star-rating label:hover,
    .star-rating label:hover ~ label {
      color: #fbbf24;
    }

    /* Custom button styles */
    .btn-update {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      transition: all 0.3s ease;
      box-shadow: 0 4px 15px 0 rgba(102, 126, 234, 0.3);
    }

    .btn-update:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px 0 rgba(102, 126, 234, 0.4);
    }

    .btn-delete {
      background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
      transition: all 0.3s ease;
      box-shadow: 0 4px 15px 0 rgba(255, 107, 107, 0.3);
    }

    .btn-delete:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px 0 rgba(255, 107, 107, 0.4);
    }

    .form-section {
      background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
      border: 1px solid #e2e8f0;
    }
  </style>
</head>
<body class="bg-gray-100 p-10 font-sans">
<div class="max-w-4xl mx-auto bg-white shadow-xl rounded-xl p-8">
  <!-- Header Section -->
  <div class="flex justify-between items-start mb-6">
    <div class="flex-1">
      <h1 class="text-3xl font-bold text-indigo-600 mb-2"><%= name %></h1>
      <p class="text-gray-700 mb-2"><strong>Description:</strong> <%= description %></p>
      <p class="text-gray-700"><strong>Guide:</strong> <%= guideName %></p>
    </div>

    <!-- Action Buttons for Guides -->
    <% if ("guide".equals(role)) { %>
    <div class="flex gap-3 ml-6">
      <button onclick="toggleEditForm()" class="btn-update text-white px-6 py-3 rounded-lg font-semibold inline-flex items-center">
        <i class="fas fa-edit mr-2"></i>
        Update
      </button>
      <form method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this place? This action cannot be undone!')">
        <input type="hidden" name="action" value="delete">
        <button type="submit" class="btn-delete text-white px-6 py-3 rounded-lg font-semibold inline-flex items-center">
          <i class="fas fa-trash mr-2"></i>
          Delete
        </button>
      </form>
    </div>
    <% } %>
  </div>

  <% if (statusMessage != null) { %>
  <div class="mb-6 p-4 rounded-lg text-white <%= statusMessage.contains("success") ? "bg-green-500" : "bg-red-500" %>">
    <i class="fas <%= statusMessage.contains("success") ? "fa-check-circle" : "fa-exclamation-triangle" %> mr-2"></i>
    <%= statusMessage %>
  </div>
  <% } %>

  <!-- Image Section -->
  <div class="mb-8">
    <h2 class="text-xl font-semibold text-gray-800 mb-4">Images</h2>
    <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
    <div class="relative inline-block">
      <img src="<%= imageUrl %>" class="rounded-lg w-64 h-64 object-cover shadow-lg">
    </div>
    <% } else { %>
    <div class="w-64 h-64 bg-gray-200 rounded-lg flex items-center justify-center">
      <div class="text-center text-gray-400">
        <i class="fas fa-image text-4xl mb-2"></i>
        <p class="text-sm">No image available</p>
      </div>
    </div>
    <% } %>
  </div>

  <!-- Guide Edit Form (Hidden by default) -->
  <% if ("guide".equals(role)) { %>
  <div id="editForm" class="form-section rounded-lg p-6 mb-8" style="display: none;">
    <h3 class="text-lg font-semibold text-gray-800 mb-4">
      <i class="fas fa-edit mr-2 text-indigo-600"></i>
      Edit Place Details
    </h3>
    <form method="post" class="space-y-4">
      <input type="hidden" name="action" value="update">

      <div class="grid md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            <i class="fas fa-map-marker-alt mr-1"></i>
            Place Name
          </label>
          <input name="name" value="<%= name %>" class="w-full border border-gray-300 px-4 py-3 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" required>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            <i class="fas fa-image mr-1"></i>
            Image (URL or base64)
          </label>
          <input name="imageData" class="w-full border border-gray-300 px-4 py-3 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="Optional image URL">
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          <i class="fas fa-align-left mr-1"></i>
          Description
        </label>
        <textarea name="description" class="w-full border border-gray-300 px-4 py-3 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" rows="4" required><%= description %></textarea>
      </div>

      <div class="flex justify-end gap-4 pt-4">
        <button type="button" onclick="toggleEditForm()" class="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium">
          <i class="fas fa-times mr-2"></i>
          Cancel
        </button>
        <button type="submit" class="btn-update text-white px-6 py-3 rounded-lg font-semibold">
          <i class="fas fa-save mr-2"></i>
          Save Changes
        </button>
      </div>
    </form>
  </div>
  <% } %>

  <!-- Comments Table -->
  <div class="mt-10">
    <h2 class="text-xl font-bold mb-4 text-gray-800">
      <i class="fas fa-comments mr-2 text-indigo-600"></i>
      Reviews & Comments
    </h2>
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rating</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Comment</th>
        </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
        <% if (commentsRaw != null && !commentsRaw.equals("No comments")) {
          String[] lines = commentsRaw.split("\n");
          for (String line : lines) {
            String user = line.split("traveler:")[1].split(",rating:")[0];
            int stars = Integer.parseInt(line.split("rating:")[1].split(",comment:")[0]);
            String comment = line.split("comment:")[1];
        %>
        <tr class="hover:bg-gray-50">
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center mr-3">
                <i class="fas fa-user text-indigo-600 text-sm"></i>
              </div>
              <span class="text-sm font-medium text-gray-900"><%= user %></span>
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="flex items-center">
              <% for (int i = 1; i <= 5; i++) { %>
              <i class="fas fa-star text-sm <%= i <= stars ? "text-yellow-400" : "text-gray-300" %>"></i>
              <% } %>
              <span class="ml-2 text-sm text-gray-600">(<%= stars %>/5)</span>
            </div>
          </td>
          <td class="px-6 py-4">
            <p class="text-sm text-gray-900"><%= comment %></p>
          </td>
        </tr>
        <% }} else { %>
        <tr>
          <td colspan="3" class="px-6 py-8 text-center">
            <div class="text-gray-400">
              <i class="fas fa-comment-slash text-4xl mb-2"></i>
              <p>No comments yet. Be the first to review!</p>
            </div>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Comment Form -->
  <div class="mt-8 bg-gray-50 rounded-lg p-6">
    <h3 class="text-lg font-semibold mb-4 text-gray-800">
      <i class="fas fa-pen mr-2 text-indigo-600"></i>
      Leave a Review
    </h3>
    <form method="post" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-3">Rating</label>
        <div class="star-rating">
          <input type="radio" id="star5" name="rating" value="5" required /><label for="star5"></label>
          <input type="radio" id="star4" name="rating" value="4" required /><label for="star4"></label>
          <input type="radio" id="star3" name="rating" value="3" required /><label for="star3"></label>
          <input type="radio" id="star2" name="rating" value="2" required /><label for="star2"></label>
          <input type="radio" id="star1" name="rating" value="1" required /><label for="star1"></label>
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Your Review</label>
        <textarea name="comment" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" rows="4" required placeholder="Share your experience about this place..."></textarea>
      </div>

      <% if (!errorMessage.isEmpty()) { %>
      <div class="p-4 bg-red-50 border-l-4 border-red-400 rounded">
        <p class="text-red-700"><i class="fas fa-exclamation-circle mr-2"></i><%= errorMessage %></p>
      </div>
      <% } %>

      <% if (!successMessage.isEmpty()) { %>
      <div class="p-4 bg-green-50 border-l-4 border-green-400 rounded">
        <p class="text-green-700"><i class="fas fa-check-circle mr-2"></i><%= successMessage %></p>
      </div>
      <% } %>

      <button type="submit" class="bg-indigo-600 text-white px-6 py-3 rounded-lg hover:bg-indigo-700 font-semibold transition-colors">
        <i class="fas fa-paper-plane mr-2"></i>
        Submit Review
      </button>
    </form>
  </div>

  <!-- Navigation -->
  <div class="mt-8 pt-6 border-t">
    <a href="index.jsp" class="inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium">
      <i class="fas fa-arrow-left mr-2"></i>
      Back to Home
    </a>
  </div>
</div>

<script>
  function toggleEditForm() {
    const form = document.getElementById('editForm');
    if (form.style.display === 'none' || form.style.display === '') {
      form.style.display = 'block';
      form.scrollIntoView({ behavior: 'smooth' });
    } else {
      form.style.display = 'none';
    }
  }
</script>

</body>
</html>