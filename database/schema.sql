-- =====================================================================
-- Vite & Gourmand - Création de la base de données relationnelle
-- SGBD : PostgreSQL (hébergé sur Supabase)
-- Ce script est rejouable : il supprime puis recrée toutes les tables.
-- =====================================================================

DROP TABLE IF EXISTS reinitialisation_mdp CASCADE;
DROP TABLE IF EXISTS avis CASCADE;
DROP TABLE IF EXISTS suivi_commande CASCADE;
DROP TABLE IF EXISTS commande CASCADE;
DROP TABLE IF EXISTS plat_allergene CASCADE;
DROP TABLE IF EXISTS menu_plat CASCADE;
DROP TABLE IF EXISTS menu_image CASCADE;
DROP TABLE IF EXISTS menu CASCADE;
DROP TABLE IF EXISTS plat CASCADE;
DROP TABLE IF EXISTS allergene CASCADE;
DROP TABLE IF EXISTS theme CASCADE;
DROP TABLE IF EXISTS regime CASCADE;
DROP TABLE IF EXISTS horaire CASCADE;
DROP TABLE IF EXISTS utilisateur CASCADE;
DROP TABLE IF EXISTS role CASCADE;

-- ---------------------------------------------------------------------
-- Rôles et utilisateurs
-- ---------------------------------------------------------------------
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE utilisateur (
    utilisateur_id  SERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,          -- sert d'identifiant de connexion
    mot_de_passe    VARCHAR(255) NOT NULL,                 -- toujours un hash (bcrypt), jamais en clair
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    telephone       VARCHAR(20),
    adresse_postale VARCHAR(255),
    code_postal     VARCHAR(10),
    ville           VARCHAR(100),
    pays            VARCHAR(100) NOT NULL DEFAULT 'France',
    actif           BOOLEAN NOT NULL DEFAULT TRUE,         -- FALSE = compte rendu inutilisable (ex. départ d'un employé)
    role_id         INT NOT NULL REFERENCES role(role_id),
    date_creation   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Jeton de réinitialisation du mot de passe (on stocke le hash du jeton, pas le jeton)
CREATE TABLE reinitialisation_mdp (
    reinitialisation_id SERIAL PRIMARY KEY,
    utilisateur_id      INT NOT NULL REFERENCES utilisateur(utilisateur_id) ON DELETE CASCADE,
    jeton_hash          VARCHAR(255) NOT NULL,
    date_expiration     TIMESTAMP NOT NULL,
    utilise             BOOLEAN NOT NULL DEFAULT FALSE
);

-- ---------------------------------------------------------------------
-- Catalogue : thèmes, régimes, allergènes, plats, menus
-- ---------------------------------------------------------------------
CREATE TABLE theme (
    theme_id SERIAL PRIMARY KEY,
    libelle  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE regime (
    regime_id SERIAL PRIMARY KEY,
    libelle   VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE allergene (
    allergene_id SERIAL PRIMARY KEY,
    libelle      VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE plat (
    plat_id   SERIAL PRIMARY KEY,
    nom       VARCHAR(150) NOT NULL,
    type_plat VARCHAR(20) NOT NULL CHECK (type_plat IN ('entree', 'plat', 'dessert')),
    photo_url VARCHAR(500)                                  -- chemin ou URL de l'image (plutôt qu'un BLOB en base)
);

-- Un plat peut contenir plusieurs allergènes
CREATE TABLE plat_allergene (
    plat_id      INT NOT NULL REFERENCES plat(plat_id) ON DELETE CASCADE,
    allergene_id INT NOT NULL REFERENCES allergene(allergene_id) ON DELETE CASCADE,
    PRIMARY KEY (plat_id, allergene_id)
);

CREATE TABLE menu (
    menu_id                    SERIAL PRIMARY KEY,
    titre                      VARCHAR(150) NOT NULL,
    description                TEXT NOT NULL,
    nombre_personnes_minimum   INT NOT NULL CHECK (nombre_personnes_minimum > 0),
    prix_minimum               NUMERIC(10,2) NOT NULL CHECK (prix_minimum >= 0),  -- prix pour le nombre minimum de personnes
    conditions                 TEXT NOT NULL,              -- délai de commande, précautions de stockage...
    quantite_restante          INT NOT NULL DEFAULT 0 CHECK (quantite_restante >= 0),
    theme_id                   INT NOT NULL REFERENCES theme(theme_id),
    regime_id                  INT NOT NULL REFERENCES regime(regime_id)
);

-- Galerie d'images d'un menu
CREATE TABLE menu_image (
    image_id SERIAL PRIMARY KEY,
    menu_id  INT NOT NULL REFERENCES menu(menu_id) ON DELETE CASCADE,
    url      VARCHAR(500) NOT NULL,
    ordre    INT NOT NULL DEFAULT 1
);

-- Un plat peut être présent dans plusieurs menus
CREATE TABLE menu_plat (
    menu_id INT NOT NULL REFERENCES menu(menu_id) ON DELETE CASCADE,
    plat_id INT NOT NULL REFERENCES plat(plat_id) ON DELETE CASCADE,
    PRIMARY KEY (menu_id, plat_id)
);

-- ---------------------------------------------------------------------
-- Horaires d'ouverture (pied de page)
-- ---------------------------------------------------------------------
CREATE TABLE horaire (
    horaire_id      SERIAL PRIMARY KEY,
    jour            VARCHAR(10) NOT NULL UNIQUE,
    heure_ouverture TIME,
    heure_fermeture TIME
);

-- ---------------------------------------------------------------------
-- Commandes et suivi
-- ---------------------------------------------------------------------
CREATE TABLE commande (
    commande_id             SERIAL PRIMARY KEY,
    numero_commande         VARCHAR(30) NOT NULL UNIQUE,
    utilisateur_id          INT NOT NULL REFERENCES utilisateur(utilisateur_id),
    menu_id                 INT NOT NULL REFERENCES menu(menu_id),
    date_commande           TIMESTAMP NOT NULL DEFAULT NOW(),
    date_prestation         DATE NOT NULL,
    heure_livraison         TIME NOT NULL,
    adresse_livraison       VARCHAR(255) NOT NULL,
    ville_livraison         VARCHAR(100) NOT NULL,
    distance_km             NUMERIC(6,1) NOT NULL DEFAULT 0 CHECK (distance_km >= 0),  -- km hors de Bordeaux
    nombre_personnes        INT NOT NULL CHECK (nombre_personnes > 0),
    prix_menu               NUMERIC(10,2) NOT NULL,        -- après remise éventuelle de 10 %
    remise                  NUMERIC(10,2) NOT NULL DEFAULT 0,
    prix_livraison          NUMERIC(10,2) NOT NULL DEFAULT 0,  -- 5 € + 0,59 € par km hors Bordeaux
    statut                  VARCHAR(30) NOT NULL DEFAULT 'en_attente'
                            CHECK (statut IN ('en_attente', 'accepte', 'en_preparation', 'en_cours_livraison',
                                              'livre', 'attente_retour_materiel', 'terminee', 'annulee')),
    pret_materiel           BOOLEAN NOT NULL DEFAULT FALSE,
    restitution_materiel    BOOLEAN NOT NULL DEFAULT FALSE,
    mode_contact_annulation VARCHAR(10) CHECK (mode_contact_annulation IN ('gsm', 'mail')),
    motif_annulation        TEXT
);

-- Historique : une ligne à chaque changement de statut (état + date et heure)
CREATE TABLE suivi_commande (
    suivi_id         SERIAL PRIMARY KEY,
    commande_id      INT NOT NULL REFERENCES commande(commande_id) ON DELETE CASCADE,
    statut           VARCHAR(30) NOT NULL,
    date_changement  TIMESTAMP NOT NULL DEFAULT NOW(),
    employe_id       INT REFERENCES utilisateur(utilisateur_id)  -- qui a fait le changement (vide si c'est le système)
);

-- ---------------------------------------------------------------------
-- Avis clients (donnés depuis une commande terminée)
-- ---------------------------------------------------------------------
CREATE TABLE avis (
    avis_id         SERIAL PRIMARY KEY,
    commande_id     INT NOT NULL UNIQUE REFERENCES commande(commande_id) ON DELETE CASCADE,  -- un avis par commande
    utilisateur_id  INT NOT NULL REFERENCES utilisateur(utilisateur_id),
    note            SMALLINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    description     TEXT NOT NULL,
    statut          VARCHAR(20) NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'valide', 'refuse')),
    date_creation   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Index pour les recherches fréquentes (filtres, suivi des commandes)
-- ---------------------------------------------------------------------
CREATE INDEX idx_menu_theme ON menu(theme_id);
CREATE INDEX idx_menu_regime ON menu(regime_id);
CREATE INDEX idx_menu_prix ON menu(prix_minimum);
CREATE INDEX idx_commande_utilisateur ON commande(utilisateur_id);
CREATE INDEX idx_commande_statut ON commande(statut);
CREATE INDEX idx_suivi_commande ON suivi_commande(commande_id);
