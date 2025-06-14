<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Register</title></head>
<body>
<h2>Register</h2>
<%
  String message = request.getParameter("message");
  if (message != null) {
    out.println("<p style='color:red'>" + message + "</p>");
  }
%>
<form action="auth" method="post">
  <input type="hidden" name="action" value="register">
  <label>Username: <input type="text" name="username"></label><br>
  <label>Password: <input type="password" name="password"></label><br>
  <label>Role:
    <select name="role">
      <option value="guide">Guide</option>
      <option value="traveler">Traveler</option>
    </select>
  </label><br>
  <input type="submit" value="Register">
</form>
<p><a href="login.jsp">Back to Login</a></p>
</body>
</html>