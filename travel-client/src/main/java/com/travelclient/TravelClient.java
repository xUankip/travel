package com.travelclient;

import com.travelclient.generated.TravelService;
import com.travelclient.generated.TravelServiceService;

public class TravelClient {
    private static final TravelServiceService service = new TravelServiceService();
    private static final TravelService port = service.getTravelServicePort();

    public static void main(String[] args) {
        // Example test calls
        boolean registerResult = register("user", "pass", "traveler");
        System.out.println("Register result: " + registerResult);

        String loginResult = login("user", "pass");
        System.out.println("Login result: " + loginResult);

        String searchResult = searchPlaces("beach");
        System.out.println("Search result: \n" + searchResult);

        boolean addPlaceResult = addPlace("Beach Resort", "A beautiful beach", 1L);
        System.out.println("Add place result: " + addPlaceResult);
    }

    public static TravelService getPort() {
        return port;
    }

    // === All Service Wrappers ===

    public static String login(String username, String password) {
        return port.login(username, password);
    }

    public static boolean register(String username, String password, String role) {
        return port.register(username, password, role);
    }

    public static boolean addPlace(String name, String description, Long guideId) {
        return port.addPlace(name, description, guideId);
    }

    public static boolean updatePlace(Long placeId, String name, String description, Long guideId) {
        return port.updatePlace(placeId, name, description, guideId);
    }

    public static boolean deletePlace(Long placeId, Long guideId) {
        return port.deletePlace(placeId, guideId);
    }

    public static boolean addImage(Long placeId, String url, String description, Long guideId) {
        return port.addImage(placeId, url, description, guideId);
    }

    public static String searchPlaces(String keyword) {
        return port.searchPlaces(keyword);
    }

    public static boolean ratePlace(Long placeId, Long travelerId, Integer rating, String comment) {
        return port.ratePlace(placeId, travelerId, rating, comment);
    }

    public static String getImagesByPlace(Long placeId) {
        return port.getImagesByPlace(placeId);
    }

    public static boolean deleteImage(Long imageId, Long guideId) {
        return port.deleteImage(imageId, guideId);
    }

    public static boolean updateImage(Long imageId, String url, String description, Long guideId) {
        return port.updateImage(imageId, url, description, guideId);
    }

    public static String getPlacesByGuide(Long guideId) {
        return port.getPlacesByGuide(guideId);
    }

    public static String getImagesByPlaceDetailed(Long placeId, Long guideId) {
        return port.getImagesByPlaceDetailed(placeId, guideId);
    }
}
