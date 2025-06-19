<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.*" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Optional" %>
<%
    String token = (String) session.getAttribute("token");
    String role = (String) session.getAttribute("role");

    if (token == null || !"guide".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String newName = request.getParameter("newName");
        String description = request.getParameter("description");
        String imageData = request.getParameter("imageData");

        try {
            URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
            QName qName = new QName("http://service.travel.com/", "TravelServiceService");
            Service service = Service.create(wsdlURL, qName);
            TravelService travelService = service.getPort(TravelService.class);

            List<Place> places = travelService.getAllPlaces();
            Optional<Place> match = places.stream()
                    .filter(p -> p.getName().equalsIgnoreCase(name))
                    .findFirst();

            if (match.isPresent()) {
                Place place = match.get();
                Long guideId = place.getGuide().getId();
                boolean updated = travelService.updatePlace(token, place.getId(), newName, description, guideId);

                // Upload image if provided
                if (imageData != null && !imageData.trim().isEmpty()) {
                    travelService.addImage(place.getId(), imageData, "Cập nhật ảnh", guideId, token);
                }

                message = updated ? "Cập nhật địa điểm thành công!" : "Cập nhật thất bại.";
            } else {
                message = "Không tìm thấy địa điểm có tên: " + name;
            }

        } catch (Exception e) {
            message = "Lỗi: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Cập nhật địa điểm</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        .hidden { display: none; }
        .error-message { color: #ef4444; font-size: 0.875rem; margin-top: 4px; }
    </style>
</head>
<body class="bg-gray-100">
<div class="min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="gradient-bg py-6 px-6 text-center">
                <h1 class="text-3xl font-bold text-white">Cập nhật địa điểm</h1>
                <p class="text-white opacity-90 mt-2">Chỉnh sửa thông tin và thêm ảnh (tùy chọn)</p>
            </div>
            <div class="px-8 py-10">
                <% if (message != null) { %>
                <p class="text-center mb-6 font-medium <%= message.contains("thành công") ? "text-green-500" : "text-red-500" %>"><%= message %></p>
                <% } %>

                <form method="post" enctype="application/x-www-form-urlencoded" class="space-y-6">
                    <label class="block font-medium text-gray-700">Tên cũ:</label>
                    <input type="text" name="name" class="w-full p-3 border rounded-lg input-field" placeholder="Tên cũ" required>

                    <label class="block font-medium text-gray-700">Tên mới:</label>
                    <input type="text" name="newName" class="w-full p-3 border rounded-lg input-field" required>

                    <label class="block font-medium text-gray-700">Mô tả mới:</label>
                    <textarea name="description" class="w-full p-3 border rounded-lg input-field" rows="4" required></textarea>

                    <label class="block font-medium text-gray-700">URL ảnh (tùy chọn):</label>
                    <input type="url" id="imageUrl" class="w-full p-3 border rounded-lg input-field" oninput="previewImageFromUrl(this.value)">

                    <label class="block font-medium text-gray-700">Hoặc chọn ảnh từ máy (tùy chọn):</label>
                    <input type="file" id="imageFile" accept="image/*" class="w-full p-3 border rounded-lg input-field" onchange="previewImageFromFile(this)">

                    <input type="hidden" name="imageData" id="imageData">
                    <p id="errorMessage" class="error-message hidden"></p>
                    <img id="imagePreview" class="preview-img hidden" alt="Preview">

                    <button type="submit" class="w-full gradient-bg text-white py-3 px-4 rounded-lg font-medium hover:opacity-90 flex items-center justify-center">
                        <i class="fas fa-sync-alt mr-2"></i> Cập nhật
                    </button>
                </form>
                <div class="text-center mt-6">
                    <a href="index.jsp" class="text-indigo-600 hover:underline">← Trở lại trang chủ</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function previewImageFromUrl(url) {
        const img = document.getElementById('imagePreview');
        const error = document.getElementById('errorMessage');
        const input = document.getElementById('imageData');
        const fileInput = document.getElementById('imageFile');

        img.classList.add('hidden');
        error.classList.add('hidden');
        input.value = '';
        fileInput.value = '';

        if (!url) return;
        const testImg = new Image();
        testImg.onload = function () {
            img.src = url;
            img.classList.remove('hidden');
            input.value = url;
        };
        testImg.onerror = function () {
            error.textContent = 'Không thể tải ảnh từ URL.';
            error.classList.remove('hidden');
        };
        testImg.src = url;
    }

    function previewImageFromFile(input) {
        const file = input.files[0];
        const preview = document.getElementById('imagePreview');
        const error = document.getElementById('errorMessage');
        const imageDataInput = document.getElementById('imageData');
        const imageUrlInput = document.getElementById('imageUrl');

        preview.classList.add('hidden');
        error.classList.add('hidden');
        imageDataInput.value = '';
        imageUrlInput.value = '';

        if (file && file.type.startsWith('image/')) {
            if (file.size > 5 * 1024 * 1024) {
                error.textContent = 'Ảnh quá lớn. Dưới 5MB thôi nha!';
                error.classList.remove('hidden');
                return;
            }

            const reader = new FileReader();
            reader.onload = function (e) {
                preview.src = e.target.result;
                preview.classList.remove('hidden');
                imageDataInput.value = e.target.result;
            };
            reader.readAsDataURL(file);
        } else {
            error.textContent = 'Vui lòng chọn file ảnh hợp lệ.';
            error.classList.remove('hidden');
        }
    }
</script>
</body>
</html>
