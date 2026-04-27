package com.adv.modules.audit.service;

import com.adv.modules.audit.entity.JournalActivite;
import com.adv.modules.audit.repository.JournalActiviteRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public final class AuditService {

    /**
     * Enregistre une action dans journaux_activite.
     * Exécuté dans une transaction indépendante — un échec ici
     * ne rollback pas la transaction métier appelante.
     * Asynchrone pour ne pas bloquer la réponse HTTP.
     *
     * @param utilisateurId UUID de l'utilisateur (null si action système)
     * @param action        Code action — ex: LOGIN_SUCCESS, RESERVATION_CREEE
     * @param details       Détails libres — ex: "voyage_id=xxx, siege=12A"
     * @param adresseIp     IP réelle extraite via ForwardedHeaderFilter
     */

    private static final Logger LOG = LoggerFactory.getLogger(AuditService.class);

    private final JournalActiviteRepository journalRepository;

    public AuditService(final JournalActiviteRepository journalRepository) {
        this.journalRepository = journalRepository;
    }

    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(final UUID utilisateurId, final String action, final  String details, final String adresseIp) {
        try {
            JournalActivite journal = JournalActivite.of(
                    utilisateurId,
                    action,
                    details,
                    adresseIp
            );
            journalRepository.save(journal);

        } catch (Exception e) {
            LOG.error("[AUDIT] Échec écriture journal — action={}, utilisateur={}, erreur={}",
                    action, utilisateurId, e.getMessage());
        }
    }
}
