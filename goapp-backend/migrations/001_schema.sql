-- GoApp Database Schema
-- Requires: PostgreSQL 16 + PostGIS 3

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── users ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone         VARCHAR(20) UNIQUE NOT NULL,
  name          VARCHAR(100),
  email         VARCHAR(150),
  gender        VARCHAR(10),
  emergency_contact VARCHAR(20),
  role          VARCHAR(10) NOT NULL DEFAULT 'RIDER' CHECK (role IN ('RIDER','DRIVER','ADMIN')),
  profile_photo VARCHAR(500),
  fcm_token     VARCHAR(500),
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── drivers (captains) ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS drivers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  onboarding_status VARCHAR(25) DEFAULT 'PENDING'
                    CHECK (onboarding_status IN ('PENDING','DOCUMENTS_SUBMITTED','VERIFIED','REJECTED')),
  is_online         BOOLEAN DEFAULT FALSE,
  current_location  GEOGRAPHY(POINT, 4326),
  city              VARCHAR(100),
  vehicle_type      VARCHAR(10) CHECK (vehicle_type IN ('bike','auto','car')),
  rating_avg        NUMERIC(3,2) DEFAULT 5.00,
  total_trips       INTEGER DEFAULT 0,
  wallet_balance    NUMERIC(10,2) DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_drivers_location ON drivers USING GIST (current_location);
CREATE INDEX IF NOT EXISTS idx_drivers_online ON drivers(is_online, vehicle_type);

-- ─── vehicles ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vehicles (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id    UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  make         VARCHAR(50),
  model        VARCHAR(50),
  plate_number VARCHAR(20) UNIQUE NOT NULL,
  vehicle_type VARCHAR(10) CHECK (vehicle_type IN ('bike','auto','car')),
  color        VARCHAR(30),
  year         SMALLINT,
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ─── rides ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rides (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id         UUID NOT NULL REFERENCES users(id),
  driver_id        UUID REFERENCES drivers(id),
  vehicle_type     VARCHAR(10) NOT NULL CHECK (vehicle_type IN ('bike','auto','car')),

  pickup_address   TEXT,
  pickup_lat       DOUBLE PRECISION NOT NULL,
  pickup_lng       DOUBLE PRECISION NOT NULL,

  drop_address     TEXT,
  drop_lat         DOUBLE PRECISION NOT NULL,
  drop_lng         DOUBLE PRECISION NOT NULL,

  encoded_polyline TEXT,
  distance_meters  INTEGER DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0,

  status           VARCHAR(30) NOT NULL DEFAULT 'SEARCHING_FOR_DRIVER'
                   CHECK (status IN (
                     'SEARCHING_FOR_DRIVER',
                     'DRIVER_ACCEPTED',
                     'DRIVER_ARRIVING',
                     'DRIVER_ARRIVED',
                     'RIDE_STARTED',
                     'REACHED_DROP_LOCATION',
                     'RIDE_COMPLETED',
                     'CANCELLED'
                   )),

  otp              CHAR(4),
  estimated_fare   NUMERIC(8,2) DEFAULT 0,
  final_fare       NUMERIC(8,2),

  cancelled_by     VARCHAR(10) CHECK (cancelled_by IN ('RIDER','DRIVER','SYSTEM')),
  cancel_reason    TEXT,

  accepted_at      TIMESTAMPTZ,
  arrived_at       TIMESTAMPTZ,
  started_at       TIMESTAMPTZ,
  completed_at     TIMESTAMPTZ,
  cancelled_at     TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rides_status   ON rides(status);
CREATE INDEX IF NOT EXISTS idx_rides_rider    ON rides(rider_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver   ON rides(driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_created  ON rides(created_at DESC);

-- ─── payments ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id          UUID UNIQUE NOT NULL REFERENCES rides(id),
  rider_id         UUID NOT NULL REFERENCES users(id),
  driver_id        UUID REFERENCES drivers(id),
  method           VARCHAR(10) NOT NULL DEFAULT 'cash' CHECK (method IN ('cash','upi','card','wallet')),
  trip_fare        NUMERIC(8,2) NOT NULL DEFAULT 0,
  tips             NUMERIC(6,2) DEFAULT 0,
  discount_amount  NUMERIC(6,2) DEFAULT 0,
  total_charged    NUMERIC(8,2) NOT NULL DEFAULT 0,
  total_earnings   NUMERIC(8,2) NOT NULL DEFAULT 0,
  payment_link     VARCHAR(500),
  transaction_id   VARCHAR(100),
  status           VARCHAR(20) DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','COMPLETED','FAILED','REFUNDED')),
  paid_at          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─── ratings ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ratings (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id     UUID NOT NULL REFERENCES rides(id),
  rater_id    UUID NOT NULL REFERENCES users(id),
  ratee_id    UUID NOT NULL REFERENCES users(id),
  score       SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(ride_id, rater_id)
);

-- ─── location_snapshots ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS location_snapshots (
  id          BIGSERIAL PRIMARY KEY,
  ride_id     UUID NOT NULL REFERENCES rides(id),
  driver_id   UUID NOT NULL,
  lat         DOUBLE PRECISION NOT NULL,
  lng         DOUBLE PRECISION NOT NULL,
  heading     SMALLINT,
  speed_kmh   NUMERIC(5,1),
  captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_loc_ride_time ON location_snapshots(ride_id, captured_at DESC);

-- ─── documents ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS documents (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  doc_type      VARCHAR(30) NOT NULL
                CHECK (doc_type IN ('profile_image','driving_license','vehicle_rc','aadhaar','pan')),
  s3_key        VARCHAR(500) NOT NULL,
  status        VARCHAR(20) DEFAULT 'PENDING'
                CHECK (status IN ('PENDING','APPROVED','REJECTED')),
  reject_reason TEXT,
  uploaded_at   TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at   TIMESTAMPTZ
);

-- ─── wallet_transactions ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id),
  type        VARCHAR(20) NOT NULL CHECK (type IN ('credit','debit')),
  amount      NUMERIC(10,2) NOT NULL,
  description TEXT,
  reference   VARCHAR(100),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_user ON wallet_transactions(user_id, created_at DESC);

-- ─── audit_logs ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_logs (
  id         BIGSERIAL PRIMARY KEY,
  actor_id   UUID,
  actor_role VARCHAR(10),
  action     VARCHAR(100) NOT NULL,
  entity     VARCHAR(50),
  entity_id  UUID,
  old_value  JSONB,
  new_value  JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Seed: services (static, for /services endpoint) ─────────────────────────
CREATE TABLE IF NOT EXISTS services (
  id              VARCHAR(20) PRIMARY KEY,
  name            VARCHAR(50) NOT NULL,
  icon_key        VARCHAR(20) NOT NULL,
  description     TEXT,
  booking_service VARCHAR(20) NOT NULL,
  featured        BOOLEAN DEFAULT FALSE,
  is_active       BOOLEAN DEFAULT TRUE,
  sort_order      SMALLINT DEFAULT 0
);

INSERT INTO services (id, name, icon_key, description, booking_service, featured, sort_order)
VALUES
  ('bike', 'Bike', 'bike', 'Quick solo rides', 'bike', TRUE, 1),
  ('auto', 'Auto', 'auto', 'Comfortable 3-wheeler rides', 'auto', TRUE, 2),
  ('car',  'Car',  'car',  'Premium 4-wheeler rides',     'car',  FALSE, 3)
ON CONFLICT (id) DO NOTHING;
