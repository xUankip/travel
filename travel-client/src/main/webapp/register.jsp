<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    .gradient-bg {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
    .social-btn {
      transition: all 0.3s ease;
    }
    .social-btn:hover {
      transform: translateY(-3px);
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
    }
    .toggle-password {
      cursor: pointer;
      transition: all 0.3s ease;
    }
    .toggle-password:hover {
      color: #667eea;
    }
    select {
      appearance: none;
      background-image: url("data:image/svg+xml;utf8,<svg fill='gray' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/><path d='M0 0h24v24H0z' fill='none'/></svg>");
      background-repeat: no-repeat;
      background-position-x: 98%;
      background-position-y: 50%;
    }
  </style>
</head>
<body class="font-sans bg-gray-50">
<div class="min-h-screen flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    <!-- Register Card -->
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
      <!-- Gradient Header -->
      <div class="gradient-bg py-8 px-6 text-center">
        <h1 class="text-3xl font-bold text-white">Create Account</h1>
        <p class="text-white opacity-90 mt-2">Join us today</p>
      </div>

      <!-- Register Form -->
      <div class="px-8 py-10">
        <%
          String message = request.getParameter("message");
          if (message != null) {
        %>
        <p class="text-red-500 text-center mb-6 font-medium"><%= message %></p>
        <%
          }
        %>
        <form action="auth" method="post" id="registerForm" class="space-y-6">
          <input type="hidden" name="action" value="register">
          <!-- Username Field -->
          <div class="relative">
            <input
                    type="text"
                    id="username"
                    name="username"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500 peer"
                    placeholder=" "
                    required
            />
            <label
                    for="username"
                    class="floating-label absolute left-4 top-3 text-gray-500 pointer-events-none peer-focus:text-indigo-500"
            >
              Username
            </label>
          </div>

          <!-- Password Field -->
          <div class="relative">
            <div class="flex items-center">
              <input
                      type="password"
                      id="password"
                      name="password"
                      class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500 peer"
                      placeholder=" "
                      required
              />
              <label
                      for="password"
                      class="floating-label absolute left-4 top-3 text-gray-500 pointer-events-none peer-focus:text-indigo-500"
              >
                Password
              </label>
              <span
                      id="togglePassword"
                      class="toggle-password absolute right-4 text-gray-500"
                      onclick="togglePasswordVisibility()"
              >
                                    <i class="far fa-eye"></i>
                                </span>
            </div>
          </div>

          <!-- Role Selection -->
          <div class="relative">
            <label
                    for="role"
                    class="block text-sm font-medium text-gray-700 mb-1"
            >
              Role
            </label>
            <select
                    id="role"
                    name="role"
                    class="input-field w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                    required
            >
              <option value="guide">Guide</option>
              <option value="traveler">Traveler</option>
            </select>
          </div>

          <!-- Submit Button -->
          <button
                  type="submit"
                  class="w-full gradient-bg text-white py-3 px-4 rounded-lg font-medium hover:opacity-90 transition duration-300 flex items-center justify-center"
          >
            <span id="registerText">Register</span>
            <span id="registerSpinner" class="hidden ml-2">
                                <i class="fas fa-spinner fa-spin"></i>
                            </span>
          </button>
        </form>

        <!-- Social Login -->
        <div class="mt-8">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
                                <span class="px-2 bg-white text-gray-500">
                                    Or continue with
                                </span>
            </div>
          </div>

          <div class="grid grid-cols-3 gap-3 mt-6">
            <a href="#" class="social-btn bg-white border border-gray-300 rounded-lg py-2 px-4 flex items-center justify-center text-gray-700 hover:bg-gray-50">
              <i class="fab fa-google text-red-500 mr-2"></i>
            </a>
            <a href="#" class="social-btn bg-white border border-gray-300 rounded-lg py-2 px-4 flex items-center justify-center text-gray-700 hover:bg-gray-50">
              <i class="fab fa-facebook-f text-blue-600 mr-2"></i>
            </a>
            <a href="#" class="social-btn bg-white border border-gray-300 rounded-lg py-2 px-4 flex items-center justify-center text-gray-700 hover:bg-gray-50">
              <i class="fab fa-twitter text-blue-400 mr-2"></i>
            </a>
          </div>
        </div>

        <!-- Login Link -->
        <div class="mt-8 text-center">
          <p class="text-gray-600">
            Already have an account?
            <a href="login.jsp" class="font-medium text-indigo-600 hover:text-indigo-500">
              Sign in
            </a>
          </p>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  // Toggle password visibility
  function togglePasswordVisibility() {
    const passwordInput = document.getElementById('password');
    const toggleIcon = document.getElementById('togglePassword').querySelector('i');

    if (passwordInput.type === 'password') {
      passwordInput.type = 'text';
      toggleIcon.classList.remove('fa-eye');
      toggleIcon.classList.add('fa-eye-slash');
    } else {
      passwordInput.type = 'password';
      toggleIcon.classList.remove('fa-eye-slash');
      toggleIcon.classList.add('fa-eye');
    }
  }

  // Add floating label functionality
  document.querySelectorAll('.input-field').forEach(input => {
    input.addEventListener('focus', function() {
      this.nextElementSibling.classList.add('text-indigo-500');
    });

    input.addEventListener('blur', function() {
      if (!this.value) {
        this.nextElementSibling.classList.remove('text-indigo-500');
      }
    });
  });
</script>
</body>
</html>