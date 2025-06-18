package com.travel.service;
import com.travel.entity.Image;
import com.travel.entity.Place;
import com.travel.entity.Ratings;
import com.travel.entity.User;

import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.persistence.*;
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
        EntityTransaction tx = null;
        try {
            tx = em.getTransaction();
            tx.begin();

            User guide = em.find(User.class, guideId);
            if (guide == null || !guide.getRole().equals("guide")) {
                tx.rollback();  // rollback if guide not found or not a guide
                return false;
            }

            Place place = new Place();
            place.setName(name);
            place.setDescription(description);
            place.setGuide(guide);

            em.persist(place);
            tx.commit(); // ✅ commit only if all succeeded
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback(); // ✅ rollback on any exception
            }
            e.printStackTrace(); // optional: log error
            return false;
        } finally {
            em.close(); // ✅ always close EntityManager
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
    @WebMethod
    public boolean deleteImage(Long imageId, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Image image = em.find(Image.class, imageId);
            if (image == null || image.getPlace().getGuide().getId() != guideId) {
                return false;
            }
            em.remove(image);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            em.getTransaction().rollback();
            return false;
        } finally {
            em.close();
        }
    }

    // Update image (guide)
    @WebMethod
    public boolean updateImage(Long imageId, String url, String description, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Image image = em.find(Image.class, imageId);
            if (image == null || image.getPlace().getGuide().getId() != guideId) {
                return false;
            }
            image.setUrl(url);
            image.setDescription(description);
            em.merge(image);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            em.getTransaction().rollback();
            return false;
        } finally {
            em.close();
        }
    }

    // Get places by guide (for dropdown population)
    @WebMethod
    public String getPlacesByGuide(Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT p FROM Place p WHERE p.guide.id = :guideId");
            query.setParameter("guideId", guideId);
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
            return "Error retrieving places";
        } finally {
            em.close();
        }
    }

    // Get images by place with more details
    @WebMethod
    public String getImagesByPlaceDetailed(Long placeId, Long guideId) {
        EntityManager em = emf.createEntityManager();
        try {
            // First check if the place belongs to the guide
            Place place = em.find(Place.class, placeId);
            if (place == null || place.getGuide().getId() != guideId) {
                return "Access denied";
            }

            Query query = em.createQuery("SELECT i FROM Image i WHERE i.place.id = :placeId ORDER BY i.id DESC");
            query.setParameter("placeId", placeId);
            List<Image> images = query.getResultList();
            StringBuilder result = new StringBuilder();
            for (Image image : images) {
                result.append("ID: ").append(image.getId())
                        .append(", URL: ").append(image.getUrl())
                        .append(", Description: ").append(image.getDescription())
                        .append(", PlaceID: ").append(image.getPlace().getId())
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