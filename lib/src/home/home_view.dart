import 'dart:io';

import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/service/model/heart_rate_model.dart';
import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/provider/devices_provider.dart';
import 'package:awaku/service/provider/fasting_provider.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/stop_watch_service.dart';
import 'package:awaku/src/bike/bike_view.dart';
import 'package:awaku/utils/extensions.dart';
import 'package:awaku/utils/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:logger/logger.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  static const routeName = '/';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with TickerProviderStateMixin {
  final _watch = WatchConnectivity();
  var _paired = false;
  final _log = <HeartRateModel>[];
  late TextEditingController weight;
  late TabController _tabController;

  final List<Tab> _tabs = [
    const Tab(text: 'Overview'),
    const Tab(text: 'Health'),
    const Tab(text: 'Activity'),
    const Tab(text: 'Wellness'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _watch.contextStream.listen((e) {
      if (mounted) {
        setState(() => _log.add(HeartRateModel.fromJson(e)));
        // Add haptic feedback for iOS
        if (Platform.isIOS) {
          HapticFeedback.lightImpact();
        }
      }
    });
    initPlatformState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(fetchUserProvider);
    final profile = profileAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (error, stack) => null,
    );
    final healthData = ref.watch(healthNotifierProvider);
    final devices = ref.watch(getDevicesProvider);
    final waterAsync = ref.watch(currentHydrationProvider);
    print('🔍 UI: WaterAsync state: ${waterAsync.runtimeType}');
    final water = waterAsync.when(
      data: (data) {
        print('🔍 UI: WaterAsync data: $data');
        return data;
      },
      loading: () {
        print('🔍 UI: WaterAsync loading');
        return null;
      },
      error: (error, stack) {
        print('🔍 UI: WaterAsync error: $error');
        return null;
      },
    );
    print('🔍 UI: Final water value: $water');
    final start = ref.watch(startFastingProvider);
    final fasting = ref.watch(selectedFastingProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              profile?.name ?? 'User',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => context.push('/setting'),
              icon: Icon(
                Icons.person_outline_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Platform.isIOS
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () async {
                          HapticFeedback.mediumImpact();
                          ref.invalidate(getDevicesProvider);
                          ref.invalidate(healthNotifierProvider);
                          await ref.read(fetchUserProvider.future);
                        },
                      ),
                      SliverFillRemaining(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildOverviewTab(context, profile, devices, water,
                                start != null, fasting, colorScheme),
                            _buildHealthTab(
                                context, profile, healthData, colorScheme),
                            _buildActivityTab(context, devices, colorScheme),
                            _buildWellnessTab(context, profile, water,
                                start != null, fasting, colorScheme),
                          ],
                        ),
                      ),
                    ],
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      ref.invalidate(getDevicesProvider);
                      ref.invalidate(healthNotifierProvider);
                      return ref.read(fetchUserProvider.future);
                    },
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Overview Tab
                        _buildOverviewTab(context, profile, devices, water,
                            start != null, fasting, colorScheme),
                        // Health Tab
                        _buildHealthTab(
                            context, profile, healthData, colorScheme),
                        // Activity Tab
                        _buildActivityTab(context, devices, colorScheme),
                        // Wellness Tab
                        _buildWellnessTab(context, profile, water,
                            start != null, fasting, colorScheme),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsSection(
      BuildContext context, ProfileModel? profile, ColorScheme colorScheme) {
    final metrics = <Widget>[
      if (_paired)
        _buildMetricCard(
          context,
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFE53E3E),
          value: _log.isEmpty ? '-' : '${_log.last.heartRate}',
          unit: 'BPM',
          label: 'Heart Rate',
          colorScheme: colorScheme,
        ),
      GestureDetector(
        onTap: () {
          if (Platform.isIOS) {
            HapticFeedback.selectionClick();
          }
          weight = TextEditingController(text: '${profile?.weight ?? 0.0}');
          _showWeightDialog(context, profile);
        },
        child: _buildMetricCard(
          context,
          icon: Icons.monitor_weight_rounded,
          iconColor: const Color(0xFF38A169),
          value: '${profile?.weight ?? '0'}',
          unit: 'KG',
          label: 'Weight',
          colorScheme: colorScheme,
        ),
      ),
      _buildMetricCard(
        context,
        icon: calculateBodyMassIndex(
                    profile?.weight ?? 0.0, profile?.height ?? 0) >=
                25
            ? Icons.trending_up_rounded
            : Icons.trending_flat_rounded,
        iconColor: calculateBodyMassIndex(
                    profile?.weight ?? 0.0, profile?.height ?? 0) >=
                25
            ? const Color(0xFFE53E3E)
            : const Color(0xFF38A169),
        value:
            calculateBodyMassIndex(profile?.weight ?? 0.0, profile?.height ?? 0)
                .toStringAsFixed(1),
        unit: 'BMI',
        label: 'Body Mass Index',
        colorScheme: colorScheme,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(24)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(20)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing(8)),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius(12)),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: context.responsiveIconSize(20),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(12)),
              Text(
                'Health Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize:
                          (Theme.of(context).textTheme.titleLarge?.fontSize ??
                                  22) *
                              context.fontSizeMultiplier,
                    ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(24)),
          // Responsive grid layout
          context.isMobile
              ? Column(
                  children: [
                    if (metrics.isNotEmpty) metrics[0],
                    if (metrics.length > 1) ...[
                      SizedBox(height: context.responsiveSpacing(16)),
                      Row(
                        children: [
                          Expanded(child: metrics[1]),
                          if (metrics.length > 2) ...[
                            SizedBox(width: context.responsiveSpacing(16)),
                            Expanded(child: metrics[2]),
                          ],
                        ],
                      ),
                    ],
                  ],
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: context.gridColumns,
                  crossAxisSpacing: context.responsiveSpacing(16),
                  mainAxisSpacing: context.responsiveSpacing(16),
                  childAspectRatio: context.isTablet ? 1.1 : 1.0,
                  children: metrics,
                ),
          SizedBox(height: context.responsiveSpacing(24)),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/setting/add-device'),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Device',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(context.responsiveSpacing(20)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(Platform.isIOS
            ? context.responsiveBorderRadius(16)
            : context.responsiveBorderRadius()),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: Platform.isIOS ? 0.5 : 1,
        ),
        boxShadow: Platform.isIOS
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: -1,
                ),
              ]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveSpacing(8)),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(context.responsiveBorderRadius(12)),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: context.responsiveIconSize(20),
            ),
          ),
          SizedBox(height: context.responsiveSpacing(12)),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontSize:
                      (Theme.of(context).textTheme.headlineSmall?.fontSize ??
                              24) *
                          context.fontSizeMultiplier,
                ),
          ),
          SizedBox(height: context.responsiveSpacing(2)),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize:
                      (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) *
                          context.fontSizeMultiplier,
                ),
          ),
          SizedBox(height: context.responsiveSpacing(8)),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontSize:
                      (Theme.of(context).textTheme.labelSmall?.fontSize ?? 10) *
                          context.fontSizeMultiplier,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesSection(AsyncValue devices, ColorScheme colorScheme) {
    return devices.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox();
        return Container(
          padding: EdgeInsets.all(context.responsiveSpacing(24)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius:
                BorderRadius.circular(context.responsiveBorderRadius(20)),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.devices_rounded,
                      color: colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Connected Devices',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (c, index) {
                  BluetoothDevice b = data[index];
                  return FutureBuilder<bool>(
                    future: FTMS.isBluetoothDeviceFTMSDevice(b),
                    builder: (context, snapshot) => (snapshot.data ?? false)
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BikeView(ftmsDevice: b),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bluetooth_connected_rounded,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.platformName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'FTMS Device',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  );
                },
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading devices: $error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildHydrationSection(BuildContext context, ProfileModel? profile,
      int? water, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(24)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(20)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing(8)),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius(12)),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: const Color(0xFF3B82F6),
                  size: context.responsiveIconSize(20),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(12)),
              Text(
                'Hydration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize:
                          (Theme.of(context).textTheme.titleLarge?.fontSize ??
                                  22) *
                              context.fontSizeMultiplier,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: context.responsiveSpacing(100),
                height: context.responsiveSpacing(100),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius(20)),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: (water ?? 0) / 100,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                        strokeWidth: 6.0,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(water ?? 0).round()}%",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.fontSize ??
                                            22) *
                                        context.fontSizeMultiplier,
                                  ),
                        ),
                        Text(
                          'Complete',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.fontSize ??
                                            11) *
                                        context.fontSizeMultiplier,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.responsiveSpacing(20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Hydration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize ??
                                    16) *
                                context.fontSizeMultiplier,
                          ),
                    ),
                    SizedBox(height: context.responsiveSpacing(8)),
                    Text(
                      'Target: ${totalWater(profile?.weight).toStringAsFixed(1)} L/day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.fontSize ??
                                    14) *
                                context.fontSizeMultiplier,
                          ),
                    ),
                    SizedBox(height: context.responsiveSpacing(16)),
                    Container(
                      width: double.infinity,
                      height: context.responsiveSpacing(48),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            context.responsiveBorderRadius(14)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: addWater,
                          borderRadius: BorderRadius.circular(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Water',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastingSection(BuildContext context, bool start,
      FastingModel? fasting, ProfileModel? profile, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Intermittent Fasting',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => context.push('/fasting'),
                  icon: Icon(
                    Icons.settings_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (fasting != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${fasting.title} Schedule',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (start)
            StreamBuilder<int>(
              stream: stopWatchTimer.rawTime,
              initialData: stopWatchTimer.rawTime.value,
              builder: (context, snap) {
                final value = snap.data!;
                final displayTime =
                    StopWatchTimer.getDisplayTime(value, hours: true);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.play_circle_filled_rounded,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fasting in Progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        displayTime,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF10B981),
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elapsed Time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 32,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fasting == null ? 'No Fasting Schedule' : 'Ready to Start',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fasting == null
                        ? 'Set up your intermittent fasting schedule'
                        : 'Begin your fasting journey',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: start
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF059669)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (start
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981))
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (fasting == null) {
                    context.push('/fasting');
                  } else {
                    if (stopWatchTimer.isRunning) {
                      Logger().d('message ${stopWatchTimer.minuteTime.value}');
                      _showEndDialog(
                          context,
                          fasting.copyWith(
                              uid: profile!.uid,
                              minuteLeft: stopWatchTimer.minuteTime.value));
                    } else {
                      stopWatchTimer.clearPresetTime();
                      stopWatchTimer.setPresetHoursTime(fasting.start);
                      stopWatchTimer.onStartTimer();
                      ref.read(startFastingProvider.notifier).state = true;
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      start
                          ? Icons.stop_circle_outlined
                          : (fasting == null
                              ? Icons.add_rounded
                              : Icons.play_arrow_rounded),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      start
                          ? 'End Fasting'
                          : (fasting == null
                              ? 'Set Fasting Schedule'
                              : 'Start Fasting'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthHistorySection(
      BuildContext context, AsyncValue healthData, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Health History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '24 Hours',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          healthData.when(
            data: (data) {
              if (data.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.health_and_safety_outlined,
                          size: 32,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No health data available',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Health data will appear here once available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  HealthDataPoint p = data[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getHealthIconColor(p.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getHealthIcon(p.type),
                            color: _getHealthIconColor(p.type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${p.typeString}: ${dataHealthConverter(p)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                checkTypeData(p.typeString)
                                    ? formatWithTime12H.format(p.dateTo)
                                    : '${formatWithTime12H.format(p.dateFrom)} - ${formatWithTime12H.format(p.dateTo)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (p.type != HealthDataType.WORKOUT)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.unitString,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            error: (e, __) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading health data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try refreshing the page',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                  ),
                ],
              ),
            ),
            loading: () => Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHealthIcon(HealthDataType type) {
    switch (type) {
      case HealthDataType.HEART_RATE:
        return Icons.favorite_rounded;
      case HealthDataType.STEPS:
        return Icons.directions_walk_rounded;
      case HealthDataType.WORKOUT:
        return Icons.fitness_center_rounded;
      case HealthDataType.WATER:
        return Icons.water_drop_rounded;
      case HealthDataType.WEIGHT:
        return Icons.monitor_weight_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  Color _getHealthIconColor(HealthDataType type) {
    switch (type) {
      case HealthDataType.HEART_RATE:
        return const Color(0xFFE53E3E);
      case HealthDataType.STEPS:
        return const Color(0xFF3B82F6);
      case HealthDataType.WORKOUT:
        return const Color(0xFFF59E0B);
      case HealthDataType.WATER:
        return const Color(0xFF06B6D4);
      case HealthDataType.WEIGHT:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  void initPlatformState() async {
    _paired = await _watch.isPaired;
    setState(() {});
  }

  int _selectedWater = 0;
  void addWater() {
    // Add haptic feedback for iOS
    if (Platform.isIOS) {
      HapticFeedback.selectionClick();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Water Intake',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (value) {
                    _selectedWater = value;
                    // Add haptic feedback on selection change for iOS
                    if (Platform.isIOS) {
                      HapticFeedback.selectionClick();
                    }
                  },
                  children: List.generate(
                    21,
                    (index) => Center(
                      child: Text(
                        '${waterParser(index).toInt()} ml',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (Platform.isIOS) {
                          HapticFeedback.selectionClick();
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (Platform.isIOS) {
                          HapticFeedback.mediumImpact();
                        }

                        try {
                          await ref.read(healthProvider).addDataHealth(
                              water: waterParser(_selectedWater));

                          // StreamProvider will automatically update UI with real-time data

                          if (context.mounted) {
                            Navigator.pop(context);
                            // Show success feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Added ${waterParser(_selectedWater).toInt()}ml water'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to add water. Please try again.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeightDialog(BuildContext context, ProfileModel? profile) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Update Weight'),
            content: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CupertinoTextField(
                controller: weight,
                keyboardType: TextInputType.number,
                placeholder: 'Weight (kg)',
                suffix: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text('kg'),
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  if (weight.text.isNotEmpty) {
                    final newWeight = double.tryParse(weight.text);
                    if (newWeight != null && profile != null) {
                      await updateProfile(
                        ref,
                        uid: profile.uid!,
                        weight: newWeight,
                      );
                      ref.invalidate(fetchUserProvider);
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Weight'),
            content: TextField(
              controller: weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                suffixText: 'kg',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (weight.text.isNotEmpty) {
                    final newWeight = double.tryParse(weight.text);
                    if (newWeight != null && profile != null) {
                      await updateProfile(
                        ref,
                        uid: profile.uid!,
                        weight: newWeight,
                      );
                      ref.invalidate(fetchUserProvider);
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showEndDialog(BuildContext context, FastingModel fasting) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('End Fasting'),
            content: const Text(
                'Are you sure you want to end your fasting session?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  stopWatchTimer.onStopTimer();
                  stopWatchTimer.onResetTimer();
                  ref.read(startFastingProvider.notifier).state = false;
                  await ref.read(createFastingProvider(fasting).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('End'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('End Fasting'),
            content: const Text(
                'Are you sure you want to end your fasting session?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  stopWatchTimer.onStopTimer();
                  stopWatchTimer.onResetTimer();
                  ref.read(startFastingProvider.notifier).state = false;
                  await ref.read(createFastingProvider(fasting).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('End'),
              ),
            ],
          );
        },
      );
    }
  }

  // Tab builder methods
  Widget _buildOverviewTab(
    BuildContext context,
    ProfileModel? profile,
    AsyncValue<List<BluetoothDevice>> devices,
    double? water,
    bool start,
    FastingModel? fasting,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Metrics Cards
          _buildHealthMetricsSection(context, profile, colorScheme),
          const SizedBox(height: 32),

          // Connected Devices Section
          _buildDevicesSection(devices, colorScheme),

          // Quick Stats
          if (profile?.waterEnable ?? true) ...[
            const SizedBox(height: 24),
            _buildQuickHydrationCard(
                context, profile, water?.toInt(), colorScheme),
          ],

          if (profile?.enableFasting ?? true) ...[
            const SizedBox(height: 16),
            _buildQuickFastingCard(context, start, fasting, colorScheme),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHealthTab(
    BuildContext context,
    ProfileModel? profile,
    AsyncValue<List<HealthDataPoint>> healthData,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Metrics Cards
          _buildHealthMetricsSection(context, profile, colorScheme),
          const SizedBox(height: 32),

          // Health History Section
          _buildHealthHistorySection(context, healthData, colorScheme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActivityTab(
    BuildContext context,
    AsyncValue<List<BluetoothDevice>> devices,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connected Devices Section
          _buildDevicesSection(devices, colorScheme),

          const SizedBox(height: 32),

          // Activity placeholder for future features
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.responsiveSpacing(1.5)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius:
                  BorderRadius.circular(context.responsiveBorderRadius()),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: context.responsiveIconSize(2),
                  color: colorScheme.primary,
                ),
                SizedBox(height: context.responsiveSpacing()),
                Text(
                  'Activity Tracking',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
                SizedBox(height: context.responsiveSpacing(0.5)),
                Text(
                  'Connect your devices to start tracking workouts and activities',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWellnessTab(
    BuildContext context,
    ProfileModel? profile,
    double? water,
    bool start,
    FastingModel? fasting,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hydration Section
          if (profile?.waterEnable ?? true) ...[
            Builder(builder: (context) {
              print('🔍 UI: Raw water value: $water');
              print('🔍 UI: Converted water value: ${water?.toInt()}');
              return _buildHydrationSection(
                  context, profile, water?.toInt(), colorScheme);
            }),
            const SizedBox(height: 32),
          ],

          // Fasting Section
          if (profile?.enableFasting ?? true) ...[
            _buildFastingSection(
                context, start != null, fasting, profile, colorScheme),
            const SizedBox(height: 32),
          ],

          // Wellness placeholder for future features
          if (!(profile?.waterEnable ?? true) &&
              !(profile?.enableFasting ?? true))
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.responsiveSpacing(1.5)),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius:
                    BorderRadius.circular(context.responsiveBorderRadius()),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: context.responsiveIconSize(2),
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: context.responsiveSpacing()),
                  Text(
                    'Wellness Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize! *
                              context.fontSizeMultiplier,
                        ),
                  ),
                  SizedBox(height: context.responsiveSpacing(0.5)),
                  Text(
                    'Enable hydration tracking and fasting features in settings',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .fontSize! *
                              context.fontSizeMultiplier,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Quick card builders for overview tab
  Widget _buildQuickHydrationCard(
    BuildContext context,
    ProfileModel? profile,
    int? water,
    ColorScheme colorScheme,
  ) {
    final target = 2000; // Default water target
    final current = water ?? 0;
    final progress = current / target;

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing()),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius()),
      ),
      child: Row(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: context.responsiveIconSize(),
            color: colorScheme.primary,
          ),
          SizedBox(width: context.responsiveSpacing()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hydration',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
                Text(
                  '${current}ml / ${target}ml',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize! *
                      context.fontSizeMultiplier,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFastingCard(
    BuildContext context,
    bool start,
    FastingModel? fasting,
    ColorScheme colorScheme,
  ) {
    final isActive = start;
    final duration = Duration.zero; // Simplified for now
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing()),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius()),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: context.responsiveIconSize(),
            color: colorScheme.primary,
          ),
          SizedBox(width: context.responsiveSpacing()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fasting',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
                Text(
                  isActive ? 'Active' : 'Not started',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall!.fontSize! *
                                context.fontSizeMultiplier,
                      ),
                ),
              ],
            ),
          ),
          Text(
            isActive ? '${hours}h ${minutes}m' : '--',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize! *
                      context.fontSizeMultiplier,
                ),
          ),
        ],
      ),
    );
  }
}
