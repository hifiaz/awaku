import 'package:awaku/utils/constants.dart';
import 'package:health/health.dart';
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
    var result = await health.hasPermissions(types);
    if (result == null || result) {
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
          water, HealthDataType.WATER, earlier, now);
    }
    if (weight != null) {
      success &= await health.writeHealthData(
          weight, HealthDataType.WEIGHT, earlier, now);
    }
    return success;
  }

  Future<List<HealthDataPoint>> getDataHealth(
      {double? water, double? weight}) async {
    final yesterday = now.subtract(const Duration(hours: 24));
    return await health.getHealthDataFromTypes(yesterday, now, types);
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
class HealthAuthNotifier extends _$HealthAuthNotifier {
  @override
  Future<bool> build() async {
    return ref.read(healthProvider).permission();
  }
}
