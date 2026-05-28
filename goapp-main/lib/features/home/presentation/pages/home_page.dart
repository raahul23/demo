import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/vehicle_marker_controller.dart';
import 'package:goapp/core/maps/map_style_loader.dart';

import '../../../auth/presentation/cubit/auth_session_cubit.dart';
import '../../../../core/onboarding/onboarding_cubit.dart';
import '../../../search/presentation/pages/ride_search_page.dart';
import '../../../search/presentation/cubit/ride_search_cubit.dart';
import '../../../booking/domain/entities/booking_service.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../../services/presentation/pages/services_page.dart';
import '../../../services/presentation/utils/service_icon_mapper.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/pages/activity_page.dart';
import '../../../profile/presentation/pages/account_page.dart';
import '../../../activity/presentation/widgets/appbar.dart';
import '../cubit/home_location_cubit.dart';
import '../cubit/home_location_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final HomeLocationCubit _homeLocationCubit;
  late final ServicesCubit _servicesCubit;
  late final ActivityCubit _activityCubit;

  @override
  void initState() {
    super.initState();
    final isTest = const bool.fromEnvironment('FLUTTER_TEST');
    _homeLocationCubit = HomeLocationCubit(autoStart: !isTest);
    _servicesCubit = getIt<ServicesCubit>()..load();
    _activityCubit = getIt<ActivityCubit>();
  }

  @override
  void dispose() {
    _homeLocationCubit.close();
    _servicesCubit.close();
    _activityCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _homeLocationCubit),
          BlocProvider.value(value: _servicesCubit),
          BlocProvider.value(value: _activityCubit),
        ],
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _HomeTabPage(),
            ServicesPage(),
            ActivityPage(),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _HomeMapBody extends StatefulWidget {
  const _HomeMapBody();

  @override
  State<_HomeMapBody> createState() => _HomeMapBodyState();
}

class _HomeMapBodyState extends State<_HomeMapBody>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  final bool _isTest = const bool.fromEnvironment('FLUTTER_TEST');
  String? _mapStyle;
  LatLng? _pendingCameraTarget;
  bool _pendingCameraZoom = false;
  bool _showingLocationDialog = false;
  late final VehicleMarkerController _vehicleController =
      VehicleMarkerController(
        onUpdate: () {
          if (mounted) setState(() {});
        },
        animate: !_isTest,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_isTest) {
      context.read<HomeLocationCubit>().init();
    }
    _loadMapStyle();
    _loadVehicleIcons();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _vehicleController.handleLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      context.read<HomeLocationCubit>().retryIfPending();
    }
  }

  Future<void> _loadMapStyle() async {
    final style = await getIt<MapStyleLoader>().loadDefault();
    if (!mounted) return;
    setState(() => _mapStyle = style);
  }

  Future<void> _loadVehicleIcons() async {
    await _vehicleController.loadBikeIcon();
  }

  void _updateVehicles(LatLng center) {
    final previous = _vehicleController.center;
    final bool changed = previous == null ||
        (previous.latitude - center.latitude).abs() > 0.00001 ||
        (previous.longitude - center.longitude).abs() > 0.00001;
    if (changed) {
      _vehicleController.start(center);
    }
  }

  void _centerOnUser(LatLng target, {bool withZoom = false}) {
    if (_mapController == null) {
      _pendingCameraTarget = target;
      _pendingCameraZoom = withZoom;
      return;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(target, 17),
    );
  }

  Future<void> _showLocationDialog({
    required HomeLocationPromptType type,
  }) async {
    if (_showingLocationDialog) return;
    _showingLocationDialog = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Please allow location'),
        content: Text(
          type == HomeLocationPromptType.service
              ? 'Enable location services to use current location.'
              : 'Enable location permission to use current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    _showingLocationDialog = false;
    if (!mounted) return;
    if (result == true) {
      final cubit = context.read<HomeLocationCubit>();
      await cubit.openSettings(type);
    }
  }

  static const double _suggestionHeight = 120;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeLocationCubit, HomeLocationState>(
      listenWhen: (previous, current) =>
          previous.promptId != current.promptId &&
          current.promptType != null,
      listener: (context, state) {
        if (state.promptType != null) {
          _showLocationDialog(type: state.promptType!);
        }
      },
      child: BlocListener<HomeLocationCubit, HomeLocationState>(
        listenWhen: (previous, current) =>
            previous.current != current.current ||
            previous.locationDenied != current.locationDenied,
        listener: (context, state) {
          if (state.locationDenied) {
            _vehicleController.stop();
            return;
          }
          final target = state.current;
          if (target != null) {
            _updateVehicles(target);
            _centerOnUser(target, withZoom: true);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: _isTest
                  ? const Center(child: Text('Map disabled in tests'))
                  : AppGoogleMap(
                      isTestOverride: _isTest,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(20.5937, 78.9629),
                        zoom: 4,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      style: _mapStyle,
                      markers: _vehicleController.markers,
                      padding: const EdgeInsets.only(
                        bottom: _suggestionHeight + 24,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (_pendingCameraTarget != null) {
                          final target = _pendingCameraTarget!;
                          final zoom = _pendingCameraZoom;
                          _pendingCameraTarget = null;
                          _pendingCameraZoom = false;
                          _centerOnUser(target, withZoom: zoom);
                        }
                      },
                    ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => getIt<RideSearchCubit>(),
                          child: const RideSearchPage(),
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Where to?',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: _suggestionHeight + 16,
              child: BlocBuilder<HomeLocationCubit, HomeLocationState>(
                builder: (context, state) {
                  return FloatingActionButton(
                    mini: true,
                    heroTag: 'current_location',
                    onPressed: () async {
                      if (state.current != null) {
                        _centerOnUser(state.current!, withZoom: true);
                        return;
                      }
                      final cubit = context.read<HomeLocationCubit>();
                      await cubit.requestCurrentLocation();
                    },
                    child: const Icon(Icons.my_location),
                  );
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BlocBuilder<ServicesCubit, ServicesState>(
                    builder: (context, state) {
                      final featured = state.items
                          .where((item) =>
                              item.bookingService != null && item.featured)
                          .toList();
                      final allBookables = state.items
                          .where((item) => item.bookingService != null)
                          .toList();
                      final displayItems =
                          featured.isNotEmpty ? featured : allBookables;
                      if (displayItems.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final tiles = displayItems.take(3).toList();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tiles
                            .map(
                              (item) => _ServiceTile(
                                icon:
                                    ServiceIconMapper.fromKey(item.iconKey),
                                label: item.name,
                                onTap: () => _openRideSearch(
                                  context,
                                  item.bookingService ?? BookingService.bike,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRideSearch(BuildContext context, BookingService service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<RideSearchCubit>(),
          child: RideSearchPage(initialService: service),
        ),
      ),
    );
  }
}

class _HomeTabPage extends StatelessWidget {
  const _HomeTabPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'GoApp Home',
        showBack: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<OnboardingCubit>().clear();
              context.read<AuthSessionCubit>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const _HomeMapBody(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const AccountPage();
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
