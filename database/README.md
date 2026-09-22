# BAMO Vision Database

**Schema version:** v1.1
**Supabase project:** [Bafokeng-Mofokeng's Project]
**Date schema was created:** 2026-09-22
**Date RLS was applied:** 2026-09-22

## Files

- `schema-v1.1.sql` — CREATE TABLE statements, view, indexes
- `rls-v1.1.sql` — Row Level Security policies

## How to rebuild

1. Open a fresh Supabase project
2. Open SQL Editor
3. Paste and run `schema-v1.1.sql`
4. Paste and run `rls-v1.1.sql`
5. Create a test user in Authentication → Users
6. Seed initial plant/corporate data (see Setup Guide v1.1 Step 6)

## Notes

- Events in `checkpoint_events` are immutable. Never delete rows.
- `current_stage` is computed via the `device_status` view, not stored.
- RLS uses `(select auth.uid())` for performance.

## Reference

See the BAMO Vision Database Setup Guide v1.1 for the complete schema explanation.
