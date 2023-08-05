// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthHash() => r'2005fd993d271c92de11d9a380a7a53f742a2c60';

/// See also [health].
@ProviderFor(health)
final healthProvider = AutoDisposeProvider<HealthProvider>.internal(
  health,
  name: r'healthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$healthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HealthRef = AutoDisposeProviderRef<HealthProvider>;
String _$healthNotifierHash() => r'6d18c4552a056305472c364689a5a4d18a190e70';

/// See also [HealthNotifier].
@ProviderFor(HealthNotifier)
final healthNotifierProvider = AutoDisposeAsyncNotifierProvider<HealthNotifier,
    List<HealthDataPoint>>.internal(
  HealthNotifier.new,
  name: r'healthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HealthNotifier = AutoDisposeAsyncNotifier<List<HealthDataPoint>>;
String _$healthAuthNotifierHash() =>
    r'5061d438b9be36c5f89ed035d53f3bec85a75a1c';

/// See also [HealthAuthNotifier].
@ProviderFor(HealthAuthNotifier)
final healthAuthNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HealthAuthNotifier, bool>.internal(
  HealthAuthNotifier.new,
  name: r'healthAuthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthAuthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HealthAuthNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member
