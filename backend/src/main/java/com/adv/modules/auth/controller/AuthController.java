package com.adv.modules.auth.controller;

import com.adv.modules.auth.dto.LogoutRequest;
import com.adv.modules.auth.entities.Utilisateur;
import com.adv.modules.auth.repository.UtilisateurRepository;
import com.adv.modules.auth.service.AuthService;
import com.adv.modules.auth.service.AuthSyncService;
import com.adv.modules.audit.service.AuditService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final AuthSyncService authSyncService;
    private final AuditService auditService;
    private final UtilisateurRepository utilisateurRepository;


    public AuthController(AuthService authService, 
                          AuthSyncService authSyncService, 
                          AuditService auditService,
                          UtilisateurRepository utilisateurRepository) {
        this.authService = authService;
        this.authSyncService = authSyncService;
        this.auditService = auditService;
        this.utilisateurRepository = utilisateurRepository;
    }

    @Operation(summary = "Synchronisation du profil — Crée ou met à jour l'utilisateur local via Keycloak")
    @SecurityRequirement(name = "bearerAuth")
    @PostMapping("/sync")
    public ResponseEntity<Utilisateur> syncProfile(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest httpRequest
    ) {
        // 1. Synchronisation de l'utilisateur avec la DB PostgreSQL
        Utilisateur utilisateur = authSyncService.syncUser(jwt);

        // 2. Audit de la synchronisation (Optionnel mais recommandé)
        auditService.log(
            utilisateur.getId(),
            "SYNCHRONISATION_PROFIL",
            "Profil synchronise avec succes apres authentification",
            httpRequest.getRemoteAddr()
        );

        return ResponseEntity.ok(utilisateur);
    }

    @Operation(summary = "Déconnexion — révocation du refresh token Keycloak")
    @SecurityRequirement(name = "bearerAuth")
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @Valid @RequestBody LogoutRequest request,
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest httpRequest
    ) {
        String utilisateurId = jwt.getSubject();

        authService.revokeRefreshToken(request.refreshToken());

        if (utilisateurRepository.existsById(UUID.fromString(utilisateurId))) {
            auditService.log(
                UUID.fromString(utilisateurId),
                "DECONNEXION",
                "Refresh token revoque",
                httpRequest.getRemoteAddr()
            );
        } 

        return ResponseEntity.ok().build();
    }
}
