import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/network/api_client.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/features/booking/data/datasources/driver_remote_datasource.dart';
import 'package:goapp/features/booking/data/datasources/driver_remote_datasource_impl.dart';
import 'package:goapp/features/booking/data/datasources/driver_tracking_socket_datasource.dart';
import 'package:goapp/features/booking/data/datasources/driver_tracking_socket_datasource_impl.dart';
import 'package:goapp/features/booking/data/repositories/driver_repository_impl.dart';
import 'package:goapp/features/booking/data/repositories/driver_tracking_repository_impl.dart';
import 'package:goapp/features/booking/domain/repositories/driver_repository.dart';
import 'package:goapp/features/booking/domain/repositories/driver_tracking_repository.dart';
import 'package:goapp/features/booking/domain/services/driver_arrival_estimator.dart';
import 'package:goapp/features/booking/domain/usecases/get_driver_info_usecase.dart';
import 'package:goapp/features/booking/domain/usecases/watch_driver_location_usecase.dart';
import 'package:goapp/features/booking/domain/services/driver_tracking_service.dart';
import 'package:goapp/core/services/notification_permission_service.dart';
import 'package:goapp/features/auth/domain/services/phone_number_service.dart';
import 'package:goapp/features/profile/domain/services/profile_validation_service.dart';
import 'package:goapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:goapp/features/profile/data/datasources/profile_local_datasource_impl.dart';

import 'package:goapp/features/location/data/datasources/location_permission_storage.dart';
import 'package:goapp/features/location/data/repositories/location_permission_repository_impl.dart';
import 'package:goapp/features/location/domain/repositories/location_permission_repository.dart';
import 'package:goapp/features/location/domain/usecases/get_location_deny_count_usecase.dart';
import 'package:goapp/features/location/domain/usecases/increment_location_deny_count_usecase.dart';
import 'package:goapp/features/location/domain/usecases/reset_location_deny_count_usecase.dart';
import 'package:goapp/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:goapp/features/booking/data/datasources/booking_remote_datasource_impl.dart';
import 'package:goapp/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:goapp/features/booking/domain/repositories/booking_repository.dart';
import 'package:goapp/features/booking/domain/usecases/get_booking_route_usecase.dart';
import 'package:goapp/features/booking/domain/services/fare_calculator.dart';
import 'package:goapp/features/booking/data/datasources/booking_progress_storage.dart';
import 'package:goapp/features/booking/data/repositories/booking_progress_repository_impl.dart';
import 'package:goapp/features/booking/domain/repositories/booking_progress_repository.dart';
import 'package:goapp/features/booking/domain/usecases/get_booking_progress_usecase.dart';
import 'package:goapp/features/booking/domain/usecases/save_booking_progress_usecase.dart';
import 'package:goapp/features/booking/domain/usecases/clear_booking_progress_usecase.dart';
import 'package:goapp/features/booking/presentation/booking_progress_controller.dart';
import 'package:goapp/features/booking/presentation/booking_flow_coordinator.dart';
import 'package:goapp/features/booking/presentation/booking_background_coordinator.dart';
import 'package:goapp/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:goapp/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:goapp/features/notifications/domain/entities/notification_progress.dart';
import 'package:goapp/features/notifications/domain/repositories/notification_repository.dart';
import 'package:goapp/features/notifications/domain/usecases/init_notifications_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_accepted_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_arrived_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_arriving_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_completed_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_progress_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_started_usecase.dart';
import 'package:goapp/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:goapp/core/services/booking_foreground_service.dart';
import 'package:goapp/core/services/booking_overlay_service.dart';
import 'package:goapp/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:goapp/features/payment/data/datasources/payment_remote_datasource_impl.dart';
import 'package:goapp/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:goapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:goapp/features/payment/domain/usecases/get_payment_options_usecase.dart';
import 'package:goapp/features/payment/domain/usecases/submit_payment_usecase.dart';
import 'package:goapp/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:goapp/features/feedback/data/datasources/feedback_remote_datasource_impl.dart';
import 'package:goapp/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:goapp/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:goapp/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:goapp/features/services/data/datasources/services_remote_datasource.dart';
import 'package:goapp/features/services/data/datasources/services_remote_datasource_impl.dart';
import 'package:goapp/features/services/data/repositories/services_repository_impl.dart';
import 'package:goapp/features/services/domain/repositories/services_repository.dart';
import 'package:goapp/features/services/domain/usecases/get_services_usecase.dart';
import 'package:goapp/features/services/presentation/cubit/services_cubit.dart';
import 'package:goapp/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:goapp/features/activity/data/datasources/activity_remote_datasource_impl.dart';
import 'package:goapp/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:goapp/features/activity/domain/repositories/activity_repository.dart';
import 'package:goapp/features/activity/domain/usecases/get_activities_usecase.dart';
import 'package:goapp/features/activity/domain/usecases/download_receipt_usecase.dart';
import 'package:goapp/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestNotificationPermissionService
    implements NotificationPermissionService {
  @override
  Future<NotificationPermissionStatus> check() async {
    return NotificationPermissionStatus.granted;
  }

  @override
  Future<bool> openSettings() async {
    return true;
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    return NotificationPermissionStatus.granted;
  }
}

class _TestNotificationsLocalDataSource implements NotificationsLocalDataSource {
  @override
  Future<void> init() async {}

  @override
  Future<void> showDriverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) async {}

  @override
  Future<void> showDriverArrived() async {}

  @override
  Future<void> showDriverArriving({
    required NotificationProgress progress,
  }) async {}

  @override
  Future<void> showRideProgress({
    required NotificationProgress progress,
  }) async {}

  @override
  Future<void> showRideStarted({required String dropLabel}) async {}

  @override
  Future<void> showRideCompleted({required String dropLabel}) async {}
}

class _TestBookingForegroundService implements BookingForegroundService {
  bool running = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> isRunning() async => running;

  @override
  Future<void> start() async {
    running = true;
  }

  @override
  Future<void> stop() async {
    running = false;
  }
}

class _TestBookingOverlayService implements BookingOverlayService {
  bool active = false;

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> hide() async {
    active = false;
  }

  @override
  Future<bool> isActive() async => active;

  @override
  Future<void> show() async {
    active = true;
  }
}

/// Creates an ApiClient that always fails immediately — tests use fallback paths.
ApiClient _testApiClient() {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) => handler.reject(
      DioException(requestOptions: options, type: DioExceptionType.connectionError),
    ),
  ));
  return ApiClient(dio: dio);
}

Future<void> testExecutable(Future<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  getIt.allowReassignment = true;
  if (!getIt.isRegistered<MapStyleLoader>()) {
    getIt.registerLazySingleton<MapStyleLoader>(() => const MapStyleLoader());
  }
  if (!getIt.isRegistered<DriverRemoteDataSource>()) {
    getIt.registerLazySingleton<DriverRemoteDataSource>(
      () => DriverRemoteDataSourceImpl(_testApiClient()),
    );
  }
  if (!getIt.isRegistered<DriverRepository>()) {
    getIt.registerLazySingleton<DriverRepository>(
      () => DriverRepositoryImpl(
        remoteDataSource: getIt<DriverRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<DriverTrackingSocketDataSource>()) {
    getIt.registerLazySingleton<DriverTrackingSocketDataSource>(
      () => DriverTrackingSocketDataSourceImpl(
        baseUrl: 'http://localhost:3000',
        tokenProvider: () async => null,
      ),
    );
  }
  if (!getIt.isRegistered<DriverTrackingRepository>()) {
    getIt.registerLazySingleton<DriverTrackingRepository>(
      () => DriverTrackingRepositoryImpl(
        socketDataSource: getIt<DriverTrackingSocketDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetDriverInfoUseCase>()) {
    getIt.registerLazySingleton<GetDriverInfoUseCase>(
      () => GetDriverInfoUseCase(getIt<DriverRepository>()),
    );
  }
  if (!getIt.isRegistered<WatchDriverLocationUseCase>()) {
    getIt.registerLazySingleton<WatchDriverLocationUseCase>(
      () => WatchDriverLocationUseCase(getIt<DriverTrackingRepository>()),
    );
  }
  if (!getIt.isRegistered<DriverArrivalEstimator>()) {
    getIt.registerLazySingleton<DriverArrivalEstimator>(
      () => const DriverArrivalEstimator(),
    );
  }
  if (!getIt.isRegistered<DriverTrackingService>()) {
    getIt.registerLazySingleton<DriverTrackingService>(
      () => const DriverTrackingService(
        interval: Duration(milliseconds: 10),
        steps: 2,
      ),
    );
  }
  if (!getIt.isRegistered<BookingRemoteDataSource>()) {
    getIt.registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(apiClient: _testApiClient()),
    );
  }
  if (!getIt.isRegistered<BookingRepository>()) {
    getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(
        remoteDataSource: getIt<BookingRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetBookingRouteUseCase>()) {
    getIt.registerLazySingleton<GetBookingRouteUseCase>(
      () => GetBookingRouteUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<FareCalculator>()) {
    getIt.registerLazySingleton<FareCalculator>(
      () => const FareCalculator(),
    );
  }
  if (!getIt.isRegistered<BookingProgressStorage>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<BookingProgressStorage>(
      () => BookingProgressStorage(prefs),
    );
  }
  if (!getIt.isRegistered<LocationPermissionStorage>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<LocationPermissionStorage>(
      () => LocationPermissionStorage(prefs),
    );
  }
  if (!getIt.isRegistered<NotificationPermissionService>()) {
    getIt.registerLazySingleton<NotificationPermissionService>(
      () => _TestNotificationPermissionService(),
    );
  }
  if (!getIt.isRegistered<PhoneNumberService>()) {
    getIt.registerLazySingleton<PhoneNumberService>(
      () => PhoneNumberService(),
    );
  }
  if (!getIt.isRegistered<ProfileValidationService>()) {
    getIt.registerLazySingleton<ProfileValidationService>(
      () => ProfileValidationService(),
    );
  }
  if (!getIt.isRegistered<ProfileLocalDataSource>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(prefs),
    );
  }
  if (!getIt.isRegistered<LocationPermissionRepository>()) {
    getIt.registerLazySingleton<LocationPermissionRepository>(
      () => LocationPermissionRepositoryImpl(
        storage: getIt<LocationPermissionStorage>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetLocationDenyCountUseCase>()) {
    getIt.registerLazySingleton<GetLocationDenyCountUseCase>(
      () => GetLocationDenyCountUseCase(
        getIt<LocationPermissionRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<IncrementLocationDenyCountUseCase>()) {
    getIt.registerLazySingleton<IncrementLocationDenyCountUseCase>(
      () => IncrementLocationDenyCountUseCase(
        getIt<LocationPermissionRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<ResetLocationDenyCountUseCase>()) {
    getIt.registerLazySingleton<ResetLocationDenyCountUseCase>(
      () => ResetLocationDenyCountUseCase(
        getIt<LocationPermissionRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<NotificationsLocalDataSource>()) {
    getIt.registerLazySingleton<NotificationsLocalDataSource>(
      () => _TestNotificationsLocalDataSource(),
    );
  }
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        localDataSource: getIt<NotificationsLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<InitNotificationsUseCase>()) {
    getIt.registerLazySingleton<InitNotificationsUseCase>(
      () => InitNotificationsUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowDriverAcceptedUseCase>()) {
    getIt.registerLazySingleton<ShowDriverAcceptedUseCase>(
      () => ShowDriverAcceptedUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowDriverArrivingUseCase>()) {
    getIt.registerLazySingleton<ShowDriverArrivingUseCase>(
      () => ShowDriverArrivingUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowDriverArrivedUseCase>()) {
    getIt.registerLazySingleton<ShowDriverArrivedUseCase>(
      () => ShowDriverArrivedUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowRideStartedUseCase>()) {
    getIt.registerLazySingleton<ShowRideStartedUseCase>(
      () => ShowRideStartedUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowRideCompletedUseCase>()) {
    getIt.registerLazySingleton<ShowRideCompletedUseCase>(
      () => ShowRideCompletedUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<ShowRideProgressUseCase>()) {
    getIt.registerLazySingleton<ShowRideProgressUseCase>(
      () => ShowRideProgressUseCase(getIt<NotificationRepository>()),
    );
  }
  if (!getIt.isRegistered<PaymentRemoteDataSource>()) {
    getIt.registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(_testApiClient()),
    );
  }
  if (!getIt.isRegistered<PaymentRepository>()) {
    getIt.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(
        remoteDataSource: getIt<PaymentRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetPaymentOptionsUseCase>()) {
    getIt.registerLazySingleton<GetPaymentOptionsUseCase>(
      () => GetPaymentOptionsUseCase(getIt<PaymentRepository>()),
    );
  }
  if (!getIt.isRegistered<SubmitPaymentUseCase>()) {
    getIt.registerLazySingleton<SubmitPaymentUseCase>(
      () => SubmitPaymentUseCase(getIt<PaymentRepository>()),
    );
  }
  if (!getIt.isRegistered<FeedbackRemoteDataSource>()) {
    getIt.registerLazySingleton<FeedbackRemoteDataSource>(
      () => FeedbackRemoteDataSourceImpl(_testApiClient()),
    );
  }
  if (!getIt.isRegistered<FeedbackRepository>()) {
    getIt.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepositoryImpl(
        remoteDataSource: getIt<FeedbackRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<SubmitFeedbackUseCase>()) {
    getIt.registerLazySingleton<SubmitFeedbackUseCase>(
      () => SubmitFeedbackUseCase(getIt<FeedbackRepository>()),
    );
  }
  if (!getIt.isRegistered<ServicesRemoteDataSource>()) {
    getIt.registerLazySingleton<ServicesRemoteDataSource>(
      () => ServicesRemoteDataSourceImpl(_testApiClient()),
    );
  }
  if (!getIt.isRegistered<ServicesRepository>()) {
    getIt.registerLazySingleton<ServicesRepository>(
      () => ServicesRepositoryImpl(
        remoteDataSource: getIt<ServicesRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetServicesUseCase>()) {
    getIt.registerLazySingleton<GetServicesUseCase>(
      () => GetServicesUseCase(getIt<ServicesRepository>()),
    );
  }
  if (!getIt.isRegistered<ServicesCubit>()) {
    getIt.registerFactory<ServicesCubit>(
      () => ServicesCubit(getIt<GetServicesUseCase>()),
    );
  }
  if (!getIt.isRegistered<ActivityRemoteDataSource>()) {
    getIt.registerLazySingleton<ActivityRemoteDataSource>(
      () => ActivityRemoteDataSourceImpl(_testApiClient()),
    );
  }
  if (!getIt.isRegistered<ActivityRepository>()) {
    getIt.registerLazySingleton<ActivityRepository>(
      () => ActivityRepositoryImpl(
        remoteDataSource: getIt<ActivityRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetActivitiesUseCase>()) {
    getIt.registerLazySingleton<GetActivitiesUseCase>(
      () => GetActivitiesUseCase(getIt<ActivityRepository>()),
    );
  }
  if (!getIt.isRegistered<DownloadReceiptUseCase>()) {
    getIt.registerLazySingleton<DownloadReceiptUseCase>(
      () => DownloadReceiptUseCase(getIt<ActivityRepository>()),
    );
  }
  if (!getIt.isRegistered<ActivityCubit>()) {
    getIt.registerFactory<ActivityCubit>(
      () => ActivityCubit(),
    );
  }
  if (!getIt.isRegistered<NotificationsCubit>()) {
    getIt.registerFactory<NotificationsCubit>(
      () => NotificationsCubit(
        initNotificationsUseCase: getIt<InitNotificationsUseCase>(),
        showDriverAcceptedUseCase: getIt<ShowDriverAcceptedUseCase>(),
        showDriverArrivingUseCase: getIt<ShowDriverArrivingUseCase>(),
        showDriverArrivedUseCase: getIt<ShowDriverArrivedUseCase>(),
        showRideStartedUseCase: getIt<ShowRideStartedUseCase>(),
        showRideCompletedUseCase: getIt<ShowRideCompletedUseCase>(),
        showRideProgressUseCase: getIt<ShowRideProgressUseCase>(),
        minUpdateInterval: const Duration(milliseconds: 10),
        minPercentStep: 1,
      ),
    );
  }
  if (!getIt.isRegistered<BookingForegroundService>()) {
    getIt.registerLazySingleton<BookingForegroundService>(
      () => _TestBookingForegroundService(),
    );
  }
  if (!getIt.isRegistered<BookingOverlayService>()) {
    getIt.registerLazySingleton<BookingOverlayService>(
      () => _TestBookingOverlayService(),
    );
  }
  if (!getIt.isRegistered<BookingProgressRepository>()) {
    getIt.registerLazySingleton<BookingProgressRepository>(
      () => BookingProgressRepositoryImpl(
        storage: getIt<BookingProgressStorage>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetBookingProgressUseCase>()) {
    getIt.registerLazySingleton<GetBookingProgressUseCase>(
      () => GetBookingProgressUseCase(getIt<BookingProgressRepository>()),
    );
  }
  if (!getIt.isRegistered<SaveBookingProgressUseCase>()) {
    getIt.registerLazySingleton<SaveBookingProgressUseCase>(
      () => SaveBookingProgressUseCase(getIt<BookingProgressRepository>()),
    );
  }
  if (!getIt.isRegistered<ClearBookingProgressUseCase>()) {
    getIt.registerLazySingleton<ClearBookingProgressUseCase>(
      () => ClearBookingProgressUseCase(getIt<BookingProgressRepository>()),
    );
  }
  if (!getIt.isRegistered<BookingProgressController>()) {
    getIt.registerFactory<BookingProgressController>(
      () => BookingProgressController(
        getProgress: getIt<GetBookingProgressUseCase>(),
        saveProgress: getIt<SaveBookingProgressUseCase>(),
        clearProgress: getIt<ClearBookingProgressUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<BookingBackgroundCoordinator>()) {
    getIt.registerFactory<BookingBackgroundCoordinator>(
      () => BookingBackgroundCoordinator(
        foregroundService: getIt<BookingForegroundService>(),
        overlayService: getIt<BookingOverlayService>(),
      ),
    );
  }
  if (!getIt.isRegistered<BookingFlowCoordinator>()) {
    getIt.registerFactory<BookingFlowCoordinator>(
      () => BookingFlowCoordinator(
        backgroundCoordinator: getIt<BookingBackgroundCoordinator>(),
        notificationsCubit: getIt<NotificationsCubit>(),
      ),
    );
  }
  await testMain();
}
