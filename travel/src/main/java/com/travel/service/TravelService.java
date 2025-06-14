package com.travel.service;
import com.travel.entity.Image;
import com.travel.entity.Place;
import com.travel.entity.Ratings;
import com.travel.entity.User;

import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebService
public class TravelService {
    private final EntityManagerFactory emf;
    private Map<String, Long> sessionTokens = new HashMap<>(); // Lưu token và user ID
    private int tokenCounter = 0;
    public TravelService() {
        // Khởi tạo EntityManagerFactory cho Hibernate
        emf = Persistence.createEntityManagerFactory("travelPU"); // Thay "travelPU" bằng tên persistence unit trong persistence.xml
    }

    // Đăng nhập
    @WebMethod
    public String login(String username, String password) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT u FROM User u WHERE u.username = :username AND u.password = :password");
            query.setParameter("username", username);
            query.setParameter("password", password); // Cần mã hóa password trong thực tế
            User user = (User) query.getSingleResult();
            if (user != null) {
                String token = "token" + tokenCounter++; // Tạo token đơn giản
                sessionTokens.put(token, user.getId());
                return token + ":" + user.getRole(); // Trả về token và role
            }
            return "failed";
        } catch (Exception e) {
            return "failed";
        } finally {
            em.close();
        }
    }

    // Đăng ký người dùng
    @WebMethod
    public boolean register(String username, String password, String role) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            User user = new User();
            user.setUsername(username);
            user.setPassword(password); // Cần mã hóa password
            user.setRole(role);
            em.persist(user);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Kiểm tra token và role trước khi thực hiện hành động
    private boolean isAuthenticated(String token, String role) {
        if (!sessionTokens.containsKey(token)) return false;
        Long userId = sessionTokens.get(token);
        EntityManager em = emf.createEntityManager();
        try {
            User user = em.find(User.class, userId);
            return user != null && user.getRole().equals(role);
        } finally {
            em.close();
        }
    }

    // Thêm địa điểm (guide)
    @WebMethod
    public boolean addPlace(String token, String name, String description) {
        if (!isAuthenticated(token, "guide")) return false;
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Long userId = sessionTokens.get(token);
            User guide = em.find(User.class, userId);
            if (guide == null) return false;
            Place place = new Place();
            place.setName(name);
            place.setDescription(description);
            place.setGuide(guide);
            em.persist(place);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Cập nhật địa điểm (guide)
    @WebMethod
    public boolean updatePlace(String token , Long placeId, String name, String description, Long guideId) {
        if (!isAuthenticated(token, "guide")) return false;
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Long userId = sessionTokens.get(token);
            User guide = em.find(User.class, userId);
            if (guide == null) return false;
            Place place = em.find(Place.class, placeId);
            if (place == null || place.getGuide().getId() != guideId) {
                return false;
            }
            place.setName(name);
            place.setDescription(description);
            em.merge(place);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Xóa địa điểm (guide)
    @WebMethod
    public boolean deletePlace(Long placeId, Long guideId, String token) {
        if (!isAuthenticated(token, "guide")) return false;
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Long userId = sessionTokens.get(token);
            if (userId == null) return false;
            if (!userId.equals(guideId)) return false;
            Place place = em.find(Place.class, placeId);
            if (place == null || place.getGuide().getId() != guideId) {
                return false;
            }
            em.remove(place);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Thêm hình ảnh (guide)
    @WebMethod
    public boolean addImage(Long placeId, String url, String description, Long guideId, String token) {
        if (!isAuthenticated(token, "guide")) return false;
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Long userId = sessionTokens.get(token);
            if (userId == null) return false;
            if (!userId.equals(guideId)) return false;
            Place place = em.find(Place.class, placeId);
            if (place == null || place.getGuide().getId() != guideId) {
                return false;
            }
            Image image = new Image();
            image.setPlace(place);
            image.setUrl(url);
            image.setDescription(description);
            em.persist(image);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Tìm kiếm địa điểm (traveler)
    @WebMethod
    public String searchPlaces(String token, String keyword) {
        if (!isAuthenticated(token, "guide") && !isAuthenticated(token, "traveler")) return "failed";
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT p FROM Place p WHERE p.name LIKE :keyword OR p.description LIKE :keyword");
            query.setParameter("keyword", "%" + keyword + "%");
            List<Place> places = query.getResultList();
            StringBuilder result = new StringBuilder();
            for (Place place : places) {
                result.append("ID: ").append(place.getId())
                        .append(", Name: ").append(place.getName())
                        .append("\n");
            }
            return result.length() > 0 ? result.toString() : "No places found";
        } catch (Exception e) {
            return "Error searching places";
        } finally {
            em.close();
        }
    }

    // Đánh giá và bình luận (traveler)
    @WebMethod
    public boolean ratePlace(Long placeId, Long travelerId, Integer rating, String comment) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Place place = em.find(Place.class, placeId);
            User traveler = em.find(User.class, travelerId);
            if (place == null || traveler == null || !traveler.getRole().equals("traveler")) {
                return false;
            }
            Ratings ratingObj = new Ratings();
            ratingObj.setPlace(place);
            ratingObj.setTraveler(traveler);
            ratingObj.setRating(rating);
            ratingObj.setComment(comment);
            em.persist(ratingObj);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    // Lấy danh sách hình ảnh của một địa điểm
    @WebMethod
    public String getImagesByPlace(Long placeId) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT i FROM Image i WHERE i.place.id = :placeId");
            query.setParameter("placeId", placeId);
            List<Image> images = query.getResultList();
            StringBuilder result = new StringBuilder();
            for (Image image : images) {
                result.append("ID: ").append(image.getId())
                        .append(", URL: ").append(image.getUrl())
                        .append(", Description: ").append(image.getDescription())
                        .append("\n");
            }
            return result.length() > 0 ? result.toString() : "No images found";
        } catch (Exception e) {
            return "Error retrieving images";
        } finally {
            em.close();
        }
    }
}