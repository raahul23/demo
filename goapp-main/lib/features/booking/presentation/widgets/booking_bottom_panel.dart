import 'package:flutter/material.dart';

import '../../domain/entities/booking_service.dart';
import '../../domain/entities/driver_search_status.dart';
import '../cubit/booking_state.dart';
import 'driver_arriving_sheet.dart';
import 'ride_completed_sheet.dart';
import 'ride_in_progress_sheet.dart';
import 'service_selector.dart';

class BookingBottomPanel extends StatelessWidget {
  final BookingState state;
  final VoidCallback onBookNow;
  final VoidCallback onCancelRide;
  final VoidCallback onCallDriver;
  final VoidCallback onMessageDriver;
  final VoidCallback onEmergency;
  final VoidCallback onSos;
  final VoidCallback onHelp;
  final VoidCallback onPayment;
  final ValueChanged<BookingService> onSelectService;
  final bool lockServiceSelection;

  const BookingBottomPanel({
    super.key,
    required this.state,
    required this.onBookNow,
    required this.onCancelRide,
    required this.onCallDriver,
    required this.onMessageDriver,
    required this.onEmergency,
    required this.onSos,
    required this.onHelp,
    required this.onPayment,
    required this.onSelectService,
    this.lockServiceSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state.driverSearchStatus == DriverSearchStatus.arriving &&
        state.driverArrivalKm != null &&
        state.driverArrivalMin != null &&
        state.driverInfo != null) {
      return DriverArrivingSheet(
        distanceKm: state.driverArrivalKm!,
        etaMin: state.driverArrivalMin!,
        arrivedInMin: state.driverArrivalInitialMin ?? state.driverArrivalMin!,
        hasArrived: state.driverHasArrived,
        driver: state.driverInfo!,
        onCancel: onCancelRide,
        onCall: onCallDriver,
        onMessage: onMessageDriver,
      );
    }

    if (state.driverSearchStatus == DriverSearchStatus.completed &&
        state.driverInfo != null) {
      return RideCompletedSheet(
        driver: state.driverInfo!,
        pickupLabel: state.pickupLabel,
        dropLabel: state.dropLabel,
        distanceKm: state.distanceKm ?? 0,
        durationMin: state.durationMin ?? 0,
        totalFare: state.selectedFare ?? state.fareQuote?.baseFare ?? 0,
        onPayment: onPayment,
      );
    }

    if (state.driverSearchStatus == DriverSearchStatus.inRide &&
        state.driverInfo != null) {
      return RideInProgressSheet(
        driver: state.driverInfo!,
        pickupLabel: state.pickupLabel,
        dropLabel: state.dropLabel,
        onEmergency: onEmergency,
        onSos: onSos,
        onHelp: onHelp,
      );
    }

    if (state.route == null || state.fareQuote == null) {
      return const SizedBox.shrink();
    }

    return BookingSummaryCard(
      pickupLabel: state.pickupLabel,
      dropLabel: state.dropLabel,
      distanceKm: state.distanceKm ?? 0,
      durationMin: state.durationMin ?? 0,
      baseFare: state.fareQuote!.baseFare,
      services: state.fareQuote!.servicePrices,
      selectedService: state.selectedService,
      lockServiceSelection: lockServiceSelection,
      onSelectService: onSelectService,
      onBookNow: onBookNow,
    );
  }
}

class BookingSummaryCard extends StatelessWidget {
  final String pickupLabel;
  final String dropLabel;
  final double distanceKm;
  final int durationMin;
  final double baseFare;
  final Map<BookingService, double> services;
  final BookingService? selectedService;
  final ValueChanged<BookingService> onSelectService;
  final VoidCallback onBookNow;
  final bool lockServiceSelection;

  const BookingSummaryCard({
    super.key,
    required this.pickupLabel,
    required this.dropLabel,
    required this.distanceKm,
    required this.durationMin,
    required this.baseFare,
    required this.services,
    required this.selectedService,
    required this.onSelectService,
    required this.onBookNow,
    this.lockServiceSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x14000000),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.circle, size: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickupLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dropLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Distance: ${distanceKm.toStringAsFixed(1)} km'),
                  Text('ETA: $durationMin min'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Estimated fare: Rs ${baseFare.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              if (lockServiceSelection)
                _SingleServiceSummary(
                  service: selectedService ?? BookingService.bike,
                  price: (selectedService != null
                          ? services[selectedService]
                          : services[BookingService.bike]) ??
                      0,
                )
              else
                ServiceSelector(
                  selectedService: selectedService,
                  prices: services,
                  onSelected: onSelectService,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedService == null ? null : onBookNow,
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SingleServiceSummary extends StatelessWidget {
  const _SingleServiceSummary({
    required this.service,
    required this.price,
  });

  final BookingService service;
  final double price;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    switch (service) {
      case BookingService.bike:
        icon = Icons.two_wheeler;
        label = 'Bike';
        break;
      case BookingService.auto:
        icon = Icons.electric_rickshaw;
        label = 'Auto';
        break;
      case BookingService.car:
        icon = Icons.directions_car;
        label = 'Car';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black87),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('Rs ${price.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}
