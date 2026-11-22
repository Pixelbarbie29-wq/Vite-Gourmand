// Serveur Express de Vite & Gourmand
require('dotenv').config();
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Test : le serveur répond-il, et la base aussi ?
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ serveur: 'ok', base: 'ok' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ serveur: 'ok', base: 'erreur' });
  }
});

// Liste des menus avec leur thème et leur régime
app.get('/api/menus', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT m.menu_id, m.titre, m.description, m.nombre_personnes_minimum,
             m.prix_minimum, m.quantite_restante,
             t.libelle AS theme, r.libelle AS regime
      FROM menu m
      JOIN theme t ON t.theme_id = m.theme_id
      JOIN regime r ON r.regime_id = m.regime_id
      ORDER BY m.menu_id
    `);
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

// Inscription d'un utilisateur
app.post('/api/auth/register', async (req, res) => {
  const { email, mot_de_passe, nom, prenom, telephone,
          adresse_postale, code_postal, ville } = req.body;

  if (!email || !mot_de_passe || !nom || !prenom) {
    return res.status(400).json({ erreur: 'Champs obligatoires manquants' });
  }

  // Mot de passe : 10 caractères min, majuscule, minuscule, chiffre, caractère spécial
  const mdpValide = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{10,}$/;
  if (!mdpValide.test(mot_de_passe)) {
    return res.status(400).json({
      erreur: 'Mot de passe : 10 caractères minimum, avec majuscule, minuscule, chiffre et caractère spécial'
    });
  }

  try {
    const hash = await bcrypt.hash(mot_de_passe, 10);
    const { rows } = await pool.query(
      `INSERT INTO utilisateur
         (email, mot_de_passe, nom, prenom, telephone, adresse_postale, code_postal, ville, role_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,
         (SELECT role_id FROM role WHERE libelle = 'utilisateur'))
       RETURNING utilisateur_id, email, nom, prenom`,
      [email, hash, nom, prenom, telephone, adresse_postale, code_postal, ville]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ erreur: 'Cet email est déjà utilisé' });
    }
    console.error(err.message);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

// Connexion
app.post('/api/auth/login', async (req, res) => {
  const { email, mot_de_passe } = req.body;
  try {
    const { rows } = await pool.query(
      `SELECT u.utilisateur_id, u.email, u.mot_de_passe, u.actif, r.libelle AS role
       FROM utilisateur u JOIN role r ON r.role_id = u.role_id
       WHERE u.email = $1`,
      [email]
    );
    const user = rows[0];
    const ok = user && user.actif && await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!ok) {
      return res.status(401).json({ erreur: 'Email ou mot de passe incorrect' });
    }
    const token = jwt.sign(
      { id: user.utilisateur_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '2h' }
    );
    res.json({ token, role: user.role });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
});

app.listen(PORT, () => {
  console.log(`Serveur lancé sur http://localhost:${PORT}`);
});