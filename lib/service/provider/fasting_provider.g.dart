// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$startFastingHash() => r'4afdf161b62847174f9a9ff667340e8e01714187';

/// See also [StartFasting].
@ProviderFor(StartFasting)
final startFastingProvider = NotifierProvider<StartFasting, bool>.internal(
  StartFasting.new,
  name: r'startFastingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$startFastingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StartFasting = Notifier<bool>;
String _$selectedFastingHash() => r'ab7b16301db43ef913a5e46d0b2fb792d86034e7';

/// See also [SelectedFasting].
@ProviderFor(SelectedFasting)
final selectedFastingProvider =
    NotifierProvider<SelectedFasting, FastingModel?>.internal(
  SelectedFasting.new,
  name: r'selectedFastingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedFastingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedFasting = Notifier<FastingModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member
