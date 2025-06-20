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
    private Place place;

    @Column(name = "url")
    private String url;

    @Column(name = "image_data", columnDefinition = "LONGTEXT")
    private String imageData;

    @Column(name = "description")
    private String description;

    public Image() {
    }

    public Image(Long id, Place place, String url, String imageData, String description) {
        this.id = id;
        this.place = place;
        this.url = url;
        this.imageData = imageData;
        this.description = description;
    }
}