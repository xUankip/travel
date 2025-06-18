<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Place</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
    .input-field {
      transition: all 0.3s ease;
    }
    .input-field:focus {
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
    }
    .floating-label {
      transition: all 0.3s ease;
      transform-origin: left top;
    }
    .input-field:focus + .floating-label,
    .input-field:not(:placeholder-shown) + .floating-label {
      transform: translateY(-1.2rem) scale(0.85);
      color: #667eea;
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
    <h2 class="text-4xl font-extrabold text-center mb-6">Add New Place</h2>
    <%
      String token = (String) session.getAttribute("token");
      if (token == null || !((String) session.getAttribute("role")).equals("guide")) {
        response.sendRedirect("login.jsp?message=Unauthorized access");
        return;
      }
    %>
    <div id="message" class="text-center mb-6 text-red-300 font-medium"></div>
    <form id="addPlaceForm" class="space-y-6">
      <!-- Name Field -->
      <div class="relative">
        <input
                type="text"
                id="name"
                name="name"
                class="input-field w-full px-4 py-3 border border-gray-200/20 text-white bg-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400 placeholder-gray-400"
                placeholder=" "
                required
        />
        <label
                for="name"
                class="floating-label absolute left-4 top-3 text-gray-300 pointer-events-none peer-focus:text-indigo-300"
        >
          Place Name
        </label>
      </div>

      <!-- Description Field -->
      <div class="relative">
                <textarea
                        id="description"
                        name="description"
                        class="input-field w-full px-4 py-3 border border-gray-200/20 text-white bg-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400 placeholder-gray-400"
                        placeholder=" "
                        rows="4"
                        required
                ></textarea>
        <label
                for="description"
                class="floating-label absolute left-4 top-3 text-gray-300 pointer-events-none peer-focus:text-indigo-300"
        >
          Description
        </label>
      </div>

      <!-- Submit Button -->
      <button
              type="submit"
              class="btn w-full bg-green-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-green-700 flex items-center justify-center"
      >
        <i class="fas fa-plus mr-2"></i> Add Place
      </button>
    </form>
    <div class="mt-6 text-center">
      <a href="home.jsp" class="text-indigo-300 hover:text-indigo-200 font-medium">
        <i class="fas fa-arrow-left mr-2"></i> Back to Home
      </a>
    </div>
  </div>
</div>

<script>
  $(document).ready(function() {
    $("#addPlaceForm").on("submit", function(e) {
      e.preventDefault();
      const token = "<%= token %>";
      const name = $("#name").val();
      const description = $("#description").val();

      $.ajax({
        url: "http://localhost:8080/travel-service/TravelService?wsdl", // URL của WebService, điều chỉnh nếu cần
        method: "POST",
        dataType: "json",
        data: JSON.stringify({
          token: token,
          name: name,
          description: description
        }),
        contentType: "application/json",
        success: function(response) {
          if (response === true) {
            $("#message").text("Place added successfully!").fadeIn().delay(3000).fadeOut();
            $("#addPlaceForm")[0].reset();
          } else {
            $("#message").text("Failed to add place.").fadeIn().delay(3000).fadeOut();
          }
        },
        error: function() {
          $("#message").text("Error connecting to server.").fadeIn().delay(3000).fadeOut();
        }
      });
    });

    // Floating label functionality
    document.querySelectorAll('.input-field').forEach(input => {
      input.addEventListener('focus', function() {
        this.nextElementSibling.classList.add('text-indigo-300');
      });
      input.addEventListener('blur', function() {
        if (!this.value) {
          this.nextElementSibling.classList.remove('text-indigo-300');
        }
      });
    });
  });
</script>
</body>
</html>