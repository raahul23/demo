import { calculateFare, getFareQuote } from '../src/features/ride/fare.service';

describe('Fare Calculation', () => {
  describe('calculateFare', () => {
    test('bike: returns minimum fare for short distance', () => {
      const fare = calculateFare('bike', 500); // 0.5 km
      expect(fare).toBe(25); // min fare
    });

    test('bike: calculates correctly for 10km', () => {
      const fare = calculateFare('bike', 10_000);
      // 20 + 10 * 8 = 100
      expect(fare).toBe(100);
    });

    test('auto: calculates correctly for 5km', () => {
      const fare = calculateFare('auto', 5_000);
      // 30 + 5 * 13 = 95
      expect(fare).toBe(95);
    });

    test('car: returns minimum fare for short distance', () => {
      const fare = calculateFare('car', 1_000); // 1 km
      // 50 + 1 * 18 = 68 < 80 min
      expect(fare).toBe(80);
    });

    test('car: calculates with surge multiplier', () => {
      const fare = calculateFare('car', 10_000, 1.5);
      // (50 + 10 * 18) * 1.5 = 230 * 1.5 = 345
      expect(fare).toBe(345);
    });

    test('all vehicle types produce non-negative fares', () => {
      const bikes = calculateFare('bike', 0);
      const auto = calculateFare('auto', 0);
      const car = calculateFare('car', 0);
      expect(bikes).toBeGreaterThan(0);
      expect(auto).toBeGreaterThan(0);
      expect(car).toBeGreaterThan(0);
    });
  });

  describe('getFareQuote', () => {
    test('returns quotes for all vehicle types', () => {
      const quote = getFareQuote(6_000);
      expect(quote).toHaveProperty('servicePrices.bike');
      expect(quote).toHaveProperty('servicePrices.auto');
      expect(quote).toHaveProperty('servicePrices.car');
    });

    test('car fare is always higher than bike for same distance', () => {
      const quote = getFareQuote(8_000);
      expect(quote.servicePrices.car).toBeGreaterThan(quote.servicePrices.bike);
    });

    test('surge multiplier increases all fares', () => {
      const normal = getFareQuote(10_000, 1.0);
      const surge = getFareQuote(10_000, 1.5);
      expect(surge.servicePrices.bike).toBeGreaterThan(normal.servicePrices.bike);
      expect(surge.servicePrices.auto).toBeGreaterThan(normal.servicePrices.auto);
      expect(surge.servicePrices.car).toBeGreaterThan(normal.servicePrices.car);
    });
  });
});
