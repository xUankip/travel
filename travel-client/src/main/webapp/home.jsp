<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Home</title></head>
<body>
<h2>Welcome</h2>
<%
  String role = (String) session.getAttribute("role");
  if (role != null) {
    out.println("<p>Logged in as: " + role + "</p>");
    if ("guide".equals(role)) {
      out.println("<p><a href='addPlace.jsp'>Add Place</a></p>");
    } else if ("traveler".equals(role)) {
      out.println("<p><a href='search.jsp'>Search Places</a></p>");
    }
    out.println("<p><a href='logout'>Logout</a></p>");
  } else {
    response.sendRedirect("login.jsp");
  }
%>
</body>
</html>