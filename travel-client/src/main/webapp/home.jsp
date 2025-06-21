<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="com.travelclient.generated.Place" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%
  response.setCharacterEncoding("UTF-8");

  TravelService travelService = null;
  List<Place> places = null;
  String searchNotice = null;
  try {
    URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
    QName qName = new QName("http://service.travel.com/", "TravelServiceService");
    Service service = Service.create(wsdlURL, qName);
    travelService = service.getPort(TravelService.class);
    String keyword = request.getParameter("q");
    if (keyword != null && !keyword.trim().isEmpty()) {
      String token = (String) session.getAttribute("token");
      places = travelService.searchPlaces(token != null ? token : "", keyword.trim());
      if (places == null || places.isEmpty()) {
        searchNotice = "No results found for \"" + keyword + "\"";
      }
    } else {
      places = travelService.getAllPlaces();
    }    if (places != null) {
      Collections.sort(places, (p1, p2) -> Long.compare(p2.getId(), p1.getId()));
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Travel App</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    html {
      scroll-behavior: smooth;
    }
    .destination-card:hover .destination-image {
      transform: scale(1.05);
    }
    .parallax {
      background-image: url('https://images.unsplash.com/photo-1506929562872-bb421503ef21?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80');
      background-attachment: fixed;
      background-size: cover;
      background-position: center;
    }
  </style>
</head>
<body class="bg-gray-50 font-sans">

<!-- Navbar -->
<nav class="bg-white shadow-lg sticky top-0 z-50">
  <div class="container mx-auto px-4 py-3 flex justify-between items-center">
    <div class="flex items-center space-x-2">
      <i class="fas fa-map-marked-alt text-blue-500 text-2xl"></i>
      <span class="text-xl font-bold text-blue-600">Travel App</span>
    </div>
    <div class="hidden md:flex space-x-6">
      <a href="#" class="text-blue-600 font-medium">Home</a>
      <a href="#destinations" class="text-gray-600 hover:text-blue-600">Destinations</a>
    </div>
    <div>
      <%
        String token = (String) session.getAttribute("token");
        if (token == null) {
      %>
      <a href="login.jsp" class="bg-blue-500 text-white px-4 py-2 rounded-full hover:bg-blue-600">
        Login
      </a>
      <% } else { %>
      <form action="logout.jsp" method="post">
        <button type="submit" class="bg-red-500 text-white px-4 py-2 rounded-full hover:bg-red-600">
          Logout
        </button>
      </form>
      <% } %>
    </div>

  </div>
</nav>

<!-- Hero -->
<section class="h-screen flex items-center justify-center text-white parallax relative">
  <div class="absolute inset-0 bg-black bg-opacity-50"></div>
  <div class="text-center z-10 px-4">
    <h1 class="text-5xl md:text-6xl font-bold mb-6">Discover Your Next Adventure</h1>
    <p class="text-xl md:text-2xl mb-10">Explore top destinations from trusted guides around the world</p>
    <!-- Search Form -->
    <form method="get" action="home.jsp" class="search-box bg-white rounded-full p-2 max-w-3xl mx-auto flex">
      <div class="flex-grow relative">
        <i class="fas fa-search absolute left-4 top-3 text-gray-400"></i>
        <input
                name="q"
                type="text"
                value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>"
                placeholder="Search destinations..."
                class="w-full pl-12 pr-4 py-3 rounded-l-full focus:outline-none text-gray-700">
      </div>
      <button type="submit" class="bg-blue-600 text-white px-6 rounded-r-full hover:bg-blue-700 transition">
        Search
      </button>
    </form>
  </div>
</section>

<!-- Destination Grid -->
<section id="destinations" class="py-16 bg-white">
  <div class="container mx-auto px-4">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-bold text-gray-800 mb-4">Popular Destinations</h2>
      <% if (searchNotice != null) { %>
      <p class="text-red-500 text-lg mb-6"><%= searchNotice %></p>
      <% } %>

    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
      <% if (places != null) {
        for (Place place : places) {
          String imageUrl = travelService.getImageUrlForPlace(place.getId());
      %>
      <a href="detail.jsp?placeId=<%= place.getId() %>" class="destination-card bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-xl transition duration-300">
        <div class="relative overflow-hidden h-60">
          <img src="<%= imageUrl != null ? imageUrl : "https://via.placeholder.com/400x300?text=No+Image" %>"
               class="w-full h-full object-cover destination-image transition duration-500" />
        </div>
        <div class="p-5">
          <h3 class="text-xl font-bold text-gray-800"><%= place.getName() %></h3>
          <p class="text-gray-600 mb-4"><%= place.getDescription() %></p>
          <div class="flex justify-between text-gray-500 text-sm">
            <span>Guide: <%= place.getGuide().getUsername() %></span>
          </div>
        </div>
      </a>
      <% }} else { %>
      <p class="text-center text-gray-500 col-span-full">No destinations available.</p>
      <% } %>
    </div>
  </div>
</section>

</body>
</html>
