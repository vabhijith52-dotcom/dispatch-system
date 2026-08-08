-- Run once against the dispatch_db database.
-- SQLAlchemy will also auto-create these tables on backend startup,
-- but the trigger + notify logic below MUST be run manually since
-- SQLAlchemy does not create triggers.

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS trucks (
    id SERIAL PRIMARY KEY,
    truck_code VARCHAR UNIQUE NOT NULL,
    plate_number VARCHAR,
    expected_count INTEGER NOT NULL DEFAULT 0,
    loaded_count INTEGER NOT NULL DEFAULT 0,
    status VARCHAR NOT NULL DEFAULT 'waiting',
    loading_started_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- for databases created before this column existed
ALTER TABLE trucks ADD COLUMN IF NOT EXISTS loading_started_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS count_events (
    id SERIAL PRIMARY KEY,
    truck_id INTEGER NOT NULL REFERENCES trucks(id) ON DELETE CASCADE,
    event_type VARCHAR NOT NULL DEFAULT 'carton_added',
    track_id INTEGER,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- LIVE SYNC: this is the part that makes a MANUAL edit made
-- directly in the database (pgAdmin / DBeaver / psql) show up
-- in the UI instantly, the same way a detection-driven update does.
-- The backend's db_listener.py subscribes to this channel.
-- ============================================================

CREATE OR REPLACE FUNCTION notify_dispatch_change() RETURNS TRIGGER AS $$
DECLARE
    payload JSON;
BEGIN
    payload := json_build_object(
        'table', TG_TABLE_NAME,
        'operation', TG_OP,
        'row', row_to_json(COALESCE(NEW, OLD))
    );
    PERFORM pg_notify('dispatch_changes', payload::text);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_trucks_notify ON trucks;
CREATE TRIGGER trg_trucks_notify
AFTER INSERT OR UPDATE OR DELETE ON trucks
FOR EACH ROW EXECUTE FUNCTION notify_dispatch_change();

DROP TRIGGER IF EXISTS trg_count_events_notify ON count_events;
CREATE TRIGGER trg_count_events_notify
AFTER INSERT ON count_events
FOR EACH ROW EXECUTE FUNCTION notify_dispatch_change();

-- Keep updated_at fresh on manual edits too
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_trucks_updated_at ON trucks;
CREATE TRIGGER trg_trucks_updated_at
BEFORE UPDATE ON trucks
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
