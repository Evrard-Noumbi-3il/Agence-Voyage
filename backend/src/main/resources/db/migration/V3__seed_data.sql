-- =============================================================================
-- V3__seed_data.sql
-- Projet : General Express Voyages
-- Auteur  : Evrard NOUMBI — Avril 2026
-- Objectif : Données de test représentatives de la réalité GEV
-- IMPORTANT : Ce fichier est pour DEV et STAGING uniquement.
--             Ne jamais exécuter en PRODUCTION.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- VILLES (villes desservies par General Express Voyages)
-- -----------------------------------------------------------------------------
INSERT INTO villes (id, nom) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Yaoundé'),
    ('00000000-0000-0000-0000-000000000002', 'Douala'),
    ('00000000-0000-0000-0000-000000000003', 'Bafoussam'),
    ('00000000-0000-0000-0000-000000000004', 'Dschang'),
    ('00000000-0000-0000-0000-000000000005', 'Mbouda'),
    ('00000000-0000-0000-0000-000000000006', 'Bangang'),
    ('00000000-0000-0000-0000-000000000007', 'Batcham'),
    ('00000000-0000-0000-0000-000000000008', 'Balessing'),
    ('00000000-0000-0000-0000-000000000009', 'Bamougoum'),
    ('00000000-0000-0000-0000-000000000010', 'Bonaberi'),
    ('00000000-0000-0000-0000-000000000011', 'Mboppi'),
    ('00000000-0000-0000-0000-000000000012', 'Batcham'),
    ('00000000-0000-0000-0000-000000000013', 'Brazzaville');

-- -----------------------------------------------------------------------------
-- AGENCES (agences réelles General Express Voyages)
-- -----------------------------------------------------------------------------
INSERT INTO agences (id, ville_id, nom_agence, quartier, description) VALUES
    -- Yaoundé
    ('10000000-0000-0000-0000-000000000001',
     '00000000-0000-0000-0000-000000000001',
     'GEV Biyem-Assi', 'Biyem-Assi',
     'Agence principale de Yaoundé. Départs vers Douala, Bafoussam, Dschang, Mbouda.'),
    ('10000000-0000-0000-0000-000000000002',
     '00000000-0000-0000-0000-000000000001',
     'GEV Mvan', 'Mvan',
     'Agence Mvan — Yaoundé. Service 24h/24h. Ligne Yaoundé-Douala-Bafoussam.'),
    ('10000000-0000-0000-0000-000000000003',
     '00000000-0000-0000-0000-000000000001',
     'GEV Carrière', 'Carrière',
     'Agence Carrière — Yaoundé. Départs nocturnes vers l''Ouest Cameroun.'),
    ('10000000-0000-0000-0000-000000000004',
     '00000000-0000-0000-0000-000000000001',
     'GEV Mimboman', 'Mimboman',
     'Agence Mimboman — Yaoundé. Connexions vers Bafoussam, Dschang, Mbouda.'),
    ('10000000-0000-0000-0000-000000000005',
     '00000000-0000-0000-0000-000000000001',
     'GEV Olembe', 'Olembe',
     'Agence Olembe — Yaoundé. Départs matinaux et nocturnes.'),
    -- Douala
    ('10000000-0000-0000-0000-000000000006',
     '00000000-0000-0000-0000-000000000002',
     'GEV Bepanda', 'Bepanda',
     'Agence Bepanda — Douala. Départs vers Yaoundé et l''Ouest.'),
    ('10000000-0000-0000-0000-000000000007',
     '00000000-0000-0000-0000-000000000002',
     'GEV Bonaberi', 'Bonaberi',
     'Agence Bonaberi — Douala. Desserte de Bafoussam, Mbouda, Dschang.'),
    ('10000000-0000-0000-0000-000000000008',
     '00000000-0000-0000-0000-000000000002',
     'GEV Mboppi', 'Mboppi',
     'Agence Mboppi — Douala. Départs 4h00 à 21h00. Service colis disponible.'),
    ('10000000-0000-0000-0000-000000000009',
     '00000000-0000-0000-0000-000000000002',
     'GEV Brazzaville', 'Brazzaville',
     'Agence Brazzaville — Douala. Connexions Bafoussam, Bangang, Mbouda.'),
    -- Bafoussam
    ('10000000-0000-0000-0000-000000000010',
     '00000000-0000-0000-0000-000000000003',
     'GEV Bafoussam Central', 'Centre-ville',
     'Agence centrale de Bafoussam. Hub principal de l''Ouest Cameroun.');

