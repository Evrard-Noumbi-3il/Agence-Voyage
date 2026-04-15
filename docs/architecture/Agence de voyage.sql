CREATE TABLE "utilisateurs" (
  "id" uuid PRIMARY KEY,
  "nom" varchar,
  "prenom" varchar,
  "email" varchar UNIQUE,
  "telephone" varchar UNIQUE,
  "photo_profil_url" varchar,
  "est_verifie" boolean DEFAULT false,
  "est_banni" boolean DEFAULT false,
  "role" varchar,
  "points_fidelite" int DEFAULT 0,
  "created_at" timestamp
);

CREATE TABLE "verifications_identite" (
  "id" uuid PRIMARY KEY,
  "utilisateur_id" uuid,
  "type_document" varchar,
  "numero_document" varchar,
  "photo_recto_url" varchar,
  "photo_verso_url" varchar,
  "photo_selfie_url" varchar,
  "date_expiration_document" date,
  "statut" varchar,
  "date_soumission" timestamp
);

CREATE TABLE "villes" (
  "id" uuid PRIMARY KEY,
  "nom" varchar
);

CREATE TABLE "agences" (
  "id" uuid PRIMARY KEY,
  "ville_id" uuid,
  "nom_agence" varchar,
  "quartier" varchar,
  "description" text,
  "photos" varchar,
  "gps_lat" double,
  "gps_long" double
);

CREATE TABLE "types_vehicule" (
  "id" uuid PRIMARY KEY,
  "categorie" varchar,
  "description" text,
  "modele_3d_url" varchar
);

CREATE TABLE "vehicules" (
  "id" uuid PRIMARY KEY,
  "type_vehicule_id" uuid,
  "immatriculation" varchar UNIQUE,
  "nombre_sieges" int,
  "statut_stock" varchar
);

CREATE TABLE "sieges" (
  "id" uuid PRIMARY KEY,
  "vehicule_id" uuid,
  "numero_siege" varchar,
  "type_siege" varchar,
  "pos_x" float,
  "pos_y" float,
  "pos_z" float
);

CREATE TABLE "trajets" (
  "id" uuid PRIMARY KEY,
  "agence_depart_id" uuid,
  "agence_arrivee_id" uuid,
  "distance_km" int
);

CREATE TABLE "voyages" (
  "id" uuid PRIMARY KEY,
  "trajet_id" uuid,
  "vehicule_id" uuid,
  "chauffeur_id" uuid,
  "date_heure_depart" timestamp,
  "date_heure_arrivee_estime" timestamp,
  "prix_base" decimal,
  "statut_voyage" varchar
);

CREATE TABLE "reservations" (
  "id" uuid PRIMARY KEY,
  "utilisateur_id" uuid,
  "voyage_id" uuid,
  "date_reservation" timestamp,
  "montant_total" decimal,
  "statut_paiement" varchar
);

CREATE TABLE "billets" (
  "id" uuid PRIMARY KEY,
  "reservation_id" uuid,
  "siege_id" uuid,
  "nom_passager" varchar,
  "qr_code_token" varchar(128) UNIQUE,
  "statut_billet" varchar,
  "date_validation" timestamp,
  "valide_par_agent_id" uuid
);

CREATE TABLE "paiements" (
  "id" uuid PRIMARY KEY,
  "reservation_id" uuid,
  "reference_payunit" varchar UNIQUE,
  "cle_idempotence" varchar UNIQUE,
  "methode_paiement" varchar,
  "montant" decimal,
  "statut_transaction" varchar,
  "webhook_payload" varchar(4096),
  "date_transaction" timestamp
);

CREATE TABLE "journaux_activite" (
  "id" uuid PRIMARY KEY,
  "utilisateur_id" uuid,
  "action" varchar,
  "details" text,
  "adresse_ip" varchar,
  "date_action" timestamp
);

ALTER TABLE "verifications_identite" ADD FOREIGN KEY ("utilisateur_id") REFERENCES "utilisateurs" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agences" ADD FOREIGN KEY ("ville_id") REFERENCES "villes" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "vehicules" ADD FOREIGN KEY ("type_vehicule_id") REFERENCES "types_vehicule" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "sieges" ADD FOREIGN KEY ("vehicule_id") REFERENCES "vehicules" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "trajets" ADD FOREIGN KEY ("agence_depart_id") REFERENCES "agences" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "trajets" ADD FOREIGN KEY ("agence_arrivee_id") REFERENCES "agences" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "voyages" ADD FOREIGN KEY ("trajet_id") REFERENCES "trajets" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "voyages" ADD FOREIGN KEY ("vehicule_id") REFERENCES "vehicules" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "voyages" ADD FOREIGN KEY ("chauffeur_id") REFERENCES "utilisateurs" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reservations" ADD FOREIGN KEY ("utilisateur_id") REFERENCES "utilisateurs" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reservations" ADD FOREIGN KEY ("voyage_id") REFERENCES "voyages" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "billets" ADD FOREIGN KEY ("reservation_id") REFERENCES "reservations" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "billets" ADD FOREIGN KEY ("siege_id") REFERENCES "sieges" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "billets" ADD FOREIGN KEY ("valide_par_agent_id") REFERENCES "utilisateurs" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "paiements" ADD FOREIGN KEY ("reservation_id") REFERENCES "reservations" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "journaux_activite" ADD FOREIGN KEY ("utilisateur_id") REFERENCES "utilisateurs" ("id") DEFERRABLE INITIALLY IMMEDIATE;
