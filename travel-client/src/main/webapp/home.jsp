<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Home</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
    }
    .fade-in {
      animation: fadeIn 0.6s ease-out;
    }
    @keyframes fadeIn {
      0% { opacity: 0; transform: translateY(20px); }
      100% { opacity: 1; transform: translateY(0); }
    }
    .btn {
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .btn:hover {
      transform: translateY(-3px);
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    }
  </style>
</head>
<body class="font-sans flex items-center justify-center min-h-screen p-4">
<div class="w-full max-w-md">
  <div class="glass-card p-8 rounded-2xl text-white fade-in">
    <h2 class="text-4xl font-extrabold text-center mb-6">Welcome</h2>
    <%
      String role = (String) session.getAttribute("role");
      if (role != null) {
    %>
    <p class="text-xl text-center mb-6">Logged in as: <span class="font-semibold"><%= role %></span></p>
    <% if ("guide".equals(role)) { %>
    <a href="addPlace.jsp" class="block btn w-full bg-green-600 text-white text-center py-3 px-4 rounded-lg font-medium hover:bg-green-700 mb-4">
      <i class="fas fa-plus mr-2"></i> Add Place
    </a>
    <% } else if ("traveler".equals(role)) { %>
    <a href="search.jsp" class="block btn w-full bg-blue-600 text-white text-center py-3 px-4 rounded-lg font-medium hover:bg-blue-700 mb-4">
      <i class="fas fa-search mr-2"></i> Search Places
    </a>
    <% } %>
    <a href="logout" class="block btn w-full bg-red-600 text-white text-center py-3 px-4 rounded-lg font-medium hover:bg-red-700">
      <i class="fas fa-sign-out-alt mr-2"></i> Logout
    </a>
    <% } else {
      response.sendRedirect("login.jsp");
    } %>
  </div>
</div>
</body>
</html>