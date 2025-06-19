<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="com.travelclient.generated.Place" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>View Places</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    .gradient-bg {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    .table-container {
      max-height: 400px;
      overflow-y: auto;
    }
  </style>
</head>
<body class="font-sans bg-gray-50">
<div class="min-h-screen flex items-center justify-center p-4">
  <div class="w-full max-w-4xl">
    <!-- View Places Card -->
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
      <!-- Gradient Header -->
      <div class="gradient-bg py-8 px-6 text-center">
        <h1 class="text-3xl font-bold text-white">Danh sách địa điểm</h1>
        <p class="text-white opacity-90 mt-2">Xem tất cả các địa điểm du lịch</p>
      </div>

      <!-- Places Table -->
      <div class="px-8 py-10">
        <%
          String message = null;
          String token = (String) session.getAttribute("token");
          String role = (String) session.getAttribute("role");

          if (token == null) {
            response.sendRedirect("login.jsp");
          } else {
            try {
              URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
              QName qName = new QName("http://service.travel.com/", "TravelServiceService");
              Service service = Service.create(wsdlURL, qName);
              TravelService travelService = service.getPort(TravelService.class);
              List<Place> places = travelService.getAllPlaces();
              if (places == null || places.isEmpty()) {
                message = "Không có địa điểm nào.";
              }
              pageContext.setAttribute("places", places);
            } catch (Exception e) {
              message = "Lỗi: " + e.getMessage();
              e.printStackTrace();
            }
          }
        %>
        <% if (message != null) { %>
        <p class="text-center mb-6 font-medium text-red-500"><%= message %></p>
        <% } %>
        <% if (pageContext.getAttribute("places") != null) { %>
        <div class="table-container">
          <table class="w-full text-left border-collapse">
            <thead>
            <tr class="bg-gray-100">
              <th class="p-3 font-semibold text-gray-700">Tên địa điểm</th>
              <th class="p-3 font-semibold text-gray-700">Mô tả</th>
              <th class="p-3 font-semibold text-gray-700">Hướng dẫn viên</th>
            </tr>
            </thead>
            <tbody>
            <% for (Place place : (List<Place>) pageContext.getAttribute("places")) { %>
            <tr class="border-b hover:bg-gray-50">
              <td class="p-3 text-gray-800"><%= place.getName() != null ? place.getName() : "N/A" %></td>
              <td class="p-3 text-gray-800"><%= place.getDescription() != null ? place.getDescription() : "N/A" %></td>
              <td class="p-3 text-gray-800">
                <%= place.getGuide() != null && place.getGuide().getUsername() != null ?
                        place.getGuide().getUsername() : "N/A" %>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } %>

        <!-- Back to Home -->
        <div class="mt-8 text-center">
          <a href="index.jsp" class="font-medium text-indigo-600 hover:text-indigo-500">
            Quay lại trang chủ
          </a>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>