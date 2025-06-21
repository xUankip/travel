package com.travel.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.UUID;

@WebServlet("/UploadServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50) // 50MB
public class UploadServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;

        // Tạo thư mục uploads nếu chưa tồn tại
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        // Lấy file và URL từ request
        Part filePart = request.getPart("image");
        String imageUrl = request.getParameter("imageUrl");
        String finalImageUrl = null;

        // Ưu tiên xử lý file upload nếu có
        if (filePart != null && filePart.getSize() > 0) {
            String originalFileName = filePart.getSubmittedFileName();
            String fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension; // Tạo tên file duy nhất
            String filePath = uploadPath + File.separator + uniqueFileName;

            // Lưu file lên server
            filePart.write(filePath);
            finalImageUrl = request.getContextPath() + "/uploads/" + uniqueFileName;
        } else if (imageUrl != null && !imageUrl.isEmpty()) {
            finalImageUrl = imageUrl;
        }

        // Lưu imageUrl vào request
        request.setAttribute("imageUrl", finalImageUrl);

        // Chuyển tiếp lại về addPlace.jsp
        request.getRequestDispatcher("/addPlace.jsp").forward(request, response);
    }
}