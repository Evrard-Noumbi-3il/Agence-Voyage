package com.adv.modules.auth.service;

import com.adv.modules.auth.entities.Utilisateur;
import com.adv.modules.auth.repository.UtilisateurRepository;
import com.adv.modules.auth.enums.RoleUtilisateur;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.util.UUID;

@Service
public class AuthSyncService {

    private final UtilisateurRepository utilisateurRepository;
    private static final Logger log = LoggerFactory.getLogger(AuthSyncService.class);

    public AuthSyncService(UtilisateurRepository utilisateurRepository) {
        this.utilisateurRepository = utilisateurRepository;
    }

    @Transactional
    public Utilisateur syncUser(Jwt jwt) {
        UUID keycloakId = UUID.fromString(jwt.getSubject());
        
        return utilisateurRepository.findById(keycloakId)
            .map(existingUser -> {
                existingUser.setNom(jwt.getClaimAsString("family_name"));
                existingUser.setPrenom(jwt.getClaimAsString("given_name"));
                return utilisateurRepository.save(existingUser);
            })
            .orElseGet(() -> {
                log.info("Creation d'un nouveau voyageur : {}", jwt.getClaimAsString("email"));
                Utilisateur newUser = new Utilisateur(
                    keycloakId,
                    jwt.getClaimAsString("email"),
                    jwt.getClaimAsString("family_name"),
                    jwt.getClaimAsString("given_name"),
                    RoleUtilisateur.VOYAGEUR
                );
                return utilisateurRepository.save(newUser);
            });
    }

}