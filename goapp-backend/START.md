# GoApp Backend — Quick Start

## Prerequisites
- Node.js 20+  ✓
- Docker Desktop (must be **running**)

---

## Step 1 — Start Docker containers (PostgreSQL + Redis)

Open a terminal in `goapp-backend/` and run:

```bash
docker compose up -d
```

Wait ~10 seconds for containers to be healthy. Verify:

```bash
docker compose ps
```

Both `goapp_postgres` and `goapp_redis` should show `healthy`.

---

## Step 2 — Run database migrations

```bash
npm run migrate
```

Output: `✓ Migration completed successfully`

---

## Step 3 — Start the backend server

```bash
npm run dev
```

Output:
```
🚀 GoApp Backend running on http://localhost:3000
   OTP bypass  : ON (use "0000")
   Health      : http://localhost:3000/health/ready
```

---

## Step 4 — Verify it works

```bash
curl http://localhost:3000/health/ready
# → {"status":"ok","db":"connected","redis":"connected"}

curl -X POST http://localhost:3000/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"+919876543210"}'
# → {"message":"OTP sent","otp_id":"..."}

curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+919876543210","otp":"0000"}'
# → {"id":"...","name":"","token":"eyJ..."}
```

---

## Step 5 — Run all tests

With Docker running and migrations done:

```bash
npm test
```

---

## Connect Flutter app

The Flutter `dev.env` is already updated:
```
API_BASE_URL=http://10.0.2.2:3000   ← Android emulator
MOCK_API=false
```

For iOS Simulator, change to `http://127.0.0.1:3000`.
For a physical device on the same WiFi, use your machine's LAN IP (e.g. `http://192.168.1.x:3000`).

---

## OTP in development

`OTP_BYPASS=true` in `.env` → the OTP is always **`0000`**.
Set `OTP_BYPASS=false` and add `MSG91_AUTH_KEY` to send real SMS.
