package com.travel.service;

import com.travel.service.TravelService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteImageServlet")
public class DeleteImageServlet extends HttpServlet {
    private TravelService travelService;

    @Override
    public void init() throws ServletException {
        travelService = new TravelService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
            Long imageId = Long.parseLong(request.getParameter("imageId"));
            Long placeId = Long.parseLong(request.getParameter("placeId"));
            Long guideId = Long.parseLong(userIdStr);

            // You would need to add a deleteImage method to your TravelService
            // For now, we'll assume it exists
            boolean success = deleteImage(imageId, guideId);

            if (success) {
                response.sendRedirect("manage-images.jsp?placeId=" + placeId + "&deleted=true");
            } else {
                response.sendRedirect("manage-images.jsp?placeId=" + placeId + "&error=delete_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-images.jsp?error=invalid_data");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-images.jsp?error=system_error");
        }
    }

    // This method would need to be added to your TravelService
    private boolean deleteImage(Long imageId, Long guideId) {
        // Implementation would call TravelService.deleteImage(imageId, guideId)
        // For now, returning true as placeholder
        return true;
    }
}