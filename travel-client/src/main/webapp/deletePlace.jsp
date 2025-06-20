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
                boolean deleted = travelService.deletePlace(place.getId(), place.getGuide().getId(), token);
                message = deleted ? "Đã xóa thành công!" : "Xóa thất bại.";
            } else {
                message = "Không tìm thấy địa điểm có tên: " + name;
            }

        } catch (Exception e) {
            message = "Lỗi: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Place</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-10">
<div class="max-w-md mx-auto bg-white p-6 rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-4 text-center">Xóa địa điểm</h2>
    <% if (message != null) { %>
    <p class="text-center text-red-500 font-medium mb-4"><%= message %></p>
    <% } %>
    <form method="post">
        <label>Tên địa điểm cần xóa:</label>
        <input type="text" name="name" required class="w-full p-2 border mb-4 rounded">
        <button type="submit" class="w-full bg-red-600 text-white py-2 rounded hover:bg-red-700">Xóa</button>
    </form>
    <div class="text-center mt-4">
        <a href="index.jsp" class="text-indigo-600 hover:underline">← Trở lại trang chủ</a>
    </div>
</div>
</body>
</html>
