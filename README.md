<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0-44aadd?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Cultures-47-44cc66?style=for-the-badge" alt="47 Cultures">
  <img src="https://img.shields.io/badge/R%C3%A9gions-48-ffcc00?style=for-the-badge" alt="48 Régions">
  <img src="https://img.shields.io/badge/Licence-MIT-aa66dd?style=for-the-badge" alt="MIT License">
  <img src="https://img.shields.io/badge/Made%20in-Morocco%20%F0%9F%87%B2%F0%9F%87%A6-dd4444?style=for-the-badge" alt="Made in Morocco">
</p>

<h1 align="center">🌱 SEVE AgTech</h1>
<h3 align="center">Simulation Économique et Végétale pour l'Entreprise Agricole</h3>

<p align="center">
  <strong>Le premier simulateur techno-économique agricole professionnel 100% marocain</strong><br>
  47 cultures · 48 régions · Modèle FAO-56 · Financement FDA · 100% offline
</p>

<p align="center">
  <a href="https://simobouzarki.github.io/seve-agtech/">🌐 Démo en ligne</a> ·
  <a href="#fonctionnalités">✨ Fonctionnalités</a> ·
  <a href="#démarrage-rapide">🚀 Démarrage</a> ·
  <a href="#architecture">🏗️ Architecture</a> ·
  <a href="#roadmap">📍 Roadmap</a>
</p>

---

## 🎯 Le Problème

Les agriculteurs marocains prennent des **décisions d'investissement de millions de dirhams** sans outils de simulation adaptés à leur contexte. Les solutions existantes sont soit importées (non adaptées au Maroc), soit trop simplistes, soit inaccessibles (coût, langue, complexité).

## 💡 La Solution

**SEVE AgTech** est un simulateur techno-économique complet qui combine :

- **Modélisation scientifique** (FAO-56, Liebig NPK, GDD) calibrée sur les données marocaines
- **47 espèces** avec variétés locales et rendements régionaux INRA/ONCA
- **48 régions** avec données climatiques mensuelles réelles
- **Financement FDA** (Génération Green) intégré avec calcul automatique des subventions
- **Dossier bancaire** générable en PDF pour demande de crédit

## ✨ Fonctionnalités

### 🧮 Moteur de Calcul Scientifique
| Module | Modèle | Description |
|--------|--------|-------------|
| Bilan Hydrique | FAO-56 | ET0, ETc, Kc par stade, stress hydrique (Ks) |
| Nutrition | Liebig | Bilan NPK, facteur limitant, plan de fertigation |
| Rendement | LUE + GDD | Modèle radiation × indice de récolte |
| Risques | Multi-facteur | Score climatique, marché, phytosanitaire, financier |
| Business Plan | 10 ans | Projection multi-annuelle avec variabilité climatique |

### 📊 30+ Panneaux de Résultats
- Rendement prévisionnel et analyse de sensibilité
- Compte d'exploitation détaillé (charges/produits)
- Calendrier phénologique et BPA
- Plan d'irrigation et fertigation
- Trésorerie mensuelle et seuil de rentabilité
- Dossier FDA/banque exportable en PDF
- Analyse SWOT et aide à la décision
- Empreinte eau et carbone

### 🗺️ Carte Interactive du Maroc
- Carte SVG cliquable des 12 régions administratives
- Synchronisation bidirectionnelle avec le sélecteur de région
- Données météo en temps réel (API Open-Meteo)

### 🔬 Outils Avancés
- **Comparateur de cultures** : comparez jusqu'à 3 cultures côte à côte
- **Visite guidée** : démonstration automatique en 5 étapes
- **Modules GEA** : qualité/HACCP, équipement, RH, approvisionnement, HSE

### 📱 PWA Offline
- Fonctionne 100% hors ligne après le premier chargement
- Installable sur mobile et desktop
- Aucune dépendance serveur pour les calculs

## 🚀 Démarrage Rapide

### Option 1 : En ligne (recommandé)
Visitez **[simobouzarki.github.io/seve-agtech](https://simobouzarki.github.io/seve-agtech/)**

### Option 2 : En local
```bash
# Cloner le projet
git clone https://github.com/simobouzarki/seve-agtech.git
cd seve-agtech

# Ouvrir directement (aucun build requis)
open modele_seve.html
# ou servir localement
python -m http.server 8000
# → http://localhost:8000/modele_seve.html
```

> **Aucune installation requise** — pas de Node.js, pas de npm, pas de build. Un navigateur suffit.

## 🏗️ Architecture

```
seve-agtech/
├── index.html              # Landing page commerciale
├── modele_seve.html        # Application principale (~16,000 lignes)
├── sw.js                   # Service Worker (PWA offline)
├── 404.html                # Page 404 stylisée
├── supabase_setup.sql      # Schéma base de données
├── SETUP_SUPABASE.md       # Guide d'installation Supabase
└── README.md               # Ce fichier
```

### Stack Technique

| Composant | Technologie |
|-----------|-------------|
| Frontend | HTML/CSS/JS vanilla (single-file, zero dependency) |
| Calculs | Moteur JS embarqué (FAO-56, Liebig, LUE) |
| Auth | Supabase Auth (optionnel) |
| Données | LocalStorage + Supabase PostgreSQL (optionnel) |
| Hébergement | GitHub Pages (statique) |
| PWA | Service Worker cache-first |
| Météo | Open-Meteo API (gratuit, sans clé) |

### Données Scientifiques

- **Cultures** : 47 espèces × variétés locales (données INRA Meknès, ONCA)
- **Régions** : 48 zones avec T°, précipitations, ET0 mensuelles (données OMM)
- **FDA** : Barèmes officiels du Fonds de Développement Agricole 2024
- **Itinéraires** : Basés sur les guides ORMVA et fiches techniques ONCA

## 📍 Roadmap

Consultez les [Issues](https://github.com/simobouzarki/seve-agtech/issues) pour le backlog détaillé.

### Phase 1 — MVP (✅ Complété)
- [x] Moteur de simulation 47 cultures
- [x] Landing page commerciale
- [x] Déploiement GitHub Pages
- [x] PWA offline
- [x] Carte SVG interactive
- [x] Comparateur de cultures
- [x] Visite guidée

### Phase 2 — Monétisation (🔄 En cours)
- [ ] Authentification Supabase (infrastructure prête)
- [ ] Plans Free / Pro / Enterprise
- [ ] Intégration paiement (Stripe + CMI)
- [ ] Dashboard utilisateur

### Phase 3 — Scale
- [ ] Application mobile (PWA améliorée)
- [ ] API REST pour intégrateurs
- [ ] Traduction arabe / amazigh
- [ ] Partenariats ONCA / ORMVA / FDA

## 🏆 Compétition

SEVE AgTech est candidat au **Prix Maroc pour la Jeunesse** — catégorie Innovation & Entrepreneuriat.

## 👨‍💻 Auteur

**EL BOUZARKI Mohamed** (DAVINCI)
- 🎓 Technicien Spécialisé en Gestion des Entreprises Agricoles
- 🏫 IPSM Mohammedia — Promotion 2025-2026
- 📧 Contact via [GitHub](https://github.com/simobouzarki)

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE) — libre d'utilisation, modification et distribution.

---

<p align="center">
  <strong>🌱 SEVE AgTech — L'agriculture marocaine mérite des outils à la hauteur de ses ambitions</strong>
</p>
