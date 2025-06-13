package com.travel.entity;

import lombok.Data;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Data
@XmlRootElement
@Table(name = "ratings")
public class Ratings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "place_id", referencedColumnName = "id")
    private Place place; // Thay placeId bằng mối quan hệ với Place

    @ManyToOne
    @JoinColumn(name = "traveler_id", referencedColumnName = "id")
    private User traveler; // Thay travelerId bằng mối quan hệ với User

    @Column(name = "rating")
    private int rating;

    @Column(name = "comment")
    private String comment;

    public Ratings() {
    }

    public Ratings(Long id, Place place, User traveler, int rating, String comment) {
        this.id = id;
        this.place = place;
        this.traveler = traveler;
        this.rating = rating;
        this.comment = comment;
    }
}