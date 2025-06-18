package com.travel.service;

import com.travel.service.TravelService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AddImageServlet")
public class AddImageServlet extends HttpServlet {
    private TravelService travelService;

    @Override
    public void init() throws ServletException {
        travelService = new TravelService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        String userIdStr = (String) session.getAttribute("userId");

        // Check if user is logged in and is a guide
        if (username == null || !"guide".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            Long placeId = Long.parseLong(request.getParameter("placeId"));
            Long guideId = Long.parseLong(userIdStr);
            String imageUrl = request.getParameter("imageUrl");
            String description = request.getParameter("description");

            // Validate input
            if (imageUrl == null || imageUrl.trim().isEmpty() ||
                    description == null || description.trim().isEmpty()) {
                response.sendRedirect("manage-images.jsp?placeId=" + placeId + "&error=missing_fields");
                return;
            }

            // Call web service to add image
            boolean success = travelService.addImage(placeId, imageUrl.trim(), description.trim(), guideId);

            if (success) {
                response.sendRedirect("manage-images.jsp?placeId=" + placeId + "&added=true");
            } else {
                response.sendRedirect("manage-images.jsp?placeId=" + placeId + "&error=add_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-images.jsp?error=invalid_data");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-images.jsp?error=system_error");
        }
    }
}