package com.adv;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test") // Utiliser le profil de test pour éviter d'affecter la base de données de production
class AdvApplicationTests {

	@Test
	void contextLoads() {
        // Test de base pour vérifier que l'application démarre
	}

}