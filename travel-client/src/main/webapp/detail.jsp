```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<% response.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Place Details</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #4a90e2 0%, #8e44ad 100%);
      background-size: 200% 200%;
      animation: gradientShift 15s ease infinite;
    }
    @keyframes gradientShift {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }
    .glass-card {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.2);
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
      border-radius: 1.5rem;
    }
    .fade-in {
      animation: fadeIn 0.6s ease-out;
    }
    @keyframes fadeIn {
      0% { opacity: 0; transform: translateY(20px); }
      100% { opacity: 1; transform: translateY(0); }
    }
    .image-gallery img {
      max-width: 200px;
      max-height: 200px;
      object-fit: cover;
      cursor: pointer;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      border-radius: 0.75rem;
    }
    .image-gallery img:hover {
      transform: scale(1.05);
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    }
    .modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.9);
      z-index: 1000;
      align-items: center;
      justify-content: center;
    }
    .modal-content {
      max-width: 90vw;
      max-height: 90vh;
      object-fit: contain;
      border-radius: 1rem;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    }
    .close {
      position: absolute;
      top: 1rem;
      right: 1.5rem;
      font-size: 2rem;
      color: #fff;
      cursor: pointer;
      transition: color 0.3s ease;
    }
    .close:hover {
      color: #ff4d4d;
    }
    .info-box {
      background: rgba(255, 255, 255, 0.05);
      border-left: 4px solid #4a90e2;
      padding: 1rem;
      border-radius: 0.5rem;
    }
    .comment-table {
      max-height: 400px;
      overflow-y: auto;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 1rem;
      padding: 1rem;
      box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.2);
    }
    .comment-table table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0 0.75rem;
    }
    .comment-table th {
      background: rgba(0, 0, 0, 0.3);
      color: #e5e7eb;
      font-weight: 600;
      padding: 1rem;
      position: sticky;
      top: 0;
      z-index: 10;
      border-radius: 0.5rem 0.5rem 0 0;
    }
    .comment-table td {
      background: rgba(255, 255, 255, 0.05);
      padding: 1rem;
      color: #d1d5db;
      transition: background 0.3s ease;
    }
    .comment-table tr:hover td {
      background: rgba(255, 255, 255, 0.15);
    }
    .comment-table .rating-stars {
      display: flex;
      gap: 0.25rem;
      color: #facc15;
    }
    .error-message {
      color: #ff4d4d;
      font-size: 0.9rem;
      margin-top: 0.5rem;
    }
    .success-message {
      color: #4ade80;
      font-size: 0.9rem;
      margin-top: 0.5rem;
    }
  </style>
</head>
<body class="font-sans flex items-center justify-center min-h-screen p-4">
<div class="w-full max-w-5xl">
  <div class="glass-card p-8 text-white fade-in">
    <div class="text-center mb-8">
      <h1 class="text-4xl font-extrabold tracking-wide">Place Details</h1>
      <div class="w-16 h-1 bg-white mx-auto mt-2 rounded-full"></div>
    </div>
    <%
      Long placeId = Long.parseLong(request.getParameter("placeId"));
      String placeName = "";
      String placeDescription = "";
      String guideName = "";
      String imagesData = "";
      String commentsData = "";
      String errorMessage = "";
      String successMessage = "";
      String token = (String) session.getAttribute("token"); // Get token from session

      try {
        URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
        QName qName = new QName("http://service.travel.com/", "TravelServiceService");
        Service service = Service.create(wsdlURL, qName);
        TravelService travelService = service.getPort(TravelService.class);

        // Handle comment submission
        if ("POST".equalsIgnoreCase(request.getMethod())) {
          String ratingStr = request.getParameter("rating");
          String comment = request.getParameter("comment");
          if (token != null) {
            try {
              int rating = Integer.parseInt(ratingStr);
              if (rating < 1 || rating > 5) {
                errorMessage = "Rating must be between 1 and 5.";
              } else if (comment == null || comment.trim().isEmpty()) {
                errorMessage = "Comment cannot be empty.";
              } else {
                boolean success = travelService.addComment(placeId, token, rating, comment);
                if (success) {
                  successMessage = "Comment added successfully!";
                } else {
                  errorMessage = "Failed to add comment. Please try again.";
                }
              }
            } catch (NumberFormatException e) {
              errorMessage = "Invalid rating value.";
            }
          } else {
            errorMessage = "You need to log in to comment.";
          }
        }

        // Get place details
        String placeDetails = travelService.getPlaceDetails(placeId);
        if (placeDetails != null && !placeDetails.startsWith("error")) {
          String[] details = placeDetails.split(",");
          for (String detail : details) {
            if (detail.startsWith("name:")) {
              placeName = detail.split("name:")[1];
            } else if (detail.startsWith("description:")) {
              placeDescription = detail.split("description:")[1];
            } else if (detail.startsWith("guide:")) {
              guideName = detail.split("guide:")[1];
            }
          }
        } else {
          out.println("<p class='text-red-300 text-center'>Error: " + (placeDetails != null ? placeDetails : "Unable to fetch data") + "</p>");
        }

        // Get images
        imagesData = travelService.getImagesByPlace(placeId);
        // Get comments
        commentsData = travelService.getCommentsByPlace(placeId);
      } catch (Exception e) {
        out.println("<p class='text-red-300 text-center'>Error: " + e.getMessage() + "</p>");
      }
    %>
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Place info and comments -->
      <div class="space-y-6 col-span-2">
        <div class="info-box">
          <h2 class="text-2xl font-semibold mb-2"><%= placeName %></h2>
          <p class="text-gray-200 leading-relaxed mb-2"><%= placeDescription %></p>
          <p class="text-gray-300"><strong>Guide:</strong> <%= guideName %></p>
        </div>
        <!-- Comments table -->
        <div class="info-box">
          <h3 class="text-xl font-medium mb-4">Comments</h3>
          <div class="comment-table">
            <table>
              <thead>
              <tr>
                <th>User</th>
                <th>Rating</th>
                <th>Comment</th>
              </tr>
              </thead>
              <tbody>
              <% if (commentsData != null && !commentsData.equals("No comments")) {
                String[] lines = commentsData.split("\n");
                for (String line : lines) {
                  if (!line.trim().isEmpty()) {
                    String traveler = line.split("traveler:")[1].split(",rating:")[0];
                    String rating = line.split("rating:")[1].split(",comment:")[0];
                    String comment = line.split("comment:")[1];
                    int ratingValue = Integer.parseInt(rating);
              %>
              <tr>
                <td><%= traveler %></td>
                <td class="rating-stars">
                  <% for (int i = 1; i <= 5; i++) { %>
                  <i class="fas fa-star <%= i <= ratingValue ? "text-yellow-400" : "text-gray-400" %>"></i>
                  <% } %>
                </td>
                <td><%= comment %></td>
              </tr>
              <% }
              }
              } else { %>
              <tr>
                <td colspan="3" class="text-gray-400 text-center">No comments yet.</td>
              </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>
        <!-- Comment form -->
        <div class="info-box">
          <h3 class="text-xl font-medium mb-4">Add Comment</h3>
          <form method="post" accept-charset="UTF-8" class="space-y-4">
            <div>
              <label for="rating" class="block text-gray-200 mb-1">Rating (1-5):</label>
              <input type="number" id="rating" name="rating" min="1" max="5" required
                     class="w-full p-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:border-blue-500">
            </div>
            <div>
              <label for="comment" class="block text-gray-200 mb-1">Comment:</label>
              <textarea id="comment" name="comment" required
                        class="w-full p-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:border-blue-500"
                        rows="4"></textarea>
            </div>
            <button type="submit"
                    class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-6 rounded-lg transition duration-300">
              <i class="fas fa-comment mr-2"></i> Submit Comment
            </button>
            <% if (!errorMessage.isEmpty()) { %>
            <p class="error-message"><%= errorMessage %></p>
            <% } %>
            <% if (!successMessage.isEmpty()) { %>
            <p class="success-message"><%= successMessage %></p>
            <% } %>
          </form>
        </div>
        <div class="text-center">
          <a href="index.jsp" class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-6 rounded-lg transition duration-300">
            <i class="fas fa-arrow-left mr-2"></i> Back to Home
          </a>
        </div>
      </div>
      <!-- Images -->
      <div>
        <h3 class="text-xl font-medium mb-4 text-center">Images</h3>
        <div class="image-gallery flex flex-wrap justify-center gap-4">
          <% if (imagesData != null && !imagesData.trim().isEmpty()) {
            String[] lines = imagesData.split("\n");
            for (String line : lines) {
              if (line.contains("URL: ") || line.contains("Base64 Image")) {
                String imgUrl = line.contains("URL: ") ? line.split("URL: ")[1].split(",")[0].trim() : "";
                String imgData = line.contains("Base64 Image") ? line.split("Description: ")[0].replace("Base64 Image", "").trim() : "";
                if (!imgUrl.isEmpty() || !imgData.isEmpty()) {
                  String src = imgUrl.isEmpty() ? imgData : imgUrl;
          %>
          <img src="<%= src %>" onclick="openModal('<%= src %>')" alt="Place image" class="hover:shadow-lg">
          <% }
          }
          }
          } else { %>
          <p class="text-gray-400 text-center">No images available.</p>
          <% } %>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <div id="imageModal" class="modal">
      <span class="close" onclick="closeModal()">×</span>
      <img class="modal-content" id="modalImage">
    </div>
  </div>
</div>
<script>
  function openModal(src) {
    const modal = document.getElementById('imageModal');
    const modalImage = document.getElementById('modalImage');
    modalImage.src = src;
    modal.style.display = "flex";
  }

  function closeModal() {
    const modal = document.getElementById('imageModal');
    modal.style.display = "none";
  }

  window.onclick = function(event) {
    const modal = document.getElementById('imageModal');
    if (event.target == modal) {
      modal.style.display = "none";
    }
  }
</script>
</body>
</html>
```