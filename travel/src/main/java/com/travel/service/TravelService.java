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
    private Map<String, Long> sessionTokens = new HashMap<>();
    private int tokenCounter = 0;

    public TravelService() {
        emf = Persistence.createEntityManagerFactory("travelPU");
    }

    @WebMethod
    public String login(String username, String password) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT u FROM User u WHERE u.username = :username AND u.password = :password");
            query.setParameter("username", username);
            query.setParameter("password", password);
            User user = (User) query.getSingleResult();
            if (user != null) {
                String token = "token" + tokenCounter++;
                sessionTokens.put(token, user.getId());
                return token + ":" + user.getRole();
            }
            return "failed";
        } catch (Exception e) {
            return "failed";
        } finally {
            em.close();
        }
    }

    @WebMethod
    public boolean register(String username, String password, String role) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            User user = new User();
            user.setUsername(username);
            user.setPassword(password);
            user.setRole(role);
            em.persist(user);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

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

    @WebMethod
    public boolean addPlace(String token, String name, String description, String imageData) {
        System.out.println("Adding place: name=" + name + ", imageData length=" + (imageData != null ? imageData.length() : 0));
        if (!isAuthenticated(token, "guide")) {
            System.out.println("Authentication failed for token: " + token);
            return false;
        }
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

            if (imageData != null && !imageData.trim().isEmpty()) {
                Image image = new Image();
                image.setPlace(place);
                if (imageData.startsWith("data:image")) {
                    System.out.println("Saving base64 image, length: " + imageData.length());
                    image.setImageData(imageData); // Lưu base64
                    image.setUrl(null); // Không dùng URL khi có base64
                } else {
                    image.setUrl(imageData); // Lưu URL
                    image.setImageData(null);
                }
                image.setDescription("Hình ảnh chính của " + name);
                em.persist(image);
            }

            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            System.out.println("Error adding place: " + e.getMessage());
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

    @WebMethod
    public boolean updatePlace(String token, Long placeId, String name, String description, Long guideId) {
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
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

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
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

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
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

    @WebMethod
    public List<Place> searchPlaces(String token, String keyword) {
        if (!isAuthenticated(token, "guide") && !isAuthenticated(token, "traveler")) {
            EntityManager em = emf.createEntityManager();
            try {
                Query query = em.createQuery(
                        "SELECT p FROM Place p WHERE LOWER(p.name) LIKE :keyword OR LOWER(p.description) LIKE :keyword ORDER BY p.id DESC",
                        Place.class
                );
                query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");
                return query.getResultList();
            } finally {
                em.close();
            }
        }

        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery(
                    "SELECT p FROM Place p WHERE LOWER(p.name) LIKE :keyword OR LOWER(p.description) LIKE :keyword ORDER BY p.id DESC",
                    Place.class
            );
            query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");
            return query.getResultList();
        } finally {
            em.close();
        }
    }


    @WebMethod
    public boolean ratePlace(Long placeId, Long travelerId, int rating, String comment) {
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
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }

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
                        .append(", URL: ").append(image.getUrl() != null ? image.getUrl() : "Base64 Image")
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
    public boolean logout(String token) {
        if (sessionTokens.containsKey(token)) {
            sessionTokens.remove(token);
            return true;
        }
        return false;
    }

    @WebMethod
    public List<Place> getAllPlaces() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createQuery("SELECT p FROM Place p ORDER BY p.id DESC", Place.class).getResultList();
        } finally {
            em.close();
        }
    }

    @WebMethod
    public String getImageUrlForPlace(Long placeId) {
        EntityManager em = emf.createEntityManager();
        try {
            Place place = em.find(Place.class, placeId);
            if (place != null) {
                List<Image> images = em.createQuery("SELECT i FROM Image i WHERE i.place.id = :placeId", Image.class)
                        .setParameter("placeId", placeId)
                        .getResultList();
                if (!images.isEmpty()) {
                    Image image = images.get(0);
                    return image.getUrl() != null ? image.getUrl() : image.getImageData();
                }
            }
            return null;
        } finally {
            em.close();
        }
    }

    @WebMethod
    public String getPlaceDetails(Long placeId) {
        EntityManager em = emf.createEntityManager();
        try {
            Place place = em.find(Place.class, placeId);
            if (place != null) {
                User guide = place.getGuide();
                String guideName = (guide != null && guide.getUsername() != null) ? guide.getUsername() : "N/A";
                return "name:" + place.getName() + ",description:" + place.getDescription() + ",guide:" + guideName;
            }
            return "error:Không tìm thấy địa điểm";
        } finally {
            em.close();
        }
    }

    @WebMethod
    public String getCommentsByPlace(Long placeId) {
        EntityManager em = emf.createEntityManager();
        try {
            Query query = em.createQuery("SELECT r FROM Ratings r WHERE r.place.id = :placeId", Ratings.class);
            query.setParameter("placeId", placeId);
            List<Ratings> ratings = query.getResultList();
            if (ratings.isEmpty()) {
                return "No comments";
            }
            StringBuilder result = new StringBuilder();
            for (Ratings rating : ratings) {
                User traveler = rating.getTraveler();
                String travelerName = (traveler != null && traveler.getUsername() != null) ? traveler.getUsername() : "Anonymous";
                result.append("traveler:").append(travelerName)
                        .append(",rating:").append(rating.getRating())
                        .append(",comment:").append(rating.getComment() != null ? rating.getComment() : "No comment")
                        .append("\n");
            }
            return result.toString();
        } finally {
            em.close();
        }
    }

    @WebMethod
    public boolean addComment(Long placeId, String token, int rating, String comment) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Long userId = sessionTokens.get(token);
            if (userId == null) {
                return false; // Token không hợp lệ
            }
            User traveler = em.find(User.class, userId);
            if (traveler == null) {
                return false; // Người dùng không tồn tại
            }
            Place place = em.find(Place.class, placeId);
            if (place == null) {
                return false; // Địa điểm không tồn tại
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
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } finally {
            em.close();
        }
    }
}
