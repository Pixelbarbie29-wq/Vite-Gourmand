// Serveur Express de Vite & Gourmand
require('dotenv').config();
const express = require('express');
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

app.listen(PORT, () => {
  console.log(`Serveur lancé sur http://localhost:${PORT}`);
});
