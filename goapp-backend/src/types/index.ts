export type UserRole = 'RIDER' | 'DRIVER' | 'ADMIN';

export type VehicleType = 'bike' | 'auto' | 'car';

export type RideStatus =
  | 'SEARCHING_FOR_DRIVER'
  | 'DRIVER_ACCEPTED'
  | 'DRIVER_ARRIVING'
  | 'DRIVER_ARRIVED'
  | 'RIDE_STARTED'
  | 'REACHED_DROP_LOCATION'
  | 'RIDE_COMPLETED'
  | 'CANCELLED';

export type CancelledBy = 'RIDER' | 'DRIVER' | 'SYSTEM';

export interface DbUser {
  id: string;
  phone: string;
  name: string | null;
  email: string | null;
  gender: string | null;
  emergency_contact: string | null;
  role: UserRole;
  profile_photo: string | null;
  fcm_token: string | null;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface DbDriver {
  id: string;
  user_id: string;
  onboarding_status: 'PENDING' | 'DOCUMENTS_SUBMITTED' | 'VERIFIED' | 'REJECTED';
  is_online: boolean;
  city: string | null;
  vehicle_type: VehicleType | null;
  rating_avg: number;
  total_trips: number;
  wallet_balance: number;
  created_at: Date;
  updated_at: Date;
}

export interface DbRide {
  id: string;
  rider_id: string;
  driver_id: string | null;
  vehicle_type: VehicleType;
  pickup_address: string | null;
  pickup_lat: number;
  pickup_lng: number;
  drop_address: string | null;
  drop_lat: number;
  drop_lng: number;
  encoded_polyline: string | null;
  distance_meters: number;
  duration_seconds: number;
  status: RideStatus;
  otp: string | null;
  estimated_fare: number;
  final_fare: number | null;
  cancelled_by: CancelledBy | null;
  cancel_reason: string | null;
  accepted_at: Date | null;
  arrived_at: Date | null;
  started_at: Date | null;
  completed_at: Date | null;
  cancelled_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface FareQuote {
  baseFare: number;
  servicePrices: Record<VehicleType, number>;
}

export interface JwtPayload {
  sub: string;
  role: UserRole;
  sessionId: string;
  iat?: number;
  exp?: number;
}

export interface DriverInfo {
  id: string;
  name: string;
  vehicle_model: string;
  plate_number: string;
  otp: string;
  phone: string;
  service: VehicleType;
  rating: number;
}

export interface LocationUpdate {
  lat: number;
  lng: number;
  heading?: number;
  speedKmh?: number;
}
