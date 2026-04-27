package com.adv.modules.audit.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "journaux_activite")
@Getter
@Setter
public class JournalActivite {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @Column(name = "utilisateur_id")
    private UUID utilisateurId;

    @Column(name = "action", nullable = false, length = 50)
    private String action;

    @Column(name = "details", columnDefinition = "TEXT")
    private String details;

    @Column(name = "adresse_ip", nullable = false, length = 45)
    private String adresseIp;

    @Column(name = "date_action", nullable = false, updatable = false)
    private Instant dateAction;

    @PrePersist
    protected void onCreate() {
        if (this.dateAction == null) {
            this.dateAction = Instant.now();
        }
    }

    // Constructeur statique pour remplacer le @Builder
    public static JournalActivite of(UUID utilisateurId, String action,
                                      String details, String adresseIp) {
        JournalActivite j = new JournalActivite();
        j.utilisateurId = utilisateurId;
        j.action        = action;
        j.details       = details;
        j.adresseIp     = adresseIp != null ? adresseIp : "UNKNOWN";
        return j;
    }
}