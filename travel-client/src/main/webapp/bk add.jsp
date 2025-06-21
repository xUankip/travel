<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Place</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    .gradient-bg {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    .input-field {
      transition: border-color 0.3s ease;
    }
    .input-field:focus {
      border-color: #667eea;
      outline: none;
    }
    .preview-img {
      max-width: 100%;
      max-height: 200px;
      object-fit: contain;
      margin-top: 10px;
      border: 1px solid #e5e7eb;
      border-radius: 4px;
    }
    .hidden {
      display: none;
    }
    .error-message {
      color: #ef4444;
      font-size: 0.875rem;
      margin-top: 4px;
    }
  </style>
</head>
<body class="font-sans bg-gray-50">
<div class="min-h-screen flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
      <div class="gradient-bg py-8 px-6 text-center">
        <h1 class="text-3xl font-bold text-white">Thêm địa điểm</h1>
        <p class="text-white opacity-90 mt-2">Nhập thông tin địa điểm mới</p>
      </div>
      <div class="px-8 py-10">
        <%
          String message = null;
          String token = (String) session.getAttribute("token");
          String role = (String) session.getAttribute("role");

          if (token == null || !"guide".equals(role)) {
            response.sendRedirect("login.jsp");
          } else if (request.getMethod().equalsIgnoreCase("POST")) {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String imageUrl = request.getParameter("imageUrl");
            try {
              URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
              QName qName = new QName("http://service.travel.com/", "TravelServiceService");
              Service service = Service.create(wsdlURL, qName);
              TravelService travelService = service.getPort(TravelService.class);
              boolean success = travelService.addPlace(token, name, description, imageUrl);
              message = success ? "Thêm địa điểm thành công!" : "Thêm địa điểm thất bại.";
            } catch (Exception e) {
              message = "Lỗi: " + e.getMessage();
              e.printStackTrace();
            }
          }
        %>
        <% if (message != null) { %>
        <p class="text-center mb-6 font-medium <%= message.startsWith("Thêm địa điểm thành công") ? "text-green-500" : "text-red-500" %>"><%= message %></p>
        <% } %>
        <form action="addPlace.jsp" method="post" class="space-y-6">
          <!-- Name Field -->
          <div>
            <label for="name" class="block text-gray-700 font-medium mb-1">Tên địa điểm</label>
            <input
                    type="text"
                    id="name"
                    name="name"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg"
                    required
            />
          </div>
          <!-- Description Field -->
          <div>
            <label for="description" class="block text-gray-700 font-medium mb-1">Mô tả</label>
            <textarea
                    id="description"
                    name="description"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg"
                    rows="4"
                    required
            ></textarea>
          </div>
          <!-- Image URL Field -->
          <div>
            <label for="imageUrl" class="block text-gray-700 font-medium mb-1">Link ảnh (tùy chọn)</label>
            <input
                    type="url"
                    id="imageUrl"
                    name="imageUrl"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg"
                    oninput="previewImage(this.value)"
            />
            <p id="errorMessage" class="error-message hidden"></p>
            <img id="imagePreview" class="preview-img hidden" alt="Image Preview" />
          </div>
          <!-- Submit Button -->
          <button
                  type="submit"
                  class="w-full gradient-bg text-white py-3 px-4 rounded-lg font-medium hover:opacity-90 transition duration-300 flex items-center justify-center"
          >
            <i class="fas fa-plus mr-2"></i> Thêm địa điểm
          </button>
        </form>
        <div class="mt-8 text-center">
          <a href="index.jsp" class="font-medium text-indigo-600 hover:text-indigo-500">
            Quay lại trang chủ
          </a>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
  function previewImage(url) {
    const img = document.getElementById('imagePreview');
    const errorMessage = document.getElementById('errorMessage');

    // Reset state
    img.classList.add('hidden');
    errorMessage.classList.add('hidden');
    errorMessage.textContent = '';

    if (!url) {
      return;
    }

    // Create a new image to test loading
    const testImg = new Image();
    testImg.onload = function() {
      img.src = url;
      img.classList.remove('hidden');
    };
    testImg.onerror = function() {
      errorMessage.textContent = 'Không thể tải ảnh. Vui lòng kiểm tra URL.';
      errorMessage.classList.remove('hidden');
    };
    testImg.src = url;
  }
</script>
</body>
</html>