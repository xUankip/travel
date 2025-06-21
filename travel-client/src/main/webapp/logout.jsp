<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.travelclient.generated.TravelService" %>
<%@ page import="javax.xml.namespace.QName" %>
<%@ page import="javax.xml.ws.Service" %>
<%@ page import="java.net.URL" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logging Out</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
    </style>
</head>
<body class="font-sans bg-gray-50">
<div class="min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
        <!-- Logout Card -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <!-- Gradient Header -->
            <div class="gradient-bg py-8 px-6 text-center">
                <h1 class="text-3xl font-bold text-white">Đăng xuất</h1>
                <p class="text-white opacity-90 mt-2">Đang xử lý...</p>
            </div>

            <!-- Logout Content -->
            <div class="px-8 py-10 text-center">
                <%
                    String token = (String) session.getAttribute("token");
                    String message = "Đang đăng xuất...";
                    boolean success = false;
                    if (token != null) {
                        try {
                            URL wsdlURL = new URL("http://localhost:8080/travel?wsdl"); // Điều chỉnh URL nếu cần
                            QName qName = new QName("http://service.travel.com/", "TravelService");
                            Service service = Service.create(wsdlURL, qName);
                            TravelService travelService = service.getPort(TravelService.class);
                            success = travelService.logout(token);
                            if (success) {
                                message = "Đăng xuất thành công!";
                            } else {
                                message = "Đăng xuất thất bại. Token không hợp lệ.";
                            }
                        } catch (Exception e) {
                            message = "Lỗi khi đăng xuất: " + e.getMessage();
                            e.printStackTrace();
                        }
                    } else {
                        message = "Không tìm thấy phiên đăng nhập.";
                    }
                    session.invalidate();
                %>
                <p class="text-gray-700 text-lg mb-6"><%= message %></p>
                <p class="text-gray-500">Chuyển hướng về trang chủ trong <span id="countdown">3</span> giây...</p>
            </div>
        </div>
    </div>
</div>

<script>
    // Countdown and redirect
    let countdown = 3;
    const countdownElement = document.getElementById('countdown');
    const timer = setInterval(() => {
        countdown--;
        countdownElement.textContent = countdown;
        if (countdown <= 0) {
            clearInterval(timer);
            window.location.href = 'index.jsp';
        }
    }, 1000);
</script>
</body>
</html>