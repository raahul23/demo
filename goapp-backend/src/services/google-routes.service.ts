import axios from 'axios';
import { env } from '../config/env';
import { GeoPoint } from '../types';

export interface RouteResult {
  encodedPolyline: string;
  distanceMeters: number;
  durationSeconds: number;
}

export async function fetchRoute(pickup: GeoPoint, drop: GeoPoint): Promise<RouteResult> {
  if (!env.GOOGLE_MAPS_API_KEY) {
    const distanceMeters = estimateDistance(pickup, drop);
    return { encodedPolyline: '', distanceMeters, durationSeconds: Math.round(distanceMeters / 8) };
  }

  try {
    const response = await axios.post(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
      {
        origin: { location: { latLng: { latitude: pickup.lat, longitude: pickup.lng } } },
        destination: { location: { latLng: { latitude: drop.lat, longitude: drop.lng } } },
        travelMode: 'DRIVE',
        routingPreference: 'TRAFFIC_AWARE',
        computeAlternativeRoutes: false,
        units: 'METRIC',
      },
      {
        headers: {
          'X-Goog-Api-Key': env.GOOGLE_MAPS_API_KEY,
          'X-Goog-FieldMask': 'routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration',
          'Content-Type': 'application/json',
        },
        timeout: 10_000,
      }
    );

    const routes = response.data?.routes ?? [];
    if (routes.length === 0) throw new Error('No routes returned');

    const route = routes[0];
    const durationStr: string = route.duration ?? '0s';
    const durationSeconds = parseInt(durationStr.replace('s', ''), 10) || 0;

    return {
      encodedPolyline: route.polyline?.encodedPolyline ?? '',
      distanceMeters: route.distanceMeters ?? 0,
      durationSeconds,
    };
  } catch {
    const distanceMeters = estimateDistance(pickup, drop);
    return { encodedPolyline: '', distanceMeters, durationSeconds: Math.round(distanceMeters / 8) };
  }
}

function estimateDistance(a: GeoPoint, b: GeoPoint): number {
  const R = 6_371_000;
  const dLat = ((b.lat - a.lat) * Math.PI) / 180;
  const dLng = ((b.lng - a.lng) * Math.PI) / 180;
  const x =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((a.lat * Math.PI) / 180) * Math.cos((b.lat * Math.PI) / 180) * Math.sin(dLng / 2) ** 2;
  return Math.round(2 * R * Math.asin(Math.sqrt(x)));
}
