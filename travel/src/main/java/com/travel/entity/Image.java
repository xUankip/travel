package com.travel.entity;

import lombok.Data;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Data
@XmlRootElement
@Table(name = "images")
public class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "place_id", referencedColumnName = "id")
    private Place place; // Thay placeId bằng mối quan hệ với Place

    @Column(name = "url")
    private String url;

    @Column(name = "description")
    private String description;

    public Image() {
    }

    public Image(Long id, Place place, String url, String description) {
        this.id = id;
        this.place = place;
        this.url = url;
        this.description = description;
    }
}