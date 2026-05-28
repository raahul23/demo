import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/env.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/services/phone_number_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cubit/auth_session_cubit.dart';
import '../../features/auth/presentation/cubit/auth_onboarding_cubit.dart';
import '../onboarding/onboarding_storage.dart';
import '../onboarding/onboarding_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource_impl.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/profile_local_datasource_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_cached_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/domain/services/profile_validation_service.dart';
import '../../features/search/data/datasources/places_remote_datasource.dart';
import '../../features/search/data/datasources/places_remote_datasource_impl.dart';
import '../../features/search/data/repositories/places_repository_impl.dart';
import '../../features/search/domain/repositories/places_repository.dart';
import '../../features/search/domain/usecases/search_places_usecase.dart';
import '../../features/search/domain/usecases/reverse_geocode_usecase.dart';
import '../../features/search/domain/usecases/get_place_details_usecase.dart';
import '../../features/search/presentation/bloc/places_bloc.dart';
import '../../features/search/presentation/cubit/ride_search_cubit.dart';
import '../../features/location/data/datasources/location_permission_storage.dart';
import '../../features/location/data/repositories/location_permission_repository_impl.dart';
import '../../features/location/domain/repositories/location_permission_repository.dart';
import '../../features/location/domain/usecases/get_location_deny_count_usecase.dart';
import '../../features/location/domain/usecases/increment_location_deny_count_usecase.dart';
import '../../features/location/domain/usecases/reset_location_deny_count_usecase.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/datasources/booking_remote_datasource_impl.dart';
import '../../features/booking/data/datasources/driver_remote_datasource.dart';
import '../../features/booking/data/datasources/driver_remote_datasource_impl.dart';
import '../../features/booking/data/datasources/driver_tracking_socket_datasource.dart';
import '../../features/booking/data/datasources/driver_tracking_socket_datasource_impl.dart';
import '../../features/booking/data/datasources/booking_progress_storage.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/data/repositories/driver_repository_impl.dart';
import '../../features/booking/data/repositories/driver_tracking_repository_impl.dart';
import '../../features/booking/data/repositories/booking_progress_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/repositories/driver_repository.dart';
import '../../features/booking/domain/repositories/driver_tracking_repository.dart';
import '../../features/booking/domain/repositories/booking_progress_repository.dart';
import '../../features/booking/domain/usecases/get_booking_route_usecase.dart';
import '../../features/booking/domain/usecases/book_ride_usecase.dart';
import '../../features/booking/domain/usecases/get_driver_info_usecase.dart';
import '../../features/booking/domain/usecases/watch_driver_location_usecase.dart';
import '../../features/booking/domain/usecases/get_booking_progress_usecase.dart';
import '../../features/booking/domain/usecases/save_booking_progress_usecase.dart';
import '../../features/booking/domain/usecases/clear_booking_progress_usecase.dart';
import '../../features/booking/domain/services/fare_calculator.dart';
import '../../features/booking/domain/services/driver_arrival_estimator.dart';
import '../../features/booking/domain/services/driver_tracking_service.dart';
import '../../features/booking/presentation/booking_progress_controller.dart';
import '../../features/booking/presentation/booking_flow_coordinator.dart';
import '../../features/booking/presentation/booking_background_coordinator.dart';
import '../../features/notifications/data/datasources/notifications_local_datasource.dart';
import '../../features/notifications/data/datasources/notifications_local_datasource_impl.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/init_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/show_driver_accepted_usecase.dart';
import '../../features/notifications/domain/usecases/show_driver_arrived_usecase.dart';
import '../../features/notifications/domain/usecases/show_driver_arriving_usecase.dart';
import '../../features/notifications/domain/usecases/show_ride_completed_usecase.dart';
import '../../features/notifications/domain/usecases/show_ride_progress_usecase.dart';
import '../../features/notifications/domain/usecases/show_ride_started_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/datasources/payment_remote_datasource_impl.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/get_payment_options_usecase.dart';
import '../../features/payment/domain/usecases/submit_payment_usecase.dart';
import '../../features/feedback/data/datasources/feedback_remote_datasource.dart';
import '../../features/feedback/data/datasources/feedback_remote_datasource_impl.dart';
import '../../features/feedback/data/repositories/feedback_repository_impl.dart';
import '../../features/feedback/domain/repositories/feedback_repository.dart';
import '../../features/feedback/domain/usecases/submit_feedback_usecase.dart';
import '../../features/services/data/datasources/services_remote_datasource.dart';
import '../../features/services/data/datasources/services_remote_datasource_impl.dart';
import '../../features/services/data/repositories/services_repository_impl.dart';
import '../../features/services/domain/repositories/services_repository.dart';
import '../../features/services/domain/usecases/get_services_usecase.dart';
import '../../features/services/presentation/cubit/services_cubit.dart';
import '../../features/activity/data/datasources/activity_remote_datasource.dart';
import '../../features/activity/data/datasources/activity_remote_datasource_impl.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/get_activities_usecase.dart';
import '../../features/activity/domain/usecases/download_receipt_usecase.dart';
import '../../features/activity/presentation/cubit/activity_cubit.dart';
import '../network/places_service.dart';
import '../services/location_service.dart';
import '../services/location_permission_service.dart';
import '../services/location_permission_service_impl.dart';
import '../services/notification_permission_service.dart';
import '../services/notification_permission_service_impl.dart';
import '../services/booking_foreground_service.dart';
import '../services/booking_overlay_service.dart';
import '../services/fcm_service.dart';
import '../maps/map_style_loader.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  _registerCore();
  _registerAuth();
  _registerProfile();
  _registerSearch();
  _registerBooking();
  _registerNotifications();
  _registerPayment();
  _registerFeedback();
  _registerServices();
  _registerActivity();
}

void _registerCore() {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: getIt<Dio>(),
      tokenProvider: () async {
        if (!getIt.isRegistered<AuthLocalDataSource>()) return null;
        return getIt<AuthLocalDataSource>().getToken();
      },
    ),
  );
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton<PlacesService>(() => PlacesService());
  if (!getIt.isRegistered<MapStyleLoader>()) {
    getIt.registerLazySingleton<MapStyleLoader>(() => const MapStyleLoader());
  }
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<LocationPermissionService>(
    () => LocationPermissionServiceImpl(),
  );
  getIt.registerLazySingleton<NotificationPermissionService>(
    () => NotificationPermissionServiceImpl(),
  );
  getIt.registerLazySingleton<BookingForegroundService>(
    () => BookingForegroundServiceImpl(),
  );
  getIt.registerLazySingleton<BookingOverlayService>(
    () => BookingOverlayServiceImpl(),
  );
  getIt.registerLazySingleton<FcmService>(() => FcmService());
  getIt.registerLazySingleton<OnboardingStorage>(
    () => OnboardingStorage(getIt<SharedPreferences>()),
  );
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<OnboardingStorage>()),
  );
  getIt.registerLazySingleton<LocationPermissionStorage>(
    () => LocationPermissionStorage(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<LocationPermissionRepository>(
    () => LocationPermissionRepositoryImpl(
      storage: getIt<LocationPermissionStorage>(),
    ),
  );
  getIt.registerLazySingleton<GetLocationDenyCountUseCase>(
    () => GetLocationDenyCountUseCase(getIt<LocationPermissionRepository>()),
  );
  getIt.registerLazySingleton<IncrementLocationDenyCountUseCase>(
    () => IncrementLocationDenyCountUseCase(getIt<LocationPermissionRepository>()),
  );
  getIt.registerLazySingleton<ResetLocationDenyCountUseCase>(
    () => ResetLocationDenyCountUseCase(getIt<LocationPermissionRepository>()),
  );
  getIt.registerLazySingleton<BookingProgressStorage>(
    () => BookingProgressStorage(getIt<SharedPreferences>()),
  );
}

void _registerAuth() {
  if (!getIt.isRegistered<PhoneNumberService>()) {
    getIt.registerLazySingleton<PhoneNumberService>(
      () => PhoneNumberService(),
    );
  }
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SharedPreferences>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RequestOtpUseCase>(
    () => RequestOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<LoginUseCase>(),
      getIt<RequestOtpUseCase>(),
      getIt<ResendOtpUseCase>(),
    ),
  );
  getIt.registerFactory<AuthSessionCubit>(
    () => AuthSessionCubit(
      getIt<AuthRepository>(),
      profileLocalDataSource: getIt<ProfileLocalDataSource>(),
    ),
  );
  getIt.registerFactory<AuthOnboardingCubit>(
    () => AuthOnboardingCubit(getIt<OnboardingStorage>()),
  );
}

void _registerProfile() {
  if (!getIt.isRegistered<ProfileValidationService>()) {
    getIt.registerLazySingleton<ProfileValidationService>(
      () => ProfileValidationService(),
    );
  }
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
      localDataSource: getIt<ProfileLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<CreateProfileUseCase>(
    () => CreateProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<GetCachedProfileUseCase>(
    () => GetCachedProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getIt<CreateProfileUseCase>(),
      getIt<GetCachedProfileUseCase>(),
    ),
  );
}

void _registerSearch() {
  getIt.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(getIt<PlacesService>()),
  );
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt<PlacesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<SearchPlacesUseCase>(
    () => SearchPlacesUseCase(getIt<PlacesRepository>()),
  );
  getIt.registerLazySingleton<ReverseGeocodeUseCase>(
    () => ReverseGeocodeUseCase(getIt<PlacesRepository>()),
  );
  getIt.registerLazySingleton<GetPlaceDetailsUseCase>(
    () => GetPlaceDetailsUseCase(getIt<PlacesRepository>()),
  );
  getIt.registerFactory<PlacesBloc>(
    () => PlacesBloc(getIt<SearchPlacesUseCase>()),
  );
  getIt.registerFactory<RideSearchCubit>(
    () => RideSearchCubit(
      getIt<SearchPlacesUseCase>(),
      getIt<ReverseGeocodeUseCase>(),
      getIt<GetPlaceDetailsUseCase>(),
      getIt<LocationService>(),
      getIt<LocationPermissionService>(),
    ),
  );
}

