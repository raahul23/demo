# GoApp API Specification (Current + Planned)

This document lists API endpoints currently used in the app and the planned endpoints required to complete production flows. It reflects the current codebase and should be updated whenever new networked features are added.

---

## Base URL
`Env.baseUrl` (from `.env`, fallback `https://api.goapp.com`)

---

# A) Backend APIs Used in App Today

## 1) Request OTP
**POST** `/auth/request-otp`

**Request**
```json
{ "phone": "+911234567890" }
```

**Response**
```json
{ "message": "OTP sent", "otp_id": "otp_123" }
```

---

## 2) Verify OTP / Login
**POST** `/auth/login`

**Request**
```json
{ "phone": "+911234567890", "otp": "123456", "otp_id": "otp_123" }
```

**Response**
```json
{ "id": "user_001", "name": "Demo User", "token": "demo-token-123" }
```

---

## 3) Resend OTP
**POST** `/auth/resend-otp`

**Request**
```json
{ "phone": "+911234567890" }
```

**Response**
```json
{ "message": "OTP resent" }
```

---

## 4) Create Profile
**POST** `/profile/create`

**Request**
```json
{
  "name": "Kumar",
  "gender": "Male",
  "email": "kumar@mail.com",
  "emergency_contact": "9876543210"
}
```

**Response**
```json
{
  "id": "profile_001",
  "name": "Kumar",
  "gender": "Male",
  "email": "kumar@mail.com",
  "emergency_contact": "9876543210"
}
```

---

# B) Google APIs Used

## 1) Places Autocomplete
**GET** `https://maps.googleapis.com/maps/api/place/autocomplete/json`

**Query**
```
input=<text>&key=<GOOGLE_MAPS_API_KEY>&components=country:IN
```

**Response (used fields)**
```json
{
  "status": "OK",
  "predictions": [
    { "description": "MG Road, Bengaluru, Karnataka, India", "place_id": "abc" }
  ]
}
```

---

## 2) Place Details
**GET** `https://maps.googleapis.com/maps/api/place/details/json`

**Query**
```
place_id=<id>&fields=geometry&key=<GOOGLE_MAPS_API_KEY>
```

**Response (used fields)**
```json
{
  "status": "OK",
  "result": { "geometry": { "location": { "lat": 12.97, "lng": 77.59 } } }
}
```

---

## 3) Reverse Geocode
**GET** `https://maps.googleapis.com/maps/api/geocode/json`

**Query**
```
latlng=12.97,77.59&key=<GOOGLE_MAPS_API_KEY>
```

**Response (used fields)**
```json
{
  "status": "OK",
  "results": [{ "formatted_address": "..." }]
}
```

---

## 4) Routes (Polyline + ETA)
**POST** `https://routes.googleapis.com/directions/v2:computeRoutes`

**Headers**
```
X-Goog-Api-Key: <GOOGLE_MAPS_API_KEY>
X-Goog-FieldMask: routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration
```

**Body**
```json
{
  "origin": {
    "location": { "latLng": { "latitude": 12.97, "longitude": 77.59 } }
  },
  "destination": {
    "location": { "latLng": { "latitude": 12.98, "longitude": 77.60 } }
  },
  "travelMode": "DRIVE",
  "routingPreference": "TRAFFIC_AWARE",
  "computeAlternativeRoutes": false,
  "units": "METRIC"
}
```

**Response (used fields)**
```json
{
  "routes": [
    {
      "polyline": { "encodedPolyline": "..." },
      "distanceMeters": 1234,
      "duration": "420s"
    }
  ]
}
```

---

## 5) Route Matrix (Optional Refinement)
**POST** `https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix`

**Headers**
```
X-Goog-Api-Key: <GOOGLE_MAPS_API_KEY>
X-Goog-FieldMask: distanceMeters,duration
```

**Body**
```json
{
  "origins": [
    { "waypoint": { "location": { "latLng": { "latitude": 12.97, "longitude": 77.59 } } } }
  ],
  "destinations": [
    { "waypoint": { "location": { "latLng": { "latitude": 12.98, "longitude": 77.60 } } } }
  ],
  "travelMode": "DRIVE",
  "routingPreference": "TRAFFIC_AWARE"
}
```

**Response (used fields)**
```json
[
  { "distanceMeters": 1234, "duration": "420s" }
]
```

---

# C) Mocked Today (Required for Production)

## 1) Services List
**GET** `/services`

**Response**
```json
[
  {
    "id": "bike",
    "name": "Bike",
    "icon_key": "bike",
    "description": "Quick solo rides",
    "booking_service": "bike",
    "featured": true
  }
]
```

---

## 2) Ride History (Activity)
**GET** `/rides/history`

**Response**
```json
[
  {
    "id": "ride_101",
    "status": "completed",
    "pickup_label": "Indiranagar",
    "drop_label": "MG Road",
    "started_at": "2026-02-08T10:10:00Z",
    "ended_at": "2026-02-08T10:25:00Z",
    "distance_km": 6.2,
    "duration_min": 15,
    "cancelled_by": null,
    "driver": {
      "name": "Rahul",
      "vehicle": "Bike",
      "plate": "KA01AB1234",
      "rating": 4.8
    },
    "payment": {
      "fare": 120,
      "method": "UPI",
      "transaction_id": "txn_123"
    },
    "support_note": "Need help? Contact support",
    "receipt_url": "https://example.com/receipt/ride_101"
  }
]
```

---

## 3) Receipt Download
**GET** `/rides/{id}/receipt`

**Response**
```json
{ "url": "https://example.com/receipt/ride_101" }
```

---

## 4) Payment Options
**GET** `/payments/options?amount=120`

**Response**
```json
[
  {
    "id": "upi",
    "type": "upi",
    "title": "UPI",
    "subtitle": "Pay via UPI apps",
    "is_recommended": true
  }
]
```

---

## 5) Submit Payment
**POST** `/payments/submit`

**Request**
```json
{ "ride_id": "ride_101", "option_id": "upi", "amount": 120 }
```

**Response**
```json
{ "status": "success", "transaction_id": "txn_123" }
```

---

## 6) Submit Feedback
**POST** `/feedback`

**Request**
```json
{
  "driver_name": "Rahul",
  "vehicle": "Bike",
  "plate_number": "KA01AB1234",
  "pickup_label": "Indiranagar",
  "drop_label": "MG Road",
  "distance_km": 6.2,
  "duration_min": 15,
  "rating": 5,
  "comment": "Smooth ride"
}
```

**Response**
```json
{ "status": "ok" }
```

---

## 7) Driver Info (Booking)
**GET** `/rides/{id}/driver`

**Response**
```json
{
  "name": "Rahul",
  "vehicle_model": "Bike",
  "plate_number": "KA01AB1234",
  "otp": "4321",
  "phone": "+911234567890",
  "service": "bike"
}
```

---

## 8) Driver Tracking (Socket)
**WSS** `/rides/{id}/track`

**Message**
```json
{ "lat": 12.9716, "lng": 77.5946, "timestamp": 1738920000 }
```

---

## 9) Active Ride (Recovery)
**GET** `/rides/active`

**Response**
```json
{
  "id": "ride_101",
  "status": "DRIVER_ARRIVING",
  "pickup_label": "Indiranagar",
  "drop_label": "MG Road"
}
```

---

## Update Policy
Whenever a new networked feature is added, update this file:
- Add endpoint
- Add request/response samples
- Note any required headers or auth

