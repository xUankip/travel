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
            String imageData = request.getParameter("imageData"); // Base64 data
            try {
              URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
              QName qName = new QName("http://service.travel.com/", "TravelServiceService");
              Service service = Service.create(wsdlURL, qName);
              TravelService travelService = service.getPort(TravelService.class);
              boolean success = travelService.addPlace(token, name, description, imageData);
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
        <form id="addPlaceForm" action="addPlace.jsp" method="post" class="space-y-6">
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
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg"
                    oninput="previewImageFromUrl(this.value)"
            />
          </div>
          <!-- Image File Field -->
          <div>
            <label for="imageFile" class="block text-gray-700 font-medium mb-1">Chọn ảnh từ máy (tùy chọn)</label>
            <input
                    type="file"
                    id="imageFile"
                    accept="image/*"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg"
                    onchange="previewImageFromFile(this)"
            />
            <input type="hidden" id="imageData" name="imageData" />
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
  function previewImageFromUrl(url) {
    const img = document.getElementById('imagePreview');
    const errorMessage = document.getElementById('errorMessage');
    const imageDataInput = document.getElementById('imageData');
    const imageFileInput = document.getElementById('imageFile');

    img.classList.add('hidden');
    errorMessage.classList.add('hidden');
    errorMessage.textContent = '';
    imageDataInput.value = '';
    imageFileInput.value = '';

    if (!url) return;

    const testImg = new Image();
    testImg.onload = function() {
      img.src = url;
      img.classList.remove('hidden');
      imageDataInput.value = url;
    };
    testImg.onerror = function() {
      errorMessage.textContent = 'Không thể tải ảnh từ URL. Vui lòng kiểm tra lại.';
      errorMessage.classList.remove('hidden');
    };
    testImg.src = url;
  }

  function previewImageFromFile(input) {
    const img = document.getElementById('imagePreview');
    const errorMessage = document.getElementById('errorMessage');
    const imageDataInput = document.getElementById('imageData');
    const imageUrlInput = document.getElementById('imageUrl');

    img.classList.add('hidden');
    errorMessage.classList.add('hidden');
    errorMessage.textContent = '';
    imageDataInput.value = '';
    imageUrlInput.value = '';

    if (input.files && input.files[0]) {
      const file = input.files[0];
      if (!file.type.startsWith('image/')) {
        errorMessage.textContent = 'Vui lòng chọn một file ảnh hợp lệ.';
        errorMessage.classList.remove('hidden');
        return;
      }
      if (file.size > 5 * 1024 * 1024) { // Giới hạn 5MB
        errorMessage.textContent = 'File ảnh quá lớn. Vui lòng chọn file dưới 5MB.';
        errorMessage.classList.remove('hidden');
        return;
      }

      const reader = new FileReader();
      reader.onload = function(e) {
        console.log('Base64 length:', e.target.result.length); // Debug
        img.src = e.target.result;
        img.classList.remove('hidden');
        imageDataInput.value = e.target.result; // Gửi base64
      };
      reader.onerror = function() {
        errorMessage.textContent = 'Không thể đọc file ảnh.';
        errorMessage.classList.remove('hidden');
      };
      reader.readAsDataURL(file);
    }
  }
</script>
</body>
</html>