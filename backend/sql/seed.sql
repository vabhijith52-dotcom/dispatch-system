-- Login is now DB-backed (see app/routers/auth_router.py) — add, remove,
-- or rename accounts by editing this table directly, no code/.env change
-- needed. Generate a new hash with:
--   python3 -c "from passlib.context import CryptContext; print(CryptContext(schemes=['bcrypt']).hash('yourpassword'))"
-- (requires bcrypt==4.0.1 pinned in requirements.txt — newer bcrypt
-- breaks passlib's 1.7.4 backend detection).
-- This hash is a verified, working bcrypt("admin123"):
INSERT INTO users (username, password_hash)
VALUES ('admin', '$2b$12$wjnSVleOSFcs62IlGU31r.5ek3ILAvf.FI6GmSfoGa.nLmi56vDWi')
ON CONFLICT (username) DO NOTHING;

-- Sample truck so the dashboard isn't empty on first run.
-- Starts at status='waiting', loaded_count=0, plate_number/loading_started_at
-- NULL — everything else (loading, count, start time) is filled in live by
-- the detection pipeline as it actually happens, not pre-seeded.
INSERT INTO trucks (truck_code, expected_count, loaded_count, status)
VALUES ('TRUCK-01', 50, 0, 'waiting')
ON CONFLICT (truck_code) DO NOTHING;
