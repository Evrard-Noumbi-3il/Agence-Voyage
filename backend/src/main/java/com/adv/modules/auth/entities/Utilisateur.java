package com.adv.modules.auth.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.Column;
import jakarta.persistence.Enumerated;
import jakarta.persistence.EnumType;
import jakarta.persistence.PrePersist;
import java.time.OffsetDateTime;
import java.util.UUID;
import com.adv.modules.auth.enums.RoleUtilisateur;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "utilisateurs")
public class Utilisateur {

    @Id
    private UUID id; 

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @Column(
        nullable = false, 
        unique = true, 
        columnDefinition = "citext" 
    )
    private String email;

    @Column(unique = true)
    private String telephone;

    @Column(name = "photo_profil_url")
    private String photoProfilUrl;

    @Column(name = "est_verifie", nullable = false)
    private boolean estVerifie = false;

    @Column(name = "est_banni", nullable = false)
    private boolean estBanni = false;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(
        nullable = false, 
        columnDefinition = "role_utilisateur_enum" // Doit correspondre exactement au nom dans ton script SQL
    )
    private RoleUtilisateur role = RoleUtilisateur.VOYAGEUR;

    @Column(name = "points_fidelite", nullable = false)
    private int pointsFidelite = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = OffsetDateTime.now();
    }

    public Utilisateur() {}

    public Utilisateur(UUID id, String email, String nom, String prenom, RoleUtilisateur role) {
        this.id = id;
        this.email = email;
        this.nom = nom;
        this.prenom = prenom;
        this.role = role;
        this.createdAt = OffsetDateTime.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public RoleUtilisateur getRole() { return role; }
    public void setRole(RoleUtilisateur role) { this.role = role; }

    public boolean isEstVerifie() { return estVerifie; }
    public void setEstVerifie(boolean estVerifie) { this.estVerifie = estVerifie; }

    public int getPointsFidelite() { return pointsFidelite; }
    public void setPointsFidelite(int pointsFidelite) { this.pointsFidelite = pointsFidelite; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getPhotoProfilUrl() { return photoProfilUrl; }
    public void setPhotoProfilUrl(String photoProfilUrl) { this.photoProfilUrl = photoProfilUrl; }

    public boolean isEstBanni() { return estBanni; }
    public void setEstBanni(boolean estBanni) { this.estBanni = estBanni; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

}   
