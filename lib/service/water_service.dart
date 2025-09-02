import 'package:awaku/service/model/water_model.dart';
import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'water_service.g.dart';

class WaterService {
  final FirebaseFirestore _firebaseStore;

  WaterService(this._firebaseStore);

  Future<Either<String, bool>> addWater({required WaterModel water}) async {
    try {
      await _firebaseStore.collection('water').add(water.toMap());
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something went wrong');
    } catch (e) {
      return left('Failed to save water data: $e');
    }
  }

  Future<Either<String, List<WaterModel>>> getWaterToday(
      {required String uid}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final data = await _firebaseStore
          .collection('water')
          .where('uid', isEqualTo: uid)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();
      print('hello ${data.docs}');
      List<WaterModel> result =
          data.docs.map((doc) => WaterModel.fromJson(doc.data())).toList();

      return right(result);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something went wrong');
    } catch (e) {
      return left('Failed to fetch water data: $e');
    }
  }

  Future<Either<String, double>> getTotalWaterToday(
      {required String uid}) async {
    try {
      final waterResult = await getWaterToday(uid: uid);
      return waterResult.fold(
        (error) => left(error),
        (waterList) {
          double total =
              waterList.fold(0.0, (sum, water) => sum + water.amount);
          return right(total);
        },
      );
    } catch (e) {
      return left('Failed to calculate total water: $e');
    }
  }

  Stream<List<WaterModel>> watchWaterToday({required String uid}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('🔍 WaterService: Querying water for UID: $uid');
    print('🔍 WaterService: Date range: $startOfDay to $endOfDay');

    return _firebaseStore
        .collection('water')
        .where('uid', isEqualTo: uid)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔍 WaterService: Found ${snapshot.docs.length} water entries');
          final waterList = snapshot.docs
              .map((doc) {
                final data = doc.data();
                print('🔍 WaterService: Raw doc data: $data');
                return WaterModel.fromJson(data);
              })
              .toList();
          print('🔍 WaterService: Parsed water list: $waterList');
          return waterList;
        });
  }
}

@riverpod
WaterService waterService(WaterServiceRef ref) {
  return WaterService(ref.read(firebaseFirestoreProvider));
}

// Provider for real-time water data
@riverpod
Stream<List<WaterModel>> waterTodayStream(WaterTodayStreamRef ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return ref.read(waterServiceProvider).watchWaterToday(uid: currentUser.uid);
}

// Provider for total water consumed today
@riverpod
Stream<double> totalWaterTodayStream(TotalWaterTodayStreamRef ref) {
  return ref.watch(waterTodayStreamProvider.stream).map((waterList) {
    print('🔍 TotalWaterStream: Received ${waterList.length} water entries');
    final total = waterList.fold(0.0, (sum, water) {
      print('🔍 TotalWaterStream: Adding ${water.amount} ML (sum: $sum)');
      return sum + water.amount;
    });
    print('🔍 TotalWaterStream: Final total: $total ML');
    return total;
  });
}
