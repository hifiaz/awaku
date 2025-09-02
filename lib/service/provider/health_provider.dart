import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/water_service.dart';
import 'package:awaku/service/model/water_model.dart';
import 'package:awaku/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

// part 'health_provider.g.dart'; // Commented out due to build issues

// Manual providers to replace @riverpod generated ones
final healthProvider = Provider<HealthProvider>((ref) => HealthProvider(ref));

class HealthProvider {
  final Ref _ref;
  Health health = Health();
  final types = dataTypes;
  final now = DateTime.now();

  HealthProvider(this._ref);

  Future<bool> auth() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
    return await health.requestAuthorization(types, permissions: permissions);
  }

  Future<bool> permission() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
    var result = await health.hasPermissions(types, permissions: permissions);
    Logger().d('permission $result');
    if (result == true) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  Future<void> revoke() async {
    return await health.revokePermissions();
  }

  Future<bool> addDataHealth({double? water, double? weight}) async {
    final earlier = now.subtract(const Duration(minutes: 20));
    bool success = true;
    if (water != null) {
      // Save to HealthKit
      success &= await health.writeHealthData(
        value: water,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now,
        unit: HealthDataUnit.MILLILITER,
      );
      
      // Save to Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final waterModel = WaterModel(
            uid: currentUser.uid,
            amount: water,
            timestamp: now,
          );
          
          final waterService = _ref.read(waterServiceProvider);
          final result = await waterService.addWater(water: waterModel);
          
          result.fold(
            (error) {
              Logger().e('Failed to save water to Firebase: $error');
              // Don't fail the entire operation if Firebase save fails
            },
            (success) {
              Logger().d('Water data saved to Firebase successfully');
            },
          );
        } catch (e) {
          Logger().e('Error saving water to Firebase: $e');
          // Don't fail the entire operation if Firebase save fails
        }
      }
    }
    if (weight != null) {
      success &= await health.writeHealthData(
        value: weight,
        type: HealthDataType.WEIGHT,
        startTime: earlier,
        endTime: now,
        unit: HealthDataUnit.KILOGRAM,
      );
    }
    return success;
  }

  Future<bool> addWeightAndHeight({double? weight, double? height}) async {
    final earlier = now.subtract(const Duration(minutes: 20));
    bool success = true;
    if (weight != null) {
      success &= await health.writeHealthData(
        value: weight,
        type: HealthDataType.WEIGHT,
        startTime: earlier,
        endTime: now,
      );
    }
    if (height != null) {
      success &= await health.writeHealthData(
        value: height.toDouble(),
        type: HealthDataType.HEIGHT,
        startTime: earlier,
        endTime: now,
      );
    }
    return success;
  }

  Future<bool> addBike(
      {required DateTime start,
      required DateTime end,
      int? distance,
      int? calories}) async {
    bool success = true;
    success &= await health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.BIKING,
        start: start,
        end: end,
        totalDistance: distance,
        totalDistanceUnit: HealthDataUnit.METER,
        totalEnergyBurned: calories,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE);
    return success;
  }

  Future<List<HealthDataPoint>> getDataHealth(
      {double? water, double? weight}) async {
    final yesterday = now.subtract(const Duration(hours: 24));
    return await health.getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: now);
  }

  Future<List<HealthDataPoint>> getWater() async {
    final yesterday = now.subtract(const Duration(hours: 24));
    return await health.getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: yesterday,
        endTime: now);
  }
}

final healthNotifierProvider = FutureProvider<List<HealthDataPoint>>((ref) async {
  return ref.read(healthProvider).getDataHealth();
});

// Real-time hydration provider using Firebase data
final currentHydrationProvider = StreamProvider<double?>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    return Stream.value(0.0);
  }
  
  // Combine user profile and water data streams
  return ref.watch(totalWaterTodayStreamProvider.stream).asyncMap((totalWaterML) async {
    print('🔍 HydrationProvider: Received total water: $totalWaterML ML');
    
    // Get user profile for target calculation
    final userAsync = ref.read(fetchUserProvider);
    final user = userAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (error, stack) => null,
    );

    print('🔍 HydrationProvider: User weight: ${user?.weight ?? 70} kg');

    // Convert consumed water from ML to L
    double totalWaterConsumedL = totalWaterML / 1000;
    print('🔍 HydrationProvider: Consumed water: $totalWaterConsumedL L');
    
    // Target water in liters (0.03 * weight)
    double targetWaterL = (0.03 * (user?.weight ?? 70).toDouble());
    print('🔍 HydrationProvider: Target water: $targetWaterL L');
    
    // Calculate percentage: (consumed / target) * 100
    double percentage = targetWaterL > 0 ? (totalWaterConsumedL / targetWaterL) * 100 : 0.0;
    print('🔍 HydrationProvider: Calculated percentage: $percentage%');
    
    // Cap at 100% to avoid showing over 100%
    final finalPercentage = percentage > 100 ? 100.0 : percentage;
    print('🔍 HydrationProvider: Final percentage: $finalPercentage%');
    
    return finalPercentage;
  });
});

// Legacy provider for backward compatibility (now uses Firebase data)
final currentHydrationFutureProvider = FutureProvider<double?>((ref) async {
  final streamValue = await ref.watch(currentHydrationProvider.future);
  return streamValue;
});

final healthAuthProvider = FutureProvider<bool>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    return false;
  }
  
  return ref.read(healthProvider).permission();
});
