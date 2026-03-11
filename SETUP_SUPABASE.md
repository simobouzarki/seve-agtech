# Guide de Configuration Supabase pour SEVE AgTech

## Prerequis

- Un navigateur web moderne
- Le fichier `supabase_setup.sql` (present dans ce dossier)
- Le fichier `modele_seve_v2.html`

---

## Etape 1 : Creer un compte Supabase

1. Aller sur [https://supabase.com](https://supabase.com)
2. Cliquer sur **Start your project** (ou **Sign Up**)
3. Se connecter avec GitHub ou creer un compte avec email/mot de passe
4. Confirmer l'adresse email si necessaire

## Etape 2 : Creer un nouveau projet

1. Dans le Dashboard, cliquer sur **New Project**
2. Remplir les champs :
   - **Name** : `seve-agtech`
   - **Database Password** : choisir un mot de passe fort (le noter quelque part)
   - **Region** : choisir **West EU (Ireland)** ou la region la plus proche du Maroc
3. Cliquer sur **Create new project**
4. Attendre 1-2 minutes que le projet soit provisionne

## Etape 3 : Executer le script SQL

1. Dans le menu lateral gauche, cliquer sur **SQL Editor**
2. Cliquer sur **New query**
3. Ouvrir le fichier `supabase_setup.sql` avec un editeur de texte, copier tout le contenu
4. Coller le contenu dans l'editeur SQL de Supabase
5. Cliquer sur **Run** (ou `Ctrl+Enter`)
6. Verifier que toutes les commandes s'executent sans erreur (message vert "Success")
7. Pour confirmer : aller dans **Table Editor** (menu lateral) et verifier que les tables ont ete creees

## Etape 4 : Recuperer les cles API

1. Dans le menu lateral, cliquer sur **Settings** (icone engrenage)
2. Aller dans **API** (sous la section Configuration)
3. Copier les deux valeurs suivantes :
   - **Project URL** : ressemble a `https://xxxxxxxx.supabase.co`
   - **anon public key** : une longue chaine de caracteres commencant par `eyJ...`
4. Garder ces valeurs accessibles pour l'etape suivante

## Etape 5 : Configurer l'application SEVE

1. Ouvrir `modele_seve_v2.html` dans un editeur de texte
2. Rechercher (`Ctrl+F`) la chaine : `YOUR_SUPABASE_URL`
3. Remplacer `YOUR_SUPABASE_URL` par l'URL du projet copiee a l'etape 4
4. Rechercher la chaine : `YOUR_SUPABASE_ANON_KEY`
5. Remplacer `YOUR_SUPABASE_ANON_KEY` par la cle anon copiee a l'etape 4
6. Sauvegarder le fichier

Exemple avant :
```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Exemple apres :
```js
const SUPABASE_URL = 'https://abcdefgh.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

## Etape 6 : Configurer l'authentification

1. Dans le Dashboard Supabase, aller dans **Authentication** (menu lateral)
2. Cliquer sur **Providers** (sous Configuration)
3. Verifier que **Email** est active (enable)
4. Parametres recommandes :
   - **Confirm email** : Activer (pour la securite)
   - **Secure email change** : Activer
5. Optionnel : dans **URL Configuration**, ajouter l'URL de votre site dans **Site URL** et **Redirect URLs** si vous deployez l'app en ligne

## Etape 7 : Tester l'installation

1. Ouvrir `modele_seve_v2.html` dans un navigateur
2. Chercher le bouton de connexion / creation de compte dans l'interface
3. Creer un nouveau compte avec un email et un mot de passe
4. Verifier la reception de l'email de confirmation (si active)
5. Se connecter et lancer une simulation pour confirmer que la sauvegarde fonctionne
6. Dans le Dashboard Supabase, aller dans **Table Editor** pour verifier que les donnees apparaissent

---

## Configuration du Cron Job : Reset mensuel du compteur de simulations

Cette section permet de remettre a zero le compteur de simulations chaque mois (utile pour un modele freemium ou un suivi d'utilisation).

### Activer l'extension pg_cron

1. Dans le Dashboard Supabase, aller dans **SQL Editor**
2. Executer la commande suivante :

```sql
-- Activer l'extension pg_cron (si pas deja fait)
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### Creer la fonction de reset

Executer dans le SQL Editor :

```sql
-- Fonction pour remettre a zero les compteurs mensuels
CREATE OR REPLACE FUNCTION reset_monthly_simulation_count()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE user_profiles
  SET monthly_simulation_count = 0,
      last_reset_date = NOW();

  -- Log de l'operation (optionnel)
  INSERT INTO cron_logs (job_name, executed_at, status)
  VALUES ('reset_monthly_simulation_count', NOW(), 'success');
END;
$$;
```

### Creer la table de logs (optionnel)

```sql
CREATE TABLE IF NOT EXISTS cron_logs (
  id BIGSERIAL PRIMARY KEY,
  job_name TEXT NOT NULL,
  executed_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'success'
);
```

### Planifier le cron job

Executer dans le SQL Editor :

```sql
-- Executer le 1er de chaque mois a 00:00 UTC
SELECT cron.schedule(
  'reset-monthly-simulations',   -- nom du job
  '0 0 1 * *',                   -- cron expression : 1er du mois a minuit
  $$SELECT reset_monthly_simulation_count()$$
);
```

### Verifier le cron job

```sql
-- Lister tous les cron jobs actifs
SELECT * FROM cron.job;

-- Voir l'historique d'execution
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

### Supprimer le cron job (si necessaire)

```sql
SELECT cron.unschedule('reset-monthly-simulations');
```

---

## Depannage

| Probleme | Solution |
|----------|----------|
| Erreur "Invalid API key" | Verifier que la cle anon est correctement copiee (pas d'espaces en trop) |
| Tables non visibles | Verifier l'execution du script SQL, relancer si necessaire |
| Email de confirmation non recu | Verifier les spams, ou desactiver la confirmation dans Authentication > Settings |
| Cron job ne s'execute pas | Verifier que `pg_cron` est bien active avec `SELECT * FROM pg_extension WHERE extname = 'pg_cron';` |
| Erreur CORS | Ajouter votre domaine dans Settings > API > Allowed Origins |

---

## Ressources

- Documentation Supabase : [https://supabase.com/docs](https://supabase.com/docs)
- Reference pg_cron : [https://supabase.com/docs/guides/functions/schedule](https://supabase.com/docs/guides/functions/schedule)
- Supabase JS Client : [https://supabase.com/docs/reference/javascript](https://supabase.com/docs/reference/javascript)
