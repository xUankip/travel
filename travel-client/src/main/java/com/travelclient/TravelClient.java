package com.travelclient;


import com.travelclient.generated.TravelService;
import com.travelclient.generated.TravelServiceService;

public class TravelClient {
    public static void main(String[] args) {
        // Khởi tạo service
        TravelServiceService service = new TravelServiceService();
        TravelService port = service.getTravelServicePort();

        boolean registerResult = port.register("user", "pass", "traveler");
        System.out.println("Register result: " + registerResult);
        // Gọi các phương thức Web Service
        String loginResult = port.login("user", "pass");
        System.out.println("Login result: " + loginResult);

        String searchResult = port.searchPlaces("beach");
        System.out.println("Search result: " + searchResult);

        boolean addPlaceResult = port.addPlace("Beach Resort", "A beautiful beach", 1L);
        System.out.println("Add place result: " + addPlaceResult);
    }
}