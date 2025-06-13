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
import java.util.List;

@WebService
public class TravelService {
    private final EntityManagerFactory emf;

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
            query.setParameter("password", password); // Lưu ý: Trong thực tế, cần mã hóa password
            User user = (User) query.getSingleResult();
            return user != null ? "success:" + user.getId() + ":" + user.getRole() : "failed";
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
            user.setPassword(password); // Lưu ý: Cần mã hóa password trong thực tế
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

    // Thêm địa điểm (guide)
    @WebMethod
    public boolean addPlace(String name, String description, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            User guide = em.find(User.class, guideId);
            if (guide == null || !guide.getRole().equals("guide")) {
                return false;
            }
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
    public boolean updatePlace(Long placeId, String name, String description, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
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
    public boolean deletePlace(Long placeId, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
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
    public boolean addImage(Long placeId, String url, String description, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
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
    public String searchPlaces(String keyword) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT p FROM Place p WHERE p.name LIKE :keyword OR p.description LIKE :keyword");
            query.setParameter("keyword", "%" + keyword + "%");
            List<Place> places = query.getResultList();
            StringBuilder result = new StringBuilder();
            for (Place place : places) {
                result.append("ID: ").append(place.getId())
                        .append(", Name: ").append(place.getName())
                        .append(", Description: ").append(place.getDescription())
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