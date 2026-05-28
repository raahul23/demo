enum BookingProgressState {
  searchingForDriver,
  driverAccepted,
  driverArriving,
  driverArrived,
  rideStarted,
  reachedDropLocation,
  rideCompleted,
  cancelled,
}

BookingProgressState bookingProgressStateFromString(String? value) {
  switch (value) {
    case 'SEARCHING_FOR_DRIVER':
      return BookingProgressState.searchingForDriver;
    case 'DRIVER_ACCEPTED':
      return BookingProgressState.driverAccepted;
    case 'DRIVER_ARRIVING':
      return BookingProgressState.driverArriving;
    case 'DRIVER_ARRIVED':
      return BookingProgressState.driverArrived;
    case 'RIDE_STARTED':
      return BookingProgressState.rideStarted;
    case 'REACHED_DROP_LOCATION':
      return BookingProgressState.reachedDropLocation;
    case 'RIDE_COMPLETED':
      return BookingProgressState.rideCompleted;
    case 'CANCELLED':
      return BookingProgressState.cancelled;
    default:
      return BookingProgressState.searchingForDriver;
  }
}

String bookingProgressStateToString(BookingProgressState state) {
  switch (state) {
    case BookingProgressState.searchingForDriver:
      return 'SEARCHING_FOR_DRIVER';
    case BookingProgressState.driverAccepted:
      return 'DRIVER_ACCEPTED';
    case BookingProgressState.driverArriving:
      return 'DRIVER_ARRIVING';
    case BookingProgressState.driverArrived:
      return 'DRIVER_ARRIVED';
    case BookingProgressState.rideStarted:
      return 'RIDE_STARTED';
    case BookingProgressState.reachedDropLocation:
      return 'REACHED_DROP_LOCATION';
    case BookingProgressState.rideCompleted:
      return 'RIDE_COMPLETED';
    case BookingProgressState.cancelled:
      return 'CANCELLED';
  }
}
