-- =====================================================================
-- Vite & Gourmand - Données de test (à exécuter après schema.sql)
-- Les menus, plats et avis sont des exemples.
-- =====================================================================

-- Rôles
INSERT INTO role (role_id, libelle) VALUES
    (1, 'utilisateur'),
    (2, 'employe'),
    (3, 'administrateur');

-- Compte administrateur : créé directement en base, jamais depuis l'application.
-- IMPORTANT : remplacer la valeur ci-dessous par un hash bcrypt réel avant utilisation
-- (le mot de passe ne doit jamais apparaître en clair dans ce dépôt public).
INSERT INTO utilisateur (email, mot_de_passe, nom, prenom, telephone, adresse_postale, code_postal, ville, pays, role_id) VALUES
    ('admin@vite-gourmand.fr', 'A_REMPLACER_PAR_UN_HASH_BCRYPT', 'Admin', 'José', '0556000000',
     '12 rue des Gourmets', '33000', 'Bordeaux', 'France', 3);

-- Thèmes
INSERT INTO theme (theme_id, libelle) VALUES
    (1, 'Noël'), (2, 'Pâques'), (3, 'Classique'), (4, 'Événement');

-- Régimes
INSERT INTO regime (regime_id, libelle) VALUES
    (1, 'Classique'), (2, 'Végétarien'), (3, 'Vegan');

-- Allergènes
INSERT INTO allergene (allergene_id, libelle) VALUES
    (1, 'Gluten'), (2, 'Lait'), (3, 'Œufs'), (4, 'Poisson'),
    (5, 'Céleri'), (6, 'Fruits à coque'), (7, 'Arachides'), (8, 'Soja');

-- Plats
INSERT INTO plat (plat_id, nom, type_plat) VALUES
    (1,  'Foie gras maison, chutney de figues', 'entree'),
    (2,  'Velouté de potimarron',               'entree'),
    (3,  'Chapon rôti, sauce aux marrons',      'plat'),
    (4,  'Gratin dauphinois',                   'plat'),
    (5,  'Bûche glacée vanille-framboise',      'dessert'),
    (6,  'Salade d''agrumes',                   'dessert'),
    (7,  'Œufs brouillés à la ciboulette',      'plat'),
    (8,  'Viennoiseries maison',                'dessert'),
    (9,  'Salade de saison',                    'entree'),
    (10, 'Ragoût de légumes d''hiver',          'plat'),
    (11, 'Tarte fine aux pommes',               'dessert'),
    (12, 'Mini-quiches assorties',              'entree'),
    (13, 'Verrines sucrées',                    'dessert'),
    (14, 'Curry de pois chiches',               'plat'),
    (15, 'Mousse chocolat-avocat',              'dessert'),
    (16, 'Blinis au saumon fumé',               'entree'),
    (17, 'Filet de bœuf, sauce au poivre',      'plat');

-- Allergènes de chaque plat
INSERT INTO plat_allergene (plat_id, allergene_id) VALUES
    (1, 1),
    (2, 2),
    (3, 2),
    (4, 2),
    (5, 2), (5, 3), (5, 1),
    (7, 3), (7, 2),
    (8, 1), (8, 2), (8, 3),
    (10, 5),
    (11, 1), (11, 2), (11, 3),
    (12, 1), (12, 2), (12, 3),
    (13, 2),
    (16, 4), (16, 1), (16, 2),
    (17, 2);

-- Menus
INSERT INTO menu (menu_id, titre, description, nombre_personnes_minimum, prix_minimum, conditions, quantite_restante, theme_id, regime_id) VALUES
    (1, 'Menu de Noël traditionnel',
        'Un repas de fête complet, du foie gras maison à la bûche glacée, pensé pour réunir toute la famille autour de la table.',
        6, 180.00,
        'À commander au moins 7 jours avant la prestation. À conserver entre 0 et 4 °C et à consommer sous 48 h. Prêt de matériel possible (600 € de frais si non rendu sous 10 jours ouvrés).',
        5, 1, 1),
    (2, 'Brunch de Pâques',
        'Un brunch généreux : œufs, viennoiseries maison, salades de saison et douceurs.',
        4, 96.00,
        'À commander au moins 3 jours avant la prestation. À consommer le jour de la livraison.',
        8, 2, 2),
    (3, 'Repas de famille',
        'Entrée, plat mijoté et dessert maison pour réunir toute la tablée.',
        8, 220.00,
        'À commander au moins 5 jours avant la prestation. À conserver au frais.',
        6, 3, 1),
    (4, 'Cocktail d''entreprise',
        'Pièces salées et sucrées pour vos réceptions et vos séminaires.',
        20, 450.00,
        'À commander au moins 10 jours avant la prestation. Prêt de matériel possible (600 € de frais si non rendu sous 10 jours ouvrés).',
        3, 4, 1),
    (5, 'Menu vegan du jardin',
        'Une cuisine 100 % végétale, colorée et de saison, sans produit d''origine animale.',
        6, 150.00,
        'À commander au moins 5 jours avant la prestation. À conserver entre 0 et 4 °C.',
        7, 4, 3),
    (6, 'Réveillon gourmand',
        'Un menu de réveillon en plusieurs services, avec des produits d''exception.',
        10, 350.00,
        'À commander au moins 14 jours avant la prestation. Prêt de matériel possible (600 € de frais si non rendu sous 10 jours ouvrés).',
        4, 1, 1);

-- Composition des menus
INSERT INTO menu_plat (menu_id, plat_id) VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
    (2, 7), (2, 8), (2, 9), (2, 13),
    (3, 2), (3, 10), (3, 11),
    (4, 12), (4, 16), (4, 13),
    (5, 9), (5, 14), (5, 15), (5, 10),
    (6, 16), (6, 17), (6, 3), (6, 5);

-- Une image par menu (chemins à adapter selon l'hébergement des images)
INSERT INTO menu_image (menu_id, url, ordre) VALUES
    (1, '/images/menus/noel-traditionnel-1.jpg', 1),
    (2, '/images/menus/brunch-paques-1.jpg', 1),
    (3, '/images/menus/repas-famille-1.jpg', 1),
    (4, '/images/menus/cocktail-entreprise-1.jpg', 1),
    (5, '/images/menus/vegan-jardin-1.jpg', 1),
    (6, '/images/menus/reveillon-gourmand-1.jpg', 1);

-- Horaires (pied de page)
INSERT INTO horaire (jour, heure_ouverture, heure_fermeture) VALUES
    ('Lundi',    '09:00', '19:00'),
    ('Mardi',    '09:00', '19:00'),
    ('Mercredi', '09:00', '19:00'),
    ('Jeudi',    '09:00', '19:00'),
    ('Vendredi', '09:00', '19:00'),
    ('Samedi',   '09:00', '17:00'),
    ('Dimanche', '10:00', '14:00');

-- Remise à jour des compteurs d'identifiants (les lignes ci-dessus ont des identifiants fixés à la main)
SELECT setval(pg_get_serial_sequence('role', 'role_id'),           (SELECT MAX(role_id) FROM role));
SELECT setval(pg_get_serial_sequence('theme', 'theme_id'),         (SELECT MAX(theme_id) FROM theme));
SELECT setval(pg_get_serial_sequence('regime', 'regime_id'),       (SELECT MAX(regime_id) FROM regime));
SELECT setval(pg_get_serial_sequence('allergene', 'allergene_id'), (SELECT MAX(allergene_id) FROM allergene));
SELECT setval(pg_get_serial_sequence('plat', 'plat_id'),           (SELECT MAX(plat_id) FROM plat));
SELECT setval(pg_get_serial_sequence('menu', 'menu_id'),           (SELECT MAX(menu_id) FROM menu));
