-- ============================================================
-- SEVE AgTech — Schema Supabase
-- Executer dans SQL Editor de votre projet Supabase
-- ============================================================

-- 1. Table des profils utilisateurs
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  phone TEXT,
  region TEXT,               -- Region agricole de l'utilisateur
  role TEXT DEFAULT 'farmer', -- farmer, technician, cooperative, institution, student
  plan TEXT DEFAULT 'free',   -- free, pro, enterprise
  plan_started_at TIMESTAMPTZ,
  plan_expires_at TIMESTAMPTZ,
  simulations_count INT DEFAULT 0,
  simulations_limit INT DEFAULT 3,  -- Free = 3/mois, Pro = illimite (-1)
  parcelles_count INT DEFAULT 0,
  parcelles_limit INT DEFAULT 1,    -- Free = 1, Pro = illimite (-1)
  stripe_customer_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table des simulations sauvegardees
CREATE TABLE IF NOT EXISTS public.simulations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  variety TEXT,
  region TEXT NOT NULL,
  params JSONB NOT NULL,     -- Tous les parametres d'entree
  results JSONB,             -- Resultats calcules
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table des parcelles
CREATE TABLE IF NOT EXISTS public.parcelles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  species TEXT,
  variety TEXT,
  region TEXT,
  surface_ha NUMERIC(10,2),
  params JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table des paiements (historique)
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount_dh NUMERIC(10,2) NOT NULL,
  plan TEXT NOT NULL,
  period TEXT NOT NULL,       -- monthly, yearly
  status TEXT DEFAULT 'pending', -- pending, completed, failed, refunded
  payment_method TEXT,        -- stripe, cmi, cash
  stripe_payment_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Indexes pour performance
CREATE INDEX IF NOT EXISTS idx_simulations_user ON public.simulations(user_id);
CREATE INDEX IF NOT EXISTS idx_simulations_created ON public.simulations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_parcelles_user ON public.parcelles(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_plan ON public.profiles(plan);

-- 6. Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parcelles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Policies: chaque utilisateur ne voit que ses propres donnees
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own simulations" ON public.simulations
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own parcelles" ON public.parcelles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own payments" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

-- 7. Trigger: creer un profil automatiquement a l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, plan, simulations_limit, parcelles_limit)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'free',
    3,
    1
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 8. Trigger: mettre a jour updated_at automatiquement
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE OR REPLACE TRIGGER simulations_updated
  BEFORE UPDATE ON public.simulations
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE OR REPLACE TRIGGER parcelles_updated
  BEFORE UPDATE ON public.parcelles
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

-- 9. Fonction: verifier les limites du plan
CREATE OR REPLACE FUNCTION public.check_plan_limits(p_user_id UUID, p_type TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_profile public.profiles%ROWTYPE;
BEGIN
  SELECT * INTO v_profile FROM public.profiles WHERE id = p_user_id;

  IF p_type = 'simulation' THEN
    -- -1 = illimite (Pro/Enterprise)
    IF v_profile.simulations_limit = -1 THEN RETURN TRUE; END IF;
    RETURN v_profile.simulations_count < v_profile.simulations_limit;
  ELSIF p_type = 'parcelle' THEN
    IF v_profile.parcelles_limit = -1 THEN RETURN TRUE; END IF;
    RETURN v_profile.parcelles_count < v_profile.parcelles_limit;
  END IF;

  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Reset mensuel du compteur de simulations (a appeler via cron Supabase)
CREATE OR REPLACE FUNCTION public.reset_monthly_simulations()
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET simulations_count = 0
  WHERE plan = 'free';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
