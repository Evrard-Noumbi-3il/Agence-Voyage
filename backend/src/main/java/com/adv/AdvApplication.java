package com.adv;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AdvApplication {

    protected AdvApplication() {
        // Constructeur vide pour Checkstyle
    }

    /**
     * Point d'entrée principal de l'application Spring Boot.
     * @param args arguments de ligne de commande.
     */
    public static void main(final String[] args) {
        SpringApplication.run(AdvApplication.class, args);
    }
}
