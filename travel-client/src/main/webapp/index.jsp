<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="com.travelclient.generated.Place" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<% response.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Travel App</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #6b46c1, #ed64a6);
            background-size: 200% 200%;
            animation: gradientFlow 15s ease infinite;
            margin: 0;
            min-height: 100vh;
            font-family: 'Arial', sans-serif;
        }
        @keyframes gradientFlow {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 1.5rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            padding: 2rem;
        }
        .glass-header {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 1000;
            padding: 1rem 2rem;
        }
        .fade-in {
            animation: fadeIn 0.8s ease-out;
        }
        @keyframes fadeIn {
            0% { opacity: 0; transform: translateY(30px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .btn {
            transition: all 0.3s ease;
            border-radius: 0.75rem;
        }
        .btn:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }
        .nft-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1.5rem;
            max-width: 90vw;
            margin: 120px auto 0;
            padding: 1rem;
        }
        .nft-card {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 1rem;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
            aspect-ratio: 1 / 1;
            display: flex;
            flex-direction: column;
            text-decoration: none;
            color: inherit;
        }
        .nft-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3);
            background: rgba(255, 255, 255, 0.25);
        }
        .nft-image {
            width: 100%;
            height: 60%;
            object-fit: cover;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .nft-content {
            padding: 1rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .nft-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #e5e7eb;
            margin-bottom: 0.5rem;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .nft-description {
            font-size: 0.9rem;
            color: #d1d5db;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .nft-guide {
            font-size: 0.85rem;
            color: #a0aec0;
            margin-top: 0.5rem;
        }
        .header-link:hover {
            color: #a0aec0;
        }
        .action-btn {
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
        }
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
            margin-top: 2rem;
        }
        .pagination-btn {
            background: rgba(255, 255, 255, 0.1);
            color: #e5e7eb;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .pagination-btn:hover:not(.disabled) {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        .pagination-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .page-number {
            background: rgba(255, 255, 255, 0.1);
            color: #e5e7eb;
            padding: 0.5rem 0.75rem;
            border-radius: 0.5rem;
            margin: 0 0.25rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .page-number:hover:not(.active) {
            background: rgba(255, 255, 255, 0.3);
        }
        .page-number.active {
            background: #6b46c1;
            color: #fff;
            font-weight: bold;
        }
    </style>
</head>
<body class="font-sans flex flex-col min-h-screen">
<!-- Header -->
<header class="">
    <div class="max-w-6xl mx-auto flex justify-between items-center">
        <div class="flex items-center space-x-4">
            <h1 class="text-3xl font-bold text-white">Travel App</h1>
        </div>
        <nav>
            <%
                String token = (String) session.getAttribute("token");
                if (token == null) {
            %>
            <a href="login.jsp" class="text-white text-lg font-medium header-link transition-colors action-btn bg-indigo-600 hover:bg-indigo-700">
                <i class="fas fa-sign-in-alt mr-2"></i> Login
            </a>
            <% } else { %>
            <form action="logout.jsp" method="post" class="inline">
                <button type="submit" class="text-white text-lg font-medium header-link transition-colors action-btn bg-red-600 hover:bg-red-700">
                    <i class="fas fa-sign-out-alt mr-2"></i> Logout
                </button>
            </form>
            <% } %>
        </nav>
    </div>
</header>

<!-- Main Content -->
<main class="flex items-center justify-center flex-grow pt-28">
    <div class="w-full max-w-8xl">
        <div class="glass-card fade-in">
            <h2 class="text-5xl font-extrabold text-center mb-8">Welcome to Travel App</h2>
            <%
                String role = (String) session.getAttribute("role");
                if (role != null) {
            %>
            <p class="text-2xl text-center mb-8">Logged in as: <span class="font-semibold text-indigo-200"><%= role %></span></p>
            <div class="flex flex-col md:flex-row justify-center gap-6 mb-10">
                <% if ("guide".equals(role)) { %>
                <a href="addPlace.jsp" class="btn w-full md:w-auto bg-green-600 text-white text-center py-3 px-8 rounded-lg font-semibold hover:bg-green-700 action-btn">
                    <i class="fas fa-plus mr-2"></i> Add Place
                </a>
                <% } else if ("traveler".equals(role)) { %>
                <a href="search.jsp" class="btn w-full md:w-auto bg-blue-600 text-white text-center py-3 px-8 rounded-lg font-semibold hover:bg-blue-700 action-btn">
                    <i class="fas fa-search mr-2"></i> Search Places
                </a>
                <% } %>
                <!-- New Create Place Button -->

            </div>
            <% } %>

            <!-- Places Grid -->
            <div class="mt-10">
                <h3 class="text-3xl font-bold text-center mb-6">Explore Our Places</h3>
                <%
                    String message = null;
                    TravelService travelService = null;
                    List<Place> places = null;
                    try {
                        URL wsdlURL = new URL("http://localhost:8080/travel?wsdl");
                        QName qName = new QName("http://service.travel.com/", "TravelServiceService");
                        Service service = Service.create(wsdlURL, qName);
                        travelService = service.getPort(TravelService.class);
                        places = travelService.getAllPlaces();

                        // Sort places by newest first (using Long.compare for Long IDs)
                        if (places != null && !places.isEmpty()) {
                            Collections.sort(places, new Comparator<Place>() {
                                @Override
                                public int compare(Place p1, Place p2) {
                                    // Sort by ID descending (newer places have higher IDs)
                                    return Long.compare(p2.getId(), p1.getId());
                                    // Alternatively, if you have a createdAt field (Date):
                                    // return p2.getCreatedAt().compareTo(p1.getCreatedAt());
                                }
                            });
                        } else {
                            message = "No places found.";
                        }
                    } catch (Exception e) {
                        message = "Error: " + e.getMessage();
                        e.printStackTrace();
                    }

                    // Pagination logic
                    int itemsPerPage = 14;
                    int currentPage = 1;
                    String pageParam = request.getParameter("page");
                    if (pageParam != null && !pageParam.isEmpty()) {
                        try {
                            currentPage = Integer.parseInt(pageParam);
                            if (currentPage < 1) currentPage = 1;
                        } catch (NumberFormatException e) {
                            currentPage = 1;
                        }
                    }
                    int totalItems = (places != null) ? places.size() : 0;
                    int totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage;
                    if (currentPage > totalPages) currentPage = totalPages;
                    int startIndex = (currentPage - 1) * itemsPerPage;
                    int endIndex = Math.min(startIndex + itemsPerPage, totalItems);
                    List<Place> paginatedPlaces = (places != null && !places.isEmpty()) ?
                            places.subList(startIndex, endIndex) : null;
                    pageContext.setAttribute("paginatedPlaces", paginatedPlaces);
                %>
                <% if (message != null) { %>
                <p class="text-center mb-6 text-red-300 text-xl"><%= message %></p>
                <% } %>
                <% if (paginatedPlaces != null && !paginatedPlaces.isEmpty()) { %>
                <div class="nft-grid">
                    <% for (Place place : (List<Place>) pageContext.getAttribute("paginatedPlaces")) { %>
                    <a href="detail.jsp?placeId=<%= place.getId() %>" class="nft-card">
                        <%
                            String imageUrl = (travelService != null) ? travelService.getImageUrlForPlace(place.getId()) : null;
                            if (imageUrl != null && !imageUrl.isEmpty()) {
                                out.print("<img src='" + imageUrl + "' alt='Place Image' class='nft-image'>");
                            } else {
                                out.print("<div class='nft-image bg-gray-600 flex items-center justify-center text-gray-400'>N/A</div>");
                            }
                        %>
                        <div class="nft-content">
                            <h4 class="nft-title"><%= place.getName() != null ? place.getName() : "N/A" %></h4>
                            <p class="nft-description"><%= place.getDescription() != null ? place.getDescription() : "N/A" %></p>
                            <p class="nft-guide">
                                Guide: <%= place.getGuide() != null && place.getGuide().getUsername() != null ?
                                    place.getGuide().getUsername() : "N/A" %>
                            </p>
                        </div>
                    </a>
                    <% } %>
                </div>
                <!-- Pagination Controls -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <a href="index.jsp?page=<%= Math.max(1, currentPage - 1) %>"
                       class="pagination-btn <%= currentPage == 1 ? "disabled" : "" %>">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <%
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, startPage + 4);
                        if (endPage - startPage < 4) {
                            startPage = Math.max(1, endPage - 4);
                        }
                        for (int i = startPage; i <= endPage; i++) {
                    %>
                    <a href="index.jsp?page=<%= i %>"
                       class="page-number <%= i == currentPage ? "active" : "" %>">
                        <%= i %>
                    </a>
                    <% } %>
                    <a href="index.jsp?page=<%= Math.min(totalPages, currentPage + 1) %>"
                       class="pagination-btn <%= currentPage == totalPages ? "disabled" : "" %>">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
                <% } %>
                <% } %>
            </div>
        </div>
    </div>
</main>
</body>
</html>