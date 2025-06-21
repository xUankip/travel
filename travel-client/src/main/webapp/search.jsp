<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Search Places - Travel App</title>
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
    .action-btn {
      padding: 0.75rem 1.5rem;
      border-radius: 0.5rem;
      transition: all 0.3s ease;
    }
    .action-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
  </style>
</head>
<body class="font-sans flex flex-col min-h-screen">
<!-- Header -->
<header class="glass-header">
  <div class="max-w-6xl mx-auto flex justify-between items-center">
    <div class="flex items-center space-x-4">
      <h1 class="text-3xl font-bold text-white">Travel App</h1>
    </div>
    <nav>
      <a href="index.jsp" class="text-white text-lg font-medium header-link transition-colors action-btn bg-blue-600 hover:bg-blue-700">
        <i class="fas fa-home mr-2"></i> Home
      </a>
    </nav>
  </div>
</header>

<!-- Main Content -->
<main class="flex items-center justify-center flex-grow">
  <div class="w-full max-w-6xl">
    <div class="glass-card fade-in">
      <h2 class="text-5xl font-extrabold text-center mb-8">Search Places</h2>
      <form action="searchResults.jsp" method="get" class="flex flex-col md:flex-row justify-center gap-4 mb-10">
        <input type="text" name="query" placeholder="Enter place name..." class="px-4 py-3 rounded-lg bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-600 w-full md:w-96">
        <button type="submit" class="btn bg-blue-600 text-white text-center py-3 px-8 rounded-lg font-semibold hover:bg-blue-700 action-btn">
          <i class="fas fa-search mr-2"></i> Search
        </button>
      </form>
      <p class="text-center text-gray-300">Enter a place name to find your next travel destination!</p>
    </div>
  </div>
</main>
</body>
</html>
```