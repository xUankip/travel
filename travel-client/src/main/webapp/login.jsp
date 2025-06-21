<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #667eea, #764ba2);
        }
        .input-field:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
        }
        .toggle-password:hover {
            color: #667eea;
        }
    </style>
</head>
<body class="font-sans bg-gray-100 flex items-center justify-center min-h-screen p-4">
<div class="w-full max-w-md">
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
        <div class="gradient-bg p-6 text-center">
            <h1 class="text-2xl font-bold text-white">Welcome Back</h1>
            <p class="text-white opacity-90 mt-1">Sign in to continue</p>
        </div>
        <div class="p-6">
            <%
                String message = request.getParameter("message");
                if (message != null) {
            %>
            <p class="text-red-500 text-center mb-4"><%= message %></p>
            <%
                }
            %>
            <form action="${pageContext.request.contextPath}/auth" method="post" class="space-y-4">
                <input type="hidden" name="action" value="login">
                <div>
                    <input type="text" id="username" name="username" class="input-field w-full p-3 border rounded-lg focus:border-indigo-500" placeholder="Username" required>
                </div>
                <div class="relative">
                    <input type="password" id="password" name="password" class="input-field w-full p-3 border rounded-lg focus:border-indigo-500" placeholder="Password" required>
                    <span id="togglePassword" class="toggle-password absolute right-3 top-3 cursor-pointer" onclick="togglePassword()">
                            <i class="far fa-eye"></i>
                        </span>
                </div>
                <div class="flex justify-between items-center text-sm">
                    <div class="flex items-center">
                        <input type="checkbox" id="remember-me" name="remember-me" class="h-4 w-4 text-indigo-600">
                        <label for="remember-me" class="ml-2 text-gray-700">Remember me</label>
                    </div>
                    <a href="#" class="text-indigo-600 hover:text-indigo-500">Forgot password?</a>
                </div>
                <button type="submit" class="w-full gradient-bg text-white p-3 rounded-lg hover:opacity-90 transition">
                    Sign In
                </button>
            </form>
            <div class="mt-4 text-center text-gray-600">
                Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp" class="text-indigo-600 hover:text-indigo-500">Register</a>
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword() {
        const passwordInput = document.getElementById('password');
        const toggleIcon = document.getElementById('togglePassword').querySelector('i');
        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            toggleIcon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            passwordInput.type = 'password';
            toggleIcon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }
</script>
</body>
</html>