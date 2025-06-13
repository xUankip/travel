package com.travel.entity;

import lombok.Data;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Data
@XmlRootElement
@Table(name = "places")
public class Place {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "description")
    private String description;

    @ManyToOne
    @JoinColumn(name = "guide_id", referencedColumnName = "id")
    private User guide;

    public Place() {
    }

    public Place(Long id, String name, String description, User guide) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.guide = guide;
    }
}