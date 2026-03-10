-- ============================================
-- CYBERSHIELD BRASIL — Setup do Supabase
-- Cole este SQL no SQL Editor do Supabase
-- ============================================

-- 1. Perfis de usuário
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free','base','plus','developer')),
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  api_key TEXT UNIQUE DEFAULT gen_random_uuid()::text,
  scans_used_this_month INT DEFAULT 0,
  api_calls_used_this_month INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Histórico de scans
CREATE TABLE IF NOT EXISTS scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  scan_type TEXT DEFAULT 'url' CHECK (scan_type IN ('url','pix','domain','ad')),
  risk_score INT CHECK (risk_score BETWEEN 0 AND 100),
  risk_level TEXT CHECK (risk_level IN ('safe','suspicious','dangerous')),
  threats JSONB DEFAULT '[]',
  ai_explanation TEXT,
  virustotal_data JSONB DEFAULT '{}',
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Golpes reportados
CREATE TABLE IF NOT EXISTS scams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  url TEXT,
  category TEXT DEFAULT 'other',
  risk_level TEXT DEFAULT 'dangerous',
  reported_by UUID REFERENCES profiles(id),
  votes INT DEFAULT 0,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Chaves PIX reportadas
CREATE TABLE IF NOT EXISTS pix_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pix_key TEXT UNIQUE NOT NULL,
  pix_type TEXT,
  risk_score INT DEFAULT 0,
  report_count INT DEFAULT 1,
  last_reported TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE scams ENABLE ROW LEVEL SECURITY;
ALTER TABLE pix_reports ENABLE ROW LEVEL SECURITY;

-- 6. Políticas RLS
CREATE POLICY "profiles_self" ON profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "scans_owner_or_public" ON scans FOR SELECT USING (auth.uid() = user_id OR is_public = true);
CREATE POLICY "scans_insert_own" ON scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "scams_public_read" ON scams FOR SELECT USING (true);
CREATE POLICY "scams_auth_insert" ON scams FOR INSERT WITH CHECK (auth.uid() = reported_by);
CREATE POLICY "pix_public_read" ON pix_reports FOR SELECT USING (true);

-- 7. Trigger: criar perfil ao cadastrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name')
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
