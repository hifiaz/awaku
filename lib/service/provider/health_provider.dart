import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/utils/constants.dart';
import 'package:health/health.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

@riverpod
HealthProvider health(HealthRef _) => HealthProvider();

class HealthProvider {
  HealthFactory health = HealthFactory();
  final types = dataTypes;
  final now = DateTime.now();

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
      success &= await health.writeHealthData(
        water,
        HealthDataType.WATER,
        earlier,
        now,
        unit: HealthDataUnit.MILLILITER,
      );
    }
    if (weight != null) {
      success &= await health.writeHealthData(
          weight, HealthDataType.WEIGHT, earlier, now,
          unit: HealthDataUnit.KILOGRAM);
    }
    return success;
  }

  Future<bool> addWeightAndHeight({double? weight, double? height}) async {
    final earlier = now.subtract(const Duration(minutes: 20));
    bool success = true;
    if (weight != null) {
      success &= await health.writeHealthData(
          weight, HealthDataType.WEIGHT, earlier, now);
    }
    if (height != null) {
      success &= await health.writeHealthData(
          height.toDouble(), HealthDataType.HEIGHT, earlier, now);
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
        HealthWorkoutActivityType.BIKING, start, end,
        totalDistance: distance,
        totalDistanceUnit: HealthDataUnit.METER,
        totalEnergyBurned: calories,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE);
    return success;
  }

  Future<List<HealthDataPoint>> getDataHealth(
      {double? water, double? weight}) async {
    final yesterday = now.subtract(const Duration(hours: 24));
    return await health.getHealthDataFromTypes(yesterday, now, types);
  }

  Future<List<HealthDataPoint>> getWater() async {
    final yesterday = now.subtract(const Duration(hours: 24));
    return await health
        .getHealthDataFromTypes(yesterday, now, [HealthDataType.WATER]);
  }
}

@riverpod
class HealthNotifier extends _$HealthNotifier {
  @override
  Future<List<HealthDataPoint>> build() async {
    return ref.read(healthProvider).getDataHealth();
  }
}

@riverpod
Future<double?> currentHydration(CurrentHydrationRef ref) async {
  final user = ref.watch(fetchUserProvider).valueOrNull;
  final water = await ref.read(healthProvider).getWater();
  double totalWater = 0.0;
  for (var i in water) {
    totalWater = totalWater + (double.parse(i.value.toString()) * 1000);
  }
  double total = (0.03 * (user?.weight ?? 0.1).toDouble()) * 1000;
  double calculate = 100 - ((total - totalWater) / total) * 100;
  return calculate;
}

@riverpod
class HealthAuthNotifier extends _$HealthAuthNotifier {
  @override
  Future<bool> build() async {
    return ref.read(healthProvider).permission();
  }
}
