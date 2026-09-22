-- ============================================
-- BAMO Vision Schema v1.1
-- Paste this into Supabase SQL Editor to build the database
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CORPORATES
CREATE TABLE corporates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    industry TEXT,
    esg_contact_email TEXT,
    subscription_tier TEXT DEFAULT 'pilot',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. PLANTS
CREATE TABLE plants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    owner_id UUID REFERENCES auth.users(id) NOT NULL,
    r2_status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. BATCHES
CREATE TABLE batches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    batch_reference TEXT UNIQUE NOT NULL,
    plant_id UUID REFERENCES plants(id) NOT NULL,
    corporate_id UUID REFERENCES corporates(id),
    total_devices INTEGER NOT NULL,
    status TEXT DEFAULT 'received',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. CONSUMER_SCANS
CREATE TABLE consumer_scans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    device_fingerprint TEXT,
    scan_image_url TEXT,
    ai_classification TEXT,
    ai_confidence DECIMAL(5,4),
    estimated_value_zar DECIMAL(10,2),
    routed_to_plant_id UUID REFERENCES plants(id),
    status TEXT DEFAULT 'pending',
    submitted_at TIMESTAMPTZ DEFAULT now(),
    confirmed_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    payment_amount_zar DECIMAL(10,2)
);

-- 5. DEVICES
CREATE TABLE devices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    unique_identifier TEXT UNIQUE NOT NULL,
    plant_id UUID REFERENCES plants(id) NOT NULL,
    device_type TEXT NOT NULL,
    mass_kg DECIMAL(10,3),
    intake_timestamp TIMESTAMPTZ DEFAULT now(),
    batch_id UUID REFERENCES batches(id),
    consumer_scan_id UUID REFERENCES consumer_scans(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. CHECKPOINT_EVENTS
CREATE TABLE checkpoint_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    device_id UUID REFERENCES devices(id) NOT NULL,
    checkpoint_number INTEGER NOT NULL,
    event_type TEXT NOT NULL,
    measured_mass_kg DECIMAL(10,3),
    cv_classification TEXT,
    cv_confidence DECIMAL(5,4),
    edge_device_id TEXT,
    image_url TEXT,
    material_stream TEXT,
    event_hash TEXT UNIQUE NOT NULL,
    previous_hash TEXT NOT NULL DEFAULT 'GENESIS',
    timestamp TIMESTAMPTZ DEFAULT now()
);

-- 7. VIEW: device_status
CREATE VIEW device_status AS
SELECT
    d.id,
    d.unique_identifier,
    d.plant_id,
    d.device_type,
    d.mass_kg AS intake_mass_kg,
    d.batch_id,
    d.consumer_scan_id,
    d.intake_timestamp,
    COALESCE(MAX(ce.checkpoint_number), 0) AS current_stage,
    COUNT(ce.id) AS total_events,
    MAX(ce.timestamp) AS last_event_at
FROM devices d
LEFT JOIN checkpoint_events ce ON ce.device_id = d.id
GROUP BY d.id;

-- 8. INDEXES
CREATE INDEX idx_plants_owner_id ON plants(owner_id);
CREATE INDEX idx_batches_plant_id ON batches(plant_id);
CREATE INDEX idx_batches_corporate_id ON batches(corporate_id);
CREATE INDEX idx_devices_plant_id ON devices(plant_id);
CREATE INDEX idx_devices_batch_id ON devices(batch_id);
CREATE INDEX idx_devices_consumer_scan_id ON devices(consumer_scan_id);
CREATE INDEX idx_consumer_scans_user_id ON consumer_scans(user_id);
CREATE INDEX idx_consumer_scans_routed_to_plant_id ON consumer_scans(routed_to_plant_id);
CREATE INDEX idx_checkpoint_events_device_id ON checkpoint_events(device_id);
CREATE INDEX idx_checkpoint_events_timestamp ON checkpoint_events(timestamp);
CREATE INDEX idx_checkpoint_events_previous_hash ON checkpoint_events(previous_hash);
