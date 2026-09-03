-- 1. Radars & Cameras Table
CREATE TABLE IF NOT EXISTS public.radars (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    address TEXT,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    type TEXT NOT NULL, -- 'stationary', 'mobile', 'speedTrap', 'redLight'
    speed_limit INTEGER NOT NULL DEFAULT 60,
    confirmed_count INTEGER NOT NULL DEFAULT 1,
    last_confirmed TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. User Community Hazard Reports Table
CREATE TABLE IF NOT EXISTS public.user_reports (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL, -- 'policePatrol', 'camera', 'trafficJam', 'accident', 'roadwork', 'pothole'
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    note TEXT,
    upvotes INTEGER NOT NULL DEFAULT 0,
    downvotes INTEGER NOT NULL DEFAULT 0,
    author_id TEXT NOT NULL DEFAULT 'anonymous',
    author_karma INTEGER NOT NULL DEFAULT 50,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Parking Zones Table
CREATE TABLE IF NOT EXISTS public.parking_zones (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    price_info TEXT,
    capacity INTEGER NOT NULL DEFAULT 50,
    available_spots INTEGER NOT NULL DEFAULT 20,
    points JSONB NOT NULL DEFAULT '[]'::jsonb,
    color_value BIGINT NOT NULL DEFAULT 4281519449,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.radars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_zones ENABLE ROW LEVEL SECURITY;

-- Allow Public Read Access
CREATE POLICY "Allow public read radars" ON public.radars FOR SELECT USING (true);
CREATE POLICY "Allow public read user_reports" ON public.user_reports FOR SELECT USING (true);
CREATE POLICY "Allow public read parking_zones" ON public.parking_zones FOR SELECT USING (true);

-- Allow Public Insert & Update for Community Driving Features
CREATE POLICY "Allow public insert user_reports" ON public.user_reports FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update user_reports" ON public.user_reports FOR UPDATE USING (true);

CREATE POLICY "Allow public insert radars" ON public.radars FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update radars" ON public.radars FOR UPDATE USING (true);

CREATE POLICY "Allow public insert parking_zones" ON public.parking_zones FOR INSERT WITH CHECK (true);

-- Seed Initial Samarkand Radars & Cameras
INSERT INTO public.radars (id, title, address, lat, lng, type, speed_limit, confirmed_count)
VALUES
    ('sam-radar-001', 'Registon Autocon Kamera', 'Registon maydoni / Registon ko''chasi', 39.654800, 66.976000, 'stationary', 60, 520),
    ('sam-radar-002', 'Mirzo Ulug''bek Tezlik Radari', 'Mirzo Ulug''bek shoh ko''chasi', 39.658200, 66.962000, 'stationary', 70, 410),
    ('sam-radar-003', 'Bulvar Kamerasi', 'Universitet xiyoboni (Bulvar)', 39.651000, 66.960000, 'stationary', 60, 380),
    ('sam-radar-004', 'Gagarin Ko''chma Radari', 'Gagarin ko''chasi', 39.663000, 66.945000, 'mobile', 70, 295),
    ('sam-radar-005', 'Dahbed Chorraha Kamerasi', 'Dahbed ko''chasi', 39.672000, 66.971000, 'stationary', 60, 440),
    ('sam-radar-006', 'Shohi Zinda Radari', 'Shohi Zinda ko''chasi', 39.664000, 66.985000, 'stationary', 60, 330),
    ('sam-radar-007', 'Siyob Svetofor Kamerasi', 'Ibn Sino ko''chasi (Siyob bozori)', 39.662000, 66.979000, 'redLight', 60, 610),
    ('sam-radar-008', 'Vokzal Autocon Radari', 'Rudakiy ko''chasi (Temir yo''l vokzali)', 39.684000, 66.929000, 'stationary', 70, 480)
ON CONFLICT (id) DO NOTHING;

-- Seed Initial Samarkand Parking Zone
INSERT INTO public.parking_zones (id, name, is_paid, price_info, capacity, available_spots, points, color_value)
VALUES (
    'park_samarqand_registan_0',
    'Registon Maydoni Parkovkasi',
    false,
    'Bepul',
    120,
    45,
    '[{"latitude": 39.654000, "longitude": 66.974000}, {"latitude": 39.655200, "longitude": 66.974000}, {"latitude": 39.655200, "longitude": 66.975500}, {"latitude": 39.654000, "longitude": 66.975500}]'::jsonb,
    4281632089
)
ON CONFLICT (id) DO NOTHING;