void _registerBooking() {
  getIt.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DriverTrackingSocketDataSource>(
    () => DriverTrackingSocketDataSourceImpl(
      baseUrl: Env.baseUrl,
      tokenProvider: () async => getIt<AuthLocalDataSource>().getToken(),
    ),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: getIt<BookingRemoteDataSource>()),
  );
  getIt.registerLazySingleton<BookingProgressRepository>(
    () => BookingProgressRepositoryImpl(
      storage: getIt<BookingProgressStorage>(),
    ),
  );
  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(remoteDataSource: getIt<DriverRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DriverTrackingRepository>(
    () => DriverTrackingRepositoryImpl(
      socketDataSource: getIt<DriverTrackingSocketDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetBookingRouteUseCase>(
    () => GetBookingRouteUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<BookRideUseCase>(
    () => BookRideUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<GetBookingProgressUseCase>(
    () => GetBookingProgressUseCase(getIt<BookingProgressRepository>()),
  );
  getIt.registerLazySingleton<SaveBookingProgressUseCase>(
    () => SaveBookingProgressUseCase(getIt<BookingProgressRepository>()),
  );
  getIt.registerLazySingleton<ClearBookingProgressUseCase>(
    () => ClearBookingProgressUseCase(getIt<BookingProgressRepository>()),
  );
  getIt.registerLazySingleton<GetDriverInfoUseCase>(
    () => GetDriverInfoUseCase(getIt<DriverRepository>()),
  );
  getIt.registerLazySingleton<WatchDriverLocationUseCase>(
    () => WatchDriverLocationUseCase(getIt<DriverTrackingRepository>()),
  );
  getIt.registerLazySingleton<FareCalculator>(() => const FareCalculator());
  getIt.registerLazySingleton<DriverArrivalEstimator>(
    () => const DriverArrivalEstimator(),
  );
  getIt.registerLazySingleton<DriverTrackingService>(
    () => const DriverTrackingService(),
  );
  getIt.registerFactory<BookingProgressController>(
    () => BookingProgressController(
      getProgress: getIt<GetBookingProgressUseCase>(),
      saveProgress: getIt<SaveBookingProgressUseCase>(),
      clearProgress: getIt<ClearBookingProgressUseCase>(),
    ),
  );
  getIt.registerFactory<BookingBackgroundCoordinator>(
    () => BookingBackgroundCoordinator(
      foregroundService: getIt<BookingForegroundService>(),
      overlayService: getIt<BookingOverlayService>(),
    ),
  );
  getIt.registerFactory<BookingFlowCoordinator>(
    () => BookingFlowCoordinator(
      backgroundCoordinator: getIt<BookingBackgroundCoordinator>(),
      notificationsCubit: getIt<NotificationsCubit>(),
    ),
  );
}

void _registerNotifications() {
  getIt.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      localDataSource: getIt<NotificationsLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<InitNotificationsUseCase>(
    () => InitNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowDriverAcceptedUseCase>(
    () => ShowDriverAcceptedUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowDriverArrivingUseCase>(
    () => ShowDriverArrivingUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowDriverArrivedUseCase>(
    () => ShowDriverArrivedUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowRideStartedUseCase>(
    () => ShowRideStartedUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowRideCompletedUseCase>(
    () => ShowRideCompletedUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<ShowRideProgressUseCase>(
    () => ShowRideProgressUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      initNotificationsUseCase: getIt<InitNotificationsUseCase>(),
      showDriverAcceptedUseCase: getIt<ShowDriverAcceptedUseCase>(),
      showDriverArrivingUseCase: getIt<ShowDriverArrivingUseCase>(),
      showDriverArrivedUseCase: getIt<ShowDriverArrivedUseCase>(),
      showRideStartedUseCase: getIt<ShowRideStartedUseCase>(),
      showRideCompletedUseCase: getIt<ShowRideCompletedUseCase>(),
      showRideProgressUseCase: getIt<ShowRideProgressUseCase>(),
    ),
  );
}

void _registerPayment() {
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: getIt<PaymentRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetPaymentOptionsUseCase>(
    () => GetPaymentOptionsUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<SubmitPaymentUseCase>(
    () => SubmitPaymentUseCase(getIt<PaymentRepository>()),
  );
}

void _registerFeedback() {
  getIt.registerLazySingleton<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepositoryImpl(remoteDataSource: getIt<FeedbackRemoteDataSource>()),
  );
  getIt.registerLazySingleton<SubmitFeedbackUseCase>(
    () => SubmitFeedbackUseCase(getIt<FeedbackRepository>()),
  );
}

void _registerServices() {
  getIt.registerLazySingleton<ServicesRemoteDataSource>(
    () => ServicesRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(remoteDataSource: getIt<ServicesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetServicesUseCase>(
    () => GetServicesUseCase(getIt<ServicesRepository>()),
  );
  getIt.registerFactory<ServicesCubit>(
    () => ServicesCubit(getIt<GetServicesUseCase>()),
  );
}

void _registerActivity() {
  getIt.registerLazySingleton<ActivityRemoteDataSource>(
    () => ActivityRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(remoteDataSource: getIt<ActivityRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetActivitiesUseCase>(
    () => GetActivitiesUseCase(getIt<ActivityRepository>()),
  );
  getIt.registerLazySingleton<DownloadReceiptUseCase>(
    () => DownloadReceiptUseCase(getIt<ActivityRepository>()),
  );
  getIt.registerFactory<ActivityCubit>(
    () => ActivityCubit(),
  );
}
