// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$waterServiceHash() => r'a7c408b45a2a68afda9507bf9a25a48dcfe764d1';

/// See also [waterService].
@ProviderFor(waterService)
final waterServiceProvider = AutoDisposeProvider<WaterService>.internal(
  waterService,
  name: r'waterServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$waterServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WaterServiceRef = AutoDisposeProviderRef<WaterService>;
String _$waterTodayStreamHash() => r'3cbaf2e952e147f9e7e6bb1803bd332228501c93';

/// See also [waterTodayStream].
@ProviderFor(waterTodayStream)
final waterTodayStreamProvider =
    AutoDisposeStreamProvider<List<WaterModel>>.internal(
  waterTodayStream,
  name: r'waterTodayStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$waterTodayStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WaterTodayStreamRef = AutoDisposeStreamProviderRef<List<WaterModel>>;
String _$totalWaterTodayStreamHash() =>
    r'47550aa6175de2423fca1022581093c53019d22a';

/// See also [totalWaterTodayStream].
@ProviderFor(totalWaterTodayStream)
final totalWaterTodayStreamProvider =
    AutoDisposeStreamProvider<double>.internal(
  totalWaterTodayStream,
  name: r'totalWaterTodayStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalWaterTodayStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalWaterTodayStreamRef = AutoDisposeStreamProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
