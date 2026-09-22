-- ============================================
-- BAMO Vision RLS Policies v1.1
-- Run after schema-v1.1.sql
-- ============================================

-- Enable RLS on all tables (deny-by-default)
ALTER TABLE corporates ENABLE ROW LEVEL SECURITY;
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumer_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkpoint_events ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PLANTS: owners manage only their own plants
-- ============================================
CREATE POLICY "plants_owner_all" ON plants
    FOR ALL
    TO authenticated
    USING ((select auth.uid()) = owner_id)
    WITH CHECK ((select auth.uid()) = owner_id);

-- ============================================
-- DEVICES: plant owners see devices at their plants
-- ============================================
CREATE POLICY "devices_via_plant" ON devices
    FOR ALL
    TO authenticated
    USING (plant_id IN (
        SELECT id FROM plants WHERE owner_id = (select auth.uid())
    ))
    WITH CHECK (plant_id IN (
        SELECT id FROM plants WHERE owner_id = (select auth.uid())
    ));

-- ============================================
-- CHECKPOINT_EVENTS: plant owners see events on their devices
-- ============================================
CREATE POLICY "checkpoint_events_via_device" ON checkpoint_events
    FOR ALL
    TO authenticated
    USING (device_id IN (
        SELECT d.id FROM devices d
        JOIN plants p ON d.plant_id = p.id
        WHERE p.owner_id = (select auth.uid())
    ));

-- ============================================
-- CONSUMER_SCANS: users see their own scans
-- ============================================
CREATE POLICY "consumer_scans_own" ON consumer_scans
    FOR ALL
    TO authenticated
    USING (user_id = (select auth.uid()))
    WITH CHECK (user_id = (select auth.uid()));

-- ============================================
-- BATCHES: plant owners see their plant's batches
-- ============================================
CREATE POLICY "batches_via_plant" ON batches
    FOR ALL
    TO authenticated
    USING (plant_id IN (
        SELECT id FROM plants WHERE owner_id = (select auth.uid())
    ))
    WITH CHECK (plant_id IN (
        SELECT id FROM plants WHERE owner_id = (select auth.uid())
    ));

-- ============================================
-- CORPORATES: for prototype, authenticated users can read
-- ============================================
CREATE POLICY "corporates_authenticated_read" ON corporates
    FOR SELECT
    TO authenticated
    USING (true);
