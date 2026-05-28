import { VehicleType, FareQuote } from '../../types';

const BASE_FARES: Record<VehicleType, number> = {
  bike: 20,
  auto: 30,
  car: 50,
};

const PER_KM_RATES: Record<VehicleType, number> = {
  bike: 8,
  auto: 13,
  car: 18,
};

const MIN_FARES: Record<VehicleType, number> = {
  bike: 25,
  auto: 40,
  car: 80,
};

export function calculateFare(
  vehicleType: VehicleType,
  distanceMeters: number,
  surgeMultiplier = 1.0
): number {
  const distKm = distanceMeters / 1000;
  const raw = BASE_FARES[vehicleType] + distKm * PER_KM_RATES[vehicleType];
  const withSurge = raw * surgeMultiplier;
  return Math.ceil(Math.max(withSurge, MIN_FARES[vehicleType]));
}

export function getFareQuote(distanceMeters: number, surgeMultiplier = 1.0): FareQuote {
  return {
    baseFare: BASE_FARES.bike,
    servicePrices: {
      bike: calculateFare('bike', distanceMeters, surgeMultiplier),
      auto: calculateFare('auto', distanceMeters, surgeMultiplier),
      car: calculateFare('car', distanceMeters, surgeMultiplier),
    },
  };
}