-- -----------------------------------------------------------------------------
-- TYPES DE VÉHICULE
-- -----------------------------------------------------------------------------
INSERT INTO types_vehicule (id, categorie, description) VALUES
    ('20000000-0000-0000-0000-000000000001',
     'CLASSIQUE',
     'Bus standard 69 places. Climatisation, bagages en soute. Confort de base.'),
    ('20000000-0000-0000-0000-000000000002',
     'VIP',
     'Bus VIP 48-54 places. Sièges inclinables larges, prises électriques, climatisation renforcée, toilettes.'),
    ('20000000-0000-0000-0000-000000000003',
     'MOYEN',
     'Minibus 20-30 places. Flexible, dessert les villes secondaires et zones rurales.');

-- -----------------------------------------------------------------------------
-- VÉHICULES (immatriculations réelles visibles sur le site GEV)
-- -----------------------------------------------------------------------------
INSERT INTO vehicules (id, type_vehicule_id, immatriculation, nombre_sieges, statut_stock) VALUES
    ('30000000-0000-0000-0000-000000000001',
     '20000000-0000-0000-0000-000000000001', 'LT953IS', 69, 'EN_SERVICE'),
    ('30000000-0000-0000-0000-000000000002',
     '20000000-0000-0000-0000-000000000001', 'LT812FM', 69, 'EN_SERVICE'),
    ('30000000-0000-0000-0000-000000000003',
     '20000000-0000-0000-0000-000000000002', 'LT843KD', 48, 'EN_SERVICE'),
    ('30000000-0000-0000-0000-000000000004',
     '20000000-0000-0000-0000-000000000002', 'LT401GN', 54, 'EN_SERVICE'),
    ('30000000-0000-0000-0000-000000000005',
     '20000000-0000-0000-0000-000000000003', 'LT748KN', 26, 'AU_GARAGE'),
    ('30000000-0000-0000-0000-000000000006',
     '20000000-0000-0000-0000-000000000001', 'LT395JZ', 69, 'EN_SERVICE');

-- -----------------------------------------------------------------------------
-- TRAJETS (lignes réelles GEV)
-- -----------------------------------------------------------------------------
INSERT INTO trajets (id, agence_depart_id, agence_arrivee_id, distance_km, est_direct) VALUES
    -- Yaoundé → Douala (ligne principale)
    ('40000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000001',  -- Biyem-Assi
     '10000000-0000-0000-0000-000000000007',  -- Bonaberi
     240, TRUE),
    -- Yaoundé → Bafoussam
    ('40000000-0000-0000-0000-000000000002',
     '10000000-0000-0000-0000-000000000001',  -- Biyem-Assi
     '10000000-0000-0000-0000-000000000010',  -- Bafoussam Central
     310, TRUE),
    -- Yaoundé → Dschang
    ('40000000-0000-0000-0000-000000000003',
     '10000000-0000-0000-0000-000000000001',  -- Biyem-Assi
     '10000000-0000-0000-0000-000000000010',  -- via Bafoussam
     350, FALSE),
    -- Douala → Bafoussam
    ('40000000-0000-0000-0000-000000000004',
     '10000000-0000-0000-0000-000000000008',  -- Mboppi
     '10000000-0000-0000-0000-000000000010',  -- Bafoussam Central
     190, TRUE),
    -- Carrière → Bafoussam
    ('40000000-0000-0000-0000-000000000005',
     '10000000-0000-0000-0000-000000000003',  -- Carrière
     '10000000-0000-0000-0000-000000000010',  -- Bafoussam Central
     310, TRUE);