# GoApp — Real-Time Ride-Hailing Backend Blueprint

> **Aligned to**: `goapp-main` (Rider Flutter app) + `Go-App-Driver-main` (Driver/Captain Flutter app)
> **Domain reference**: Existing `BookingProgressState`, `TripSessionStage`, `BookingService`, `FareQuote`, `DriverInfo`, and WebSocket `DriverTrackingSocketDataSource` contracts extracted from both codebases.

---

## Table of Contents

1. [Architecture Decision](#1-architecture-decision)
2. [Tech Stack & Environment](#2-tech-stack--environment)
3. [Data Model & Schemas](#3-data-model--schemas)
4. [API Design & Real-Time Flows](#4-api-design--real-time-flows)
5. [Real-Time Concerns](#5-real-time-concerns)
6. [Reliability & Scalability](#6-reliability--scalability)
7. [Security & Compliance](#7-security--compliance)
8. [Observability & Operations](#8-observability--operations)
9. [MVP Phased Plan](#9-mvp-phased-plan)
10. [Code Samples](#10-code-samples)

---

## 1. Architecture Decision

### Decision: Modular Monolith → Selective Microservices

For a startup / early-stage product with one rider app and one driver app, a **modular monolith** is the right first choice. It is fast to build, easy to debug, and can be split service-by-service once scaling pressure demands it.

```
┌─────────────────────────────────────────────────────────────┐
│                     API Gateway (Nginx / Kong)               │
│         Rate limiting · JWT validation · TLS termination     │
└──────────────────┬──────────────────────┬───────────────────┘
                   │                      │
         ┌─────────▼──────┐     ┌─────────▼──────┐
         │  Rider REST API │     │ Driver REST API │
         │  (Node/Express) │     │ (Node/Express)  │
         └─────────┬───────┘     └────────┬────────┘
                   │                      │
         ┌─────────▼──────────────────────▼────────┐
         │           GoApp Core Service             │
         │  auth · ride · location · payment ·      │
         │  notification · matching · analytics     │
         └───────────┬───────────────┬──────────────┘
                     │               │
           ┌─────────▼───┐   ┌───────▼─────┐
           │  PostgreSQL  │   │    Redis     │
           │  + PostGIS   │   │  (cache +    │
           │              │   │   pub/sub)   │
           └─────────────┘   └─────────────┘
```

### Messaging: WebSocket over Socket.IO

Both apps already have `DriverTrackingSocketDataSource` (rider) and `TripBackgroundService` (driver). The backend uses **Socket.IO** rooms:

- Room `ride:{rideId}` — all lifecycle events for both rider and driver
- Room `driver:{driverId}` — location broadcast from driver → server → rider
- Room `available-orders:{city}:{vehicleType}` — new ride broadcasts to nearby drivers

### Event-Driven Design

Internal events use Redis Pub/Sub for decoupling the matching engine, notifications, and analytics from the HTTP layer.

```
HTTP POST /rides/book
   → RideService.createRide()
   → redis.publish("ride:created", payload)
      ├── MatchingWorker subscribes → finds drivers → emits to Socket.IO
      ├── NotificationWorker subscribes → sends FCM push
      └── AnalyticsWorker subscribes → writes to time-series store
```

---

## 2. Tech Stack & Environment

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Language | **Node.js 20 (TypeScript)** | Excellent async I/O for WebSockets; large ecosystem |
| Framework | **Express 5 + Socket.IO 4** | REST + real-time in one process |
| Primary DB | **PostgreSQL 16 + PostGIS 3** | Geospatial queries (`ST_DWithin`, `ST_Distance`); ACID rides/payments |
| Cache + PubSub | **Redis 7 (Cluster)** | Driver location cache; socket pub/sub; session tokens |
| Queue | **BullMQ (Redis-backed)** | Background jobs: document verification, invoice emails, surge calc |
| File storage | **AWS S3 / Cloudflare R2** | Driver documents (Aadhaar, PAN, RC, profile photo) |
| Maps | **Google Routes API + Places API** | Already in both apps (same key pattern) |
| SMS / OTP | **Twilio / MSG91** | OTP for both rider and driver auth |
| Push | **Firebase Cloud Messaging (FCM)** | Both apps already have `fcm_service.dart` |
| Auth | **JWT (access) + Refresh token (Redis)** | Stateless access; revocable refresh |
| Hosting (MVP) | **Railway / Render** | Zero-ops, Postgres + Redis add-ons; upgrade to GCP/AWS later |
| Hosting (Scale) | **GCP GKE or AWS ECS** | Horizontal pod autoscaling |
| CDN | **Cloudflare** | TLS, DDoS, caching static assets |

### Authentication & Role Model

```
Roles: RIDER | DRIVER (Captain) | ADMIN

JWT payload:
{
  "sub": "user_uuid",
  "role": "DRIVER",
  "sessionId": "redis_key_for_refresh",
  "iat": 1700000000,
  "exp": 1700003600   // 1-hour access token
}

Refresh token: 30 days, stored in Redis as:
  refresh:{sessionId} → { userId, role, deviceId }
```

---

## 3. Data Model & Schemas

### Entity Relationship Overview

```
User ──< Rider           (1:1)
User ──< Driver          (1:1)
Driver ──< Vehicle       (1:many, one active at a time)
Driver ──< Document      (1:many)
Rider ──< Ride           (1:many, as requester)
Driver ──< Ride          (1:many, as fulfiller)
Ride ──< Location        (1:many, time-series snapshots)
Ride ──< Payment         (1:1)
Ride ──< Rating          (1:2, rider rates driver + driver rates rider)
```

### Core Table Schemas (PostgreSQL + PostGIS)

```sql
-- ─── users ───────────────────────────────────────────────────
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone         VARCHAR(15) UNIQUE NOT NULL,
  name          VARCHAR(100),
  email         VARCHAR(150),
  role          VARCHAR(10) NOT NULL CHECK (role IN ('RIDER','DRIVER','ADMIN')),
  profile_photo VARCHAR(500),
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── drivers (captains) ──────────────────────────────────────
CREATE TABLE drivers (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  onboarding_status VARCHAR(20) DEFAULT 'PENDING'
                    CHECK (onboarding_status IN
                      ('PENDING','DOCUMENTS_SUBMITTED','VERIFIED','REJECTED')),
  is_online         BOOLEAN DEFAULT FALSE,
  current_location  GEOGRAPHY(POINT, 4326),   -- PostGIS
  city              VARCHAR(100),
  vehicle_type      VARCHAR(10) CHECK (vehicle_type IN ('bike','auto','car')),
  rating_avg        NUMERIC(3,2) DEFAULT 5.00,
  total_trips       INTEGER DEFAULT 0,
  wallet_balance    NUMERIC(10,2) DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index on driver location (critical for matchmaking)
CREATE INDEX idx_drivers_location
  ON drivers USING GIST (current_location);

-- ─── vehicles ─────────────────────────────────────────────────
CREATE TABLE vehicles (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id    UUID REFERENCES drivers(id) ON DELETE CASCADE,
  make         VARCHAR(50),   -- e.g. "Honda"
  model        VARCHAR(50),   -- e.g. "Activa"
  plate_number VARCHAR(20) UNIQUE NOT NULL,
  vehicle_type VARCHAR(10) CHECK (vehicle_type IN ('bike','auto','car')),
  color        VARCHAR(30),
  year         SMALLINT,
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ─── rides ────────────────────────────────────────────────────
-- Mirrors BookingProgressState enum in the rider app exactly
CREATE TABLE rides (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id         UUID REFERENCES users(id),
  driver_id        UUID REFERENCES drivers(id),
  vehicle_type     VARCHAR(10) NOT NULL CHECK (vehicle_type IN ('bike','auto','car')),

  -- Pickup
  pickup_address   TEXT,
  pickup_lat       DOUBLE PRECISION NOT NULL,
  pickup_lng       DOUBLE PRECISION NOT NULL,
  pickup_location  GEOGRAPHY(POINT, 4326) GENERATED ALWAYS AS
                     (ST_SetSRID(ST_MakePoint(pickup_lng, pickup_lat), 4326)::geography)
                   STORED,

  -- Drop
  drop_address     TEXT,
  drop_lat         DOUBLE PRECISION NOT NULL,
  drop_lng         DOUBLE PRECISION NOT NULL,
  drop_location    GEOGRAPHY(POINT, 4326) GENERATED ALWAYS AS
                     (ST_SetSRID(ST_MakePoint(drop_lng, drop_lat), 4326)::geography)
                   STORED,

  -- Route (from Google Routes API)
  encoded_polyline TEXT,
  distance_meters  INTEGER,
  duration_seconds INTEGER,

  -- State machine — matches BookingProgressState in rider app
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

  -- OTP for ride start verification
  otp              CHAR(4),

  -- Fare
  estimated_fare   NUMERIC(8,2),
  final_fare       NUMERIC(8,2),

  -- Cancellation
  cancelled_by     VARCHAR(10) CHECK (cancelled_by IN ('RIDER','DRIVER','SYSTEM')),
  cancel_reason    TEXT,

  -- Timing
  accepted_at      TIMESTAMPTZ,
  arrived_at       TIMESTAMPTZ,
  started_at       TIMESTAMPTZ,
  completed_at     TIMESTAMPTZ,
  cancelled_at     TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_rides_rider ON rides(rider_id);
CREATE INDEX idx_rides_driver ON rides(driver_id);
CREATE INDEX idx_rides_created ON rides(created_at DESC);

-- ─── payments ─────────────────────────────────────────────────
CREATE TABLE payments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id          UUID UNIQUE REFERENCES rides(id),
  rider_id         UUID REFERENCES users(id),
  driver_id        UUID REFERENCES drivers(id),
  method           VARCHAR(10) NOT NULL CHECK (method IN ('cash','online')),
  trip_fare        NUMERIC(8,2) NOT NULL,
  tips             NUMERIC(6,2) DEFAULT 0,
  discount_percent NUMERIC(5,2) DEFAULT 0,
  discount_amount  NUMERIC(6,2) DEFAULT 0,
  total_earnings   NUMERIC(8,2) NOT NULL,   -- driver's net
  total_charged    NUMERIC(8,2) NOT NULL,   -- rider's total
  payment_link     VARCHAR(500),            -- UPI QR link
  status           VARCHAR(20) DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','COMPLETED','FAILED','REFUNDED')),
  paid_at          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─── ratings ──────────────────────────────────────────────────
CREATE TABLE ratings (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id     UUID REFERENCES rides(id),
  rater_id    UUID REFERENCES users(id),
  ratee_id    UUID REFERENCES users(id),
  score       SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── location_snapshots (time-series) ─────────────────────────
-- Written every 3-5 seconds during active ride
-- Consider TimescaleDB hypertable for scale
CREATE TABLE location_snapshots (
  id         BIGSERIAL,
  ride_id    UUID NOT NULL REFERENCES rides(id),
  driver_id  UUID NOT NULL,
  lat        DOUBLE PRECISION NOT NULL,
  lng        DOUBLE PRECISION NOT NULL,
  heading    SMALLINT,        -- 0-359 degrees
  speed_kmh  NUMERIC(5,1),
  captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_loc_ride_time ON location_snapshots(ride_id, captured_at DESC);

-- ─── documents ────────────────────────────────────────────────
CREATE TABLE documents (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id   UUID REFERENCES drivers(id) ON DELETE CASCADE,
  doc_type    VARCHAR(30) NOT NULL
              CHECK (doc_type IN (
                'profile_image','driving_license','vehicle_rc',
                'aadhaar','pan'
              )),
  s3_key      VARCHAR(500) NOT NULL,
  status      VARCHAR(20) DEFAULT 'PENDING'
              CHECK (status IN ('PENDING','APPROVED','REJECTED')),
  reject_reason TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ
);
```

---

## 4. API Design & Real-Time Flows

### 4.1 REST Endpoints

All routes follow the versioned pattern the driver app already uses: `/api/v1/...`

#### Auth (shared — rider & driver)

```
POST   /auth/request-otp          { phone, role: "RIDER"|"DRIVER" }
POST   /auth/resend-otp           { phone }
POST   /auth/otp/verify           { phone, otp, deviceId }
POST   /auth/refresh              { refreshToken }
POST   /auth/logout               (JWT required)
```

#### Rider

```
POST   /profile/create            { name, email }
GET    /profile/me

GET    /rides/fare-quote          ?pickupLat&pickupLng&dropLat&dropLng
POST   /rides/book                { vehicleType, pickup, drop, encodedPolyline, ... }
GET    /rides/:rideId             
POST   /rides/:rideId/cancel      { reason }
GET    /rides/active              (current in-progress ride)
GET    /rides/history             ?page&limit

POST   /rides/:rideId/rating      { score, comment }
GET    /activity                  (alias for rides/history + wallet)
GET    /wallet/balance
POST   /wallet/topup              { amount, method }
```

#### Driver (Captain)

```
-- Onboarding (matches existing driver app endpoints)
POST   /api/v1/onboarding/profile
GET    /api/v1/onboarding/progress
POST   /api/v1/onboarding/submit

POST   /api/v1/documents/profile-image
POST   /api/v1/documents/driving-license
POST   /api/v1/documents/vehicle-rc
POST   /api/v1/documents/aadhaar
POST   /api/v1/documents/pan
POST   /api/v1/documents/submit-all
GET    /api/v1/documents/status
GET    /api/v1/documents

POST   /api/v1/bank/details
GET    /api/v1/vehicles/types
POST   /api/v1/vehicles/select

GET    /v1/captain/profile

-- Operations
POST   /api/v1/driver/go-online   { lat, lng }
POST   /api/v1/driver/go-offline
POST   /api/v1/driver/location    { lat, lng, heading, speedKmh }  (polling fallback)

POST   /api/v1/rides/:rideId/accept
POST   /api/v1/rides/:rideId/decline
POST   /api/v1/rides/:rideId/arrived     (captain at pickup)
POST   /api/v1/rides/:rideId/start       { otp }  (verify OTP → RIDE_STARTED)
POST   /api/v1/rides/:rideId/complete    { finalLat, finalLng }
POST   /api/v1/rides/:rideId/cancel      { reason }

GET    /api/v1/earnings/summary
GET    /api/v1/earnings/history
POST   /api/v1/rides/:rideId/payment-received  { method }

POST   /api/v1/rides/:rideId/rating     { score, comment }
```

#### Admin

```
GET    /admin/drivers             ?status&city&page&limit
PATCH  /admin/drivers/:id/verify
PATCH  /admin/documents/:id/approve
PATCH  /admin/documents/:id/reject  { reason }
GET    /admin/rides               ?status&date
GET    /admin/analytics/dashboard
POST   /admin/surge/config        { cityId, multiplier }
```

---

### 4.2 Ride Lifecycle — Full State Machine

```
RIDER                          SERVER                        DRIVER
  │                               │                              │
  │──POST /rides/book────────────►│                              │
  │                               │ status: SEARCHING_FOR_DRIVER │
  │                               │ pub "ride:created"           │
  │                               │──── Socket emit ────────────►│ room: available-orders
  │                               │     (15 sec window)          │
  │◄── WS: searching ─────────────│                              │
  │                               │◄── POST /rides/:id/accept ───│
  │                               │ status: DRIVER_ACCEPTED       │
  │◄── WS: driverAccepted ────────│──── WS: rideAssigned ───────►│
  │                               │                              │
  │  (driver streams location)    │◄── WS: driver:location ──────│ every 3s
  │◄── WS: driverLocation ────────│                              │
  │                               │◄── POST /arrived ────────────│
  │                               │ status: DRIVER_ARRIVED        │
  │◄── WS: driverArrived ─────────│──── WS: arrivedAtPickup ────►│
  │                               │                              │
  │ (rider shows OTP to driver)   │◄── POST /start { otp } ──────│
  │                               │ validates OTP                 │
  │                               │ status: RIDE_STARTED          │
  │◄── WS: rideStarted ───────────│──── WS: tripStarted ────────►│
  │                               │                              │
  │  (location stream continues)  │◄── WS: driver:location ──────│
  │◄── WS: driverLocation ────────│                              │
  │                               │◄── POST /complete ───────────│
  │                               │ status: RIDE_COMPLETED        │
  │◄── WS: rideCompleted ─────────│──── WS: tripCompleted ──────►│
  │                               │  (sends TripPaymentDetails)  │
  │──POST /rating ───────────────►│◄── POST /rating ─────────────│
```

---

### 4.3 WebSocket Event Catalogue

#### Server → Rider

| Event | Payload |
|-------|---------|
| `ride:searching` | `{ rideId, estimatedWaitSec }` |
| `ride:driverAccepted` | `{ rideId, driver: DriverInfo, etaMin, distanceKm }` |
| `ride:driverLocation` | `{ rideId, lat, lng, heading, etaMin }` |
| `ride:driverArrived` | `{ rideId }` |
| `ride:started` | `{ rideId, startedAt }` |
| `ride:completed` | `{ rideId, fare, duration, distance }` |
| `ride:cancelled` | `{ rideId, cancelledBy, reason }` |
| `ride:noDriverFound` | `{ rideId }` (after timeout) |

#### Server → Driver

| Event | Payload |
|-------|---------|
| `order:available` | `{ rideId, pickup, drop, distanceKm, estimatedFare, vehicleType, expiresInMs: 15000 }` |
| `order:assigned` | `{ rideId, rider: RiderInfo, otp, pickup, drop, route }` |
| `trip:otpVerified` | `{ rideId }` |
| `trip:completed` | `{ rideId, payment: TripPaymentDetails }` |
| `trip:cancelled` | `{ rideId, cancelledBy }` |

#### Driver → Server (location stream)

```json
{ "event": "driver:location", "data": { "lat": 12.9716, "lng": 77.5946, "heading": 245, "speedKmh": 32.5 } }
```

---

### 4.4 Webhook & Analytics Events

Published to Redis and consumed by an analytics worker that writes to a time-series store (TimescaleDB or ClickHouse):

```
ride.created       ride.driver_assigned   ride.started
ride.completed     ride.cancelled         driver.went_online
driver.went_offline  payment.completed    rating.submitted
```

Third-party webhook POST (configurable URL, HMAC-signed):

```json
{
  "event": "ride.completed",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": { "rideId": "...", "fare": 120.00, "vehicleType": "auto" },
  "signature": "sha256=abc123..."
}
```

---

## 5. Real-Time Concerns

### Geospatial Matchmaking

```sql
-- Find online drivers within 5 km of pickup, matching vehicle type
-- Ordered by distance, limited to top 10 candidates
SELECT
  d.id,
  d.user_id,
  u.name,
  ST_Distance(d.current_location, ST_MakePoint($1, $2)::geography) AS distance_m
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE
  d.is_online = TRUE
  AND d.vehicle_type = $3
  AND d.onboarding_status = 'VERIFIED'
  AND NOT EXISTS (
    SELECT 1 FROM rides r
    WHERE r.driver_id = d.id
      AND r.status NOT IN ('RIDE_COMPLETED', 'CANCELLED')
  )
  AND ST_DWithin(
    d.current_location,
    ST_MakePoint($1, $2)::geography,
    5000   -- 5 km radius
  )
ORDER BY distance_m ASC
LIMIT 10;
```

### Driver Location Caching

Drivers stream location every 3 seconds. Hitting Postgres for every update is wasteful. Use Redis:

```
SET driver:location:{driverId}  "{lat,lng,heading,speed,ts}"  EX 30
```

The PostGIS column on `drivers` is updated every 15 seconds via a background flush job, not on every WebSocket message. This keeps Postgres write load low.

### Location Precision & Streaming Intervals

| Phase | Interval | Precision |
|-------|----------|-----------|
| Driver online (idle) | 10 s | ~50 m (battery-saver) |
| Driver approaching pickup | 3 s | ~5 m (GPS full accuracy) |
| During ride | 3 s | ~5 m |
| Driver offline / app background | 30 s (FCM silent push trigger) | — |

### Fault Tolerance: Booking Resume

Both apps persist in-progress booking state locally (`BookingProgressStorage` in rider, `TripSessionStore` in driver). The backend mirrors this with an `active_session` Redis key:

```
SET ride:session:{rideId}  "{fullRideState}"  EX 3600
```

On reconnect, the client calls `GET /rides/active` and the server restores state from Redis (falling back to Postgres).

---

## 6. Reliability & Scalability

### Horizontal Scaling

Socket.IO uses **Redis Adapter** so multiple API server instances share the same rooms:

```typescript
import { createAdapter } from '@socket.io/redis-adapter';
const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();
io.adapter(createAdapter(pubClient, subClient));
```

Sticky sessions are NOT required with the Redis adapter.

### Driver Matching: Expanding Search Radius

If no driver is found at 3 km within 30 s → expand to 5 km. If no driver at 5 km within 60 s → emit `ride:noDriverFound`.

```typescript
async function matchWithBackoff(rideId: string, pickup: GeoPoint, vehicleType: string) {
  const radii = [3000, 5000, 8000]; // metres
  const waits  = [30_000, 30_000];  // ms between attempts

  for (let i = 0; i < radii.length; i++) {
    const drivers = await findNearbyDrivers(pickup, vehicleType, radii[i]);
    if (drivers.length > 0) {
      await broadcastToDrivers(rideId, drivers);
      return;
    }
    if (i < waits.length) await sleep(waits[i]);
  }
  await cancelWithNoDriver(rideId);
}
```

### Rate Limiting (per IP + per user)

```
OTP requests:   3 per phone per 10 min
Ride booking:   5 per rider per hour
Location update: 1 per 2 s per driver (server-side drop duplicate)
API default:    100 req/min per JWT subject
```

### Idempotency

Ride booking and payment endpoints accept `Idempotency-Key` header. The server stores results in Redis for 24 h:

```
GET idempotency:{key} → return cached response (HTTP 200, no re-processing)
```

### Circuit Breaker (external calls)

Use `opossum` (Node.js) around Google Routes API and FCM:

```typescript
const routeBreaker = new CircuitBreaker(fetchGoogleRoute, {
  timeout: 5000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
  fallback: () => estimateFareByDistance(),
});
```

### Eventual Consistency

Ride status is the **source of truth** in Postgres. Redis caches are write-through and expire in 30–60 s. On any cache miss, fall back to Postgres. There is no eventual consistency risk for safety-critical states (OTP verification, payment) because these always write to Postgres first.

---

## 7. Security & Compliance

### Input Validation

All request bodies validated with **Zod** schemas. Example:

```typescript
const BookRideSchema = z.object({
  vehicleType: z.enum(['bike', 'auto', 'car']),
  pickup: z.object({ lat: z.number().min(-90).max(90), lng: z.number().min(-180).max(180), address: z.string().max(300) }),
  drop:   z.object({ lat: z.number().min(-90).max(90), lng: z.number().min(-180).max(180), address: z.string().max(300) }),
  encodedPolyline: z.string().optional(),
});
```

### Encryption

- **In transit**: TLS 1.3 everywhere (Cloudflare terminates → origin over HTTPS)
- **At rest**: AWS S3 SSE-S3 for documents; Postgres encryption via RDS storage encryption or pgcrypto for sensitive fields (bank account numbers)
- **OTPs**: Never logged, never returned in ride response after ride start

### Audit Logs

Every state transition appended to `audit_logs`:

```sql
CREATE TABLE audit_logs (
  id         BIGSERIAL PRIMARY KEY,
  actor_id   UUID,
  actor_role VARCHAR(10),
  action     VARCHAR(100),
  entity     VARCHAR(50),
  entity_id  UUID,
  old_value  JSONB,
  new_value  JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Data Retention

- Location snapshots: 90 days (then archive to cold storage / delete)
- OTPs: TTL 10 min in Redis, never persisted to Postgres
- Ride data: 3 years (legal requirement in India for cab aggregators)
- Audit logs: 7 years

---

## 8. Observability & Operations

### Metrics (Prometheus + Grafana)

Key metrics to track:

```
goapp_ride_requests_total{status,vehicleType}
goapp_ride_match_duration_seconds{vehicleType}   -- time to find driver
goapp_active_rides_gauge
goapp_drivers_online_gauge{city,vehicleType}
goapp_ws_connections_gauge
goapp_location_updates_per_second
goapp_payment_failures_total{method}
```

### Distributed Tracing (OpenTelemetry)

```typescript
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({ url: process.env.OTEL_ENDPOINT }),
  serviceName: 'goapp-core',
});
sdk.start();
```

Trace every ride booking end-to-end: HTTP → matching → Socket.IO emit → driver accept → OTP → payment.

### Structured Logging

```typescript
// Use pino for JSON logging
logger.info({ rideId, driverId, event: 'ride.started', durationMs: 45 }, 'Ride started');
```

### Health Checks

```
GET /health/live    → 200 OK  (process alive)
GET /health/ready   → 200 OK  (DB + Redis connected, else 503)
```

### Deployment Plan

**MVP (Railway/Render)**:
```
1 web service (API + Socket.IO)
1 Postgres instance (+ PostGIS extension)
1 Redis instance
1 BullMQ worker service (background jobs)
```

**Scale-Up (GKE)**:
```
API pods: 3-10 (HPA on CPU + WS connections)
Worker pods: 2-5 (HPA on BullMQ queue depth)
Postgres: Cloud SQL (read replicas for analytics)
Redis: Memorystore cluster
Ingress: GCP Load Balancer + Cloudflare
```

---

## 9. MVP Phased Plan

### Phase 1 — Core Ride Lifecycle (Weeks 1–6)

- OTP auth for rider and driver (phone-based)
- Driver onboarding + document upload (S3)
- Book ride → match → accept → OTP start → complete
- WebSocket: live driver location streaming to rider
- Cash payment only (no gateway integration)
- Basic FCM push notifications

**Milestone**: End-to-end ride from booking to completion working on both apps.

### Phase 2 — Payments & Ratings (Weeks 7–10)

- Online payment via Razorpay / Stripe India
- UPI QR link generation (matches `payment_link` in `TripPaymentDetails`)
- Post-ride ratings (both directions)
- Wallet top-up and balance for riders
- Earnings summary for drivers (matches `earnings` feature in driver app)
- Driver online hours tracking (matches `online_hours_store.dart`)

### Phase 3 — Advanced Matching & Analytics (Weeks 11–16)

- Surge pricing engine (demand/supply ratio per geohash cell)
- Demand planner heatmap (matches `demand_planner` feature in driver app)
- Driver incentives / bonus system (matches `incentives` feature)
- Ride rescheduling / saved locations
- Admin dashboard with live map

### Phase 4 — Scale & Hardening (Weeks 17–22)

- TimescaleDB migration for location_snapshots
- Redis Cluster + Socket.IO horizontal scaling
- OpenTelemetry full trace pipeline
- SLA monitoring: P50/P95/P99 match time
- GDPR / DPDP Act 2023 compliance (data export + deletion)

---

## 10. Code Samples

### 10.1 Auth Service — OTP Flow

```typescript
// src/features/auth/auth.service.ts
import { createClient } from 'redis';
import { sign, verify } from 'jsonwebtoken';
import { generateOTP, sendSMS } from '../utils';

const redis = createClient({ url: process.env.REDIS_URL });

export class AuthService {
  // Step 1: Request OTP
  async requestOtp(phone: string, role: 'RIDER' | 'DRIVER'): Promise<void> {
    // Rate limit: max 3 requests per phone per 10 min
    const rateKey = `otp:rate:${phone}`;
    const count = await redis.incr(rateKey);
    if (count === 1) await redis.expire(rateKey, 600);
    if (count > 3) throw new Error('TOO_MANY_OTP_REQUESTS');

    const otp = generateOTP(4);  // e.g. "7382"
    // Store with 10-min TTL, never persist to DB
    await redis.set(`otp:${phone}`, JSON.stringify({ otp, role }), { EX: 600 });
    await sendSMS(phone, `Your GoApp OTP is ${otp}. Valid for 10 minutes.`);
  }

  // Step 2: Verify OTP → issue tokens
  async verifyOtp(
    phone: string,
    submittedOtp: string,
    deviceId: string
  ): Promise<{ accessToken: string; refreshToken: string; user: User }> {
    const raw = await redis.get(`otp:${phone}`);
    if (!raw) throw new Error('OTP_EXPIRED');

    const { otp, role } = JSON.parse(raw) as { otp: string; role: string };
    if (otp !== submittedOtp) throw new Error('OTP_INVALID');

    // Delete OTP immediately after use
    await redis.del(`otp:${phone}`);

    // Upsert user
    const user = await db.user.upsert({
      where: { phone },
      create: { phone, role },
      update: {},
    });

    return this.issueTokens(user, deviceId);
  }

  async issueTokens(user: User, deviceId: string) {
    const sessionId = crypto.randomUUID();
    const accessToken = sign(
      { sub: user.id, role: user.role, sessionId },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
    const refreshToken = sign(
      { sub: user.id, sessionId },
      process.env.JWT_REFRESH_SECRET!,
      { expiresIn: '30d' }
    );

    // Store refresh session in Redis (revocable)
    await redis.set(
      `refresh:${sessionId}`,
      JSON.stringify({ userId: user.id, role: user.role, deviceId }),
      { EX: 30 * 24 * 3600 }  // 30 days
    );

    return { accessToken, refreshToken, user };
  }
}
```

---

### 10.2 Ride Service — Booking & State Transitions

```typescript
// src/features/ride/ride.service.ts

export class RideService {
  constructor(
    private readonly db: Database,
    private readonly redis: RedisClient,
    private readonly io: Server,           // Socket.IO
    private readonly matchingQueue: Queue   // BullMQ
  ) {}

  async bookRide(riderId: string, dto: BookRideDto): Promise<Ride> {
    // 1. Fetch route from Google Routes API (or use provided polyline)
    const route = await fetchGoogleRoute(dto.pickup, dto.drop);

    // 2. Calculate fare quote
    const fare = calculateFare(dto.vehicleType, route.distanceMeters);

    // 3. Generate OTP for ride start verification
    const otp = generateOTP(4);

    // 4. Create ride in DB
    const ride = await this.db.rides.create({
      riderId,
      vehicleType: dto.vehicleType,
      pickupLat: dto.pickup.lat,
      pickupLng: dto.pickup.lng,
      pickupAddress: dto.pickup.address,
      dropLat: dto.drop.lat,
      dropLng: dto.drop.lng,
      dropAddress: dto.drop.address,
      encodedPolyline: route.encodedPolyline,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
      estimatedFare: fare,
      otp,
      status: 'SEARCHING_FOR_DRIVER',
    });

    // 5. Cache active session
    await this.redis.set(
      `ride:session:${ride.id}`,
      JSON.stringify(ride),
      { EX: 3600 }
    );

    // 6. Notify rider via WebSocket
    this.io.to(`rider:${riderId}`).emit('ride:searching', {
      rideId: ride.id,
      estimatedWaitSec: 60,
    });

    // 7. Enqueue matching job (handles radius expansion + broadcast to drivers)
    await this.matchingQueue.add('match-ride', { rideId: ride.id }, {
      attempts: 3,
      backoff: { type: 'exponential', delay: 5000 },
    });

    return ride;
  }

  async driverAccept(driverId: string, rideId: string): Promise<void> {
    // Atomic lock: prevent two drivers accepting same ride
    const lockKey = `ride:lock:${rideId}`;
    const acquired = await this.redis.set(lockKey, driverId, {
      NX: true,   // only set if not exists
      EX: 10,
    });
    if (!acquired) throw new Error('RIDE_ALREADY_ACCEPTED');

    const ride = await this.db.rides.update(rideId, {
      driverId,
      status: 'DRIVER_ACCEPTED',
      acceptedAt: new Date(),
    });

    // Notify rider
    this.io.to(`rider:${ride.riderId}`).emit('ride:driverAccepted', {
      rideId,
      driver: await this.getDriverInfo(driverId),
      etaMin: await this.estimateEta(driverId, ride),
    });

    // Notify driver with full trip details
    this.io.to(`driver:${driverId}`).emit('order:assigned', {
      rideId,
      otp: ride.otp,
      pickup: { lat: ride.pickupLat, lng: ride.pickupLng, address: ride.pickupAddress },
      drop:   { lat: ride.dropLat,   lng: ride.dropLng,   address: ride.dropAddress },
      encodedPolyline: ride.encodedPolyline,
    });
  }

  async startRide(driverId: string, rideId: string, submittedOtp: string): Promise<void> {
    const ride = await this.db.rides.findById(rideId);
    if (ride.driverId !== driverId) throw new Error('UNAUTHORIZED');
    if (ride.otp !== submittedOtp)  throw new Error('OTP_INVALID');

    await this.db.rides.update(rideId, {
      status: 'RIDE_STARTED',
      startedAt: new Date(),
    });

    // Emit to both parties
    this.io.to(`ride:${rideId}`).emit('ride:started', { rideId, startedAt: new Date() });
  }

  async completeRide(driverId: string, rideId: string): Promise<TripPaymentDetails> {
    const ride = await this.db.rides.update(rideId, {
      status: 'RIDE_COMPLETED',
      completedAt: new Date(),
    });

    const payment = await this.createPayment(ride);

    // Emit TripPaymentDetails to driver (mirrors TripPaymentDetails class in driver app)
    this.io.to(`driver:${driverId}`).emit('trip:completed', {
      rideId,
      payment: {
        totalEarnings: payment.totalEarnings,
        tripFare: payment.tripFare,
        tips: payment.tips,
        discountPercent: payment.discountPercent,
        discountAmount: payment.discountAmount,
        paymentLink: payment.paymentLink,
        method: payment.method,
      },
    });

    // Emit completion to rider
    this.io.to(`rider:${ride.riderId}`).emit('ride:completed', {
      rideId,
      fare: payment.totalCharged,
      duration: ride.durationSeconds,
      distance: ride.distanceMeters,
    });

    return payment;
  }
}
```

---

### 10.3 Location Streaming Service

```typescript
// src/features/location/location.gateway.ts
// Socket.IO handler for driver location streaming

export function registerLocationHandlers(io: Server, redis: RedisClient) {
  io.on('connection', (socket) => {
    const { userId, role } = socket.data.auth;  // set by JWT middleware

    // Driver joins their personal room
    if (role === 'DRIVER') {
      socket.join(`driver:${userId}`);
    }

    // Rider subscribes to driver location for their active ride
    if (role === 'RIDER') {
      socket.join(`rider:${userId}`);
    }

    // Driver streams location
    socket.on('driver:location', async (data: LocationUpdate) => {
      const { lat, lng, heading, speedKmh } = data;

      // Validate
      if (!isValidCoord(lat, lng)) return;

      // 1. Update Redis cache (hot path — no DB write)
      await redis.set(
        `driver:location:${userId}`,
        JSON.stringify({ lat, lng, heading, speedKmh, ts: Date.now() }),
        { EX: 30 }
      );

      // 2. Find active ride for this driver
      const rideId = await redis.get(`driver:activeRide:${userId}`);
      if (!rideId) return;

      // 3. Forward to rider in real-time
      const ride = await redis.get(`ride:session:${rideId}`);
      if (!ride) return;
      const { riderId } = JSON.parse(ride);

      const etaMin = await estimateEtaFromCache(userId, rideId);

      // Emit to rider — matches DriverTrackingSocketDataSource.connect() stream
      io.to(`rider:${riderId}`).emit('ride:driverLocation', {
        rideId,
        lat,
        lng,
        heading,
        etaMin,
      });

      // 4. Persist snapshot to DB (batched every 15 s via background flush)
      await redis.lPush(`loc:batch:${rideId}`, JSON.stringify({ lat, lng, heading, speedKmh }));
      await redis.expire(`loc:batch:${rideId}`, 3600);
    });

    socket.on('disconnect', async () => {
      if (role === 'DRIVER') {
        // Mark driver as offline if they disconnect
        await redis.del(`driver:location:${userId}`);
        await updateDriverOnlineStatus(userId, false);
      }
    });
  });
}
```

---

### 10.4 Matching Worker (BullMQ)

```typescript
// src/workers/matching.worker.ts

const matchingWorker = new Worker('match-ride', async (job) => {
  const { rideId } = job.data;
  const ride = await db.rides.findById(rideId);

  if (ride.status !== 'SEARCHING_FOR_DRIVER') return; // already matched

  const radii = [3000, 5000, 8000];

  for (const radius of radii) {
    // PostGIS geospatial query
    const drivers = await db.query(`
      SELECT d.id, d.user_id, u.name,
        ST_Distance(d.current_location, ST_MakePoint($1,$2)::geography) as dist_m
      FROM drivers d
      JOIN users u ON u.id = d.user_id
      WHERE d.is_online = TRUE
        AND d.vehicle_type = $3
        AND d.onboarding_status = 'VERIFIED'
        AND NOT EXISTS (
          SELECT 1 FROM rides r WHERE r.driver_id = d.id
          AND r.status NOT IN ('RIDE_COMPLETED','CANCELLED')
        )
        AND ST_DWithin(d.current_location, ST_MakePoint($1,$2)::geography, $4)
      ORDER BY dist_m ASC LIMIT 10
    `, [ride.pickupLng, ride.pickupLat, ride.vehicleType, radius]);

    if (drivers.length === 0) {
      await sleep(20_000); // wait 20s before expanding radius
      continue;
    }

    // Broadcast to each candidate driver (15-second acceptance window)
    for (const driver of drivers) {
      io.to(`driver:${driver.user_id}`).emit('order:available', {
        rideId: ride.id,
        pickup: { lat: ride.pickupLat, lng: ride.pickupLng, address: ride.pickupAddress },
        drop:   { lat: ride.dropLat,   lng: ride.dropLng,   address: ride.dropAddress },
        distanceKm: (driver.dist_m / 1000).toFixed(1),
        estimatedFare: ride.estimatedFare,
        vehicleType: ride.vehicleType,
        expiresInMs: 15_000,  // matches AvailableOrdersCubit._perOrderDuration
      });

      // Track which drivers were offered this ride
      await redis.sAdd(`ride:offered:${ride.id}`, driver.user_id);
    }

    // Wait for acceptance (poll Redis lock)
    const accepted = await waitForAcceptance(ride.id, 15_000);
    if (accepted) return;  // driver accepted via driverAccept()
  }

  // No driver found after all radius expansions
  await db.rides.update(rideId, { status: 'CANCELLED', cancelledBy: 'SYSTEM' });
  io.to(`rider:${ride.riderId}`).emit('ride:noDriverFound', { rideId });
}, { connection: redisConnection });
```

---

### 10.5 Fare Calculation

```typescript
// src/features/ride/fare.service.ts
// Mirrors BookingService enum: bike | auto | car

const BASE_FARES: Record<string, number> = {
  bike: 20,
  auto: 30,
  car:  50,
};

const PER_KM_RATES: Record<string, number> = {
  bike: 8,
  auto: 13,
  car:  18,
};

const MIN_FARES: Record<string, number> = {
  bike: 25,
  auto: 40,
  car:  80,
};

export function calculateFare(
  vehicleType: 'bike' | 'auto' | 'car',
  distanceMeters: number,
  surgeMultiplier: number = 1.0
): FareQuote {
  const distKm = distanceMeters / 1000;
  const raw = BASE_FARES[vehicleType] + distKm * PER_KM_RATES[vehicleType];
  const withSurge = raw * surgeMultiplier;
  const final = Math.max(withSurge, MIN_FARES[vehicleType]);

  return {
    baseFare: BASE_FARES[vehicleType],
    servicePrices: {
      bike: Math.max(
        BASE_FARES.bike + distKm * PER_KM_RATES.bike * surgeMultiplier,
        MIN_FARES.bike
      ),
      auto: Math.max(
        BASE_FARES.auto + distKm * PER_KM_RATES.auto * surgeMultiplier,
        MIN_FARES.auto
      ),
      car: Math.max(
        BASE_FARES.car + distKm * PER_KM_RATES.car * surgeMultiplier,
        MIN_FARES.car
      ),
    },
  };
}
```

---

### 10.6 Express App Bootstrap

```typescript
// src/app.ts
import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { jwtMiddleware } from './middleware/auth';

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' },
  transports: ['websocket', 'polling'],
});

// Socket.IO Redis adapter for horizontal scaling
const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();
await Promise.all([pubClient.connect(), subClient.connect()]);
io.adapter(createAdapter(pubClient, subClient));

// Security
app.use(helmet());
app.use(express.json({ limit: '1mb' }));

// Rate limiting
app.use('/auth', rateLimit({ windowMs: 60_000, max: 20 }));
app.use('/api',  rateLimit({ windowMs: 60_000, max: 100 }));

// Routes
app.use('/auth',          authRouter);
app.use('/profile',       jwtMiddleware, profileRouter);
app.use('/rides',         jwtMiddleware, rideRouter);
app.use('/api/v1',        jwtMiddleware, driverRouter);
app.use('/admin',         jwtMiddleware, requireRole('ADMIN'), adminRouter);

// WebSocket auth + handlers
io.use(socketJwtMiddleware);
registerLocationHandlers(io, redis);
registerRideHandlers(io, redis);

// Health checks
app.get('/health/live',  (_, res) => res.json({ status: 'ok' }));
app.get('/health/ready', healthCheckHandler);

server.listen(process.env.PORT ?? 3000, () => {
  console.log(`GoApp backend running on :${process.env.PORT ?? 3000}`);
});
```

---

## Environment Variables Reference

```bash
# Server
NODE_ENV=development
PORT=3000
JWT_SECRET=<min-32-char-secret>
JWT_REFRESH_SECRET=<min-32-char-secret>

# Database
DATABASE_URL=postgresql://user:pass@host:5432/goapp

# Redis
REDIS_URL=redis://default:pass@host:6379

# Google
GOOGLE_ROUTES_API_KEY=<your-key>
GOOGLE_MAPS_PLATFORM_KEY=<your-key>

# Firebase (FCM)
FIREBASE_SERVICE_ACCOUNT_JSON=<base64-encoded-json>

# OTP (MSG91 example)
MSG91_AUTH_KEY=<key>
MSG91_TEMPLATE_ID=<template>

# Storage
AWS_S3_BUCKET=goapp-documents
AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=<key>
AWS_SECRET_ACCESS_KEY=<secret>

# Frontend URLs
RIDER_APP_BASE_URL=https://api.goapp.com
DRIVER_APP_BASE_URL=https://api.goappdriver.com

# Observability
OTEL_ENDPOINT=http://otel-collector:4318/v1/traces
SENTRY_DSN=<dsn>
```

---

*Generated by Claude — aligned to `goapp-main` rider app and `Go-App-Driver-main` driver/captain app source trees.*
