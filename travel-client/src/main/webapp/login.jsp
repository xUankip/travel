<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Login</title></head>
<body>
<h2>Login</h2>
<%
    String message = request.getParameter("message");
    if (message != null) {
        out.println("<p style='color:red'>" + message + "</p>");
    }
%>
<form action="auth" method="post">
    <input type="hidden" name="action" value="login">
    <label>Username: <input type="text" name="username"></label><br>
    <label>Password: <input type="password" name="password"></label><br>
    <input type="submit" value="Login">
</form>
<p><a href="register.jsp">Register</a></p>
</body>
</html>