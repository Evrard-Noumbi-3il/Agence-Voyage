package com.adv.modules.audit.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.PrePersist;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "journaux_activite")
@Getter
@Setter
public final class JournalActivite {
    private static final int MAX_ACTION_LENGTH = 50;
    private static final int MAX_IP_LENGTH = 45;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @Column(name = "utilisateur_id")
    private UUID utilisateurId;

    @Column(name = "action", nullable = false, length = MAX_ACTION_LENGTH)
    private String action;

    @Column(name = "details", columnDefinition = "TEXT")
    private String details;

    @Column(name = "adresse_ip", nullable = false, length = MAX_IP_LENGTH)
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
    public static JournalActivite of(final UUID utilisateurId, final String action,
                                      final String details, final String adresseIp) {
        JournalActivite j = new JournalActivite();
        j.utilisateurId = utilisateurId;
        j.action        = action;
        j.details       = details;
        j.adresseIp     = adresseIp != null ? adresseIp : "UNKNOWN";
        return j;
    }
}
