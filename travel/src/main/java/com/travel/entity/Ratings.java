package com.travel.entity;

import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Data
@NoArgsConstructor
@Table(name = "ratings", indexes = {
        @Index(name = "idx_place_id", columnList = "place_id"),
        @Index(name = "idx_traveler_id", columnList = "traveler_id")
})
@XmlRootElement
public class Ratings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "place_id", referencedColumnName = "id")
    private Place place;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "traveler_id", referencedColumnName = "id")
    private User traveler;

    @Column(name = "rating")
    @Min(1)
    @Max(5)
    private int rating;

    @Column(name = "comment")
    @NotNull
    private String comment;

    public Ratings(Place place, User traveler, int rating, String comment) {
        this.place = place;
        this.traveler = traveler;
        this.rating = rating;
        this.comment = comment;
    }
}