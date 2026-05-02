package com.adv.modules.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final RestTemplate restTemplate;

    @Value("${keycloak.revocation-endpoint}")
    private String revocationEndpoint;

    @Value("${keycloak.client-id}")
    private String clientId;

    public AuthService() {
        this.restTemplate = new RestTemplate();
    }

    public void revokeRefreshToken(String refreshToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("token", refreshToken);
        body.add("token_type_hint", "refresh_token");
        body.add("client_id", clientId);

        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(body, headers);

        try {
            restTemplate.postForEntity(revocationEndpoint, entity, Void.class);
            log.info("[AUTH] Refresh token révoqué avec succès");
        } catch (Exception e) {
            // On loggue mais on ne fait pas planter le logout
            // Le token expirera naturellement
            log.warn("[AUTH] Échec révocation token Keycloak : {}", e.getMessage());
        }
    }
}