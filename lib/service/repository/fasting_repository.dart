import 'package:awaku/service/fasting_service.dart';
import 'package:awaku/service/model/fasting_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FastingRepository {
  final FastingService _fastingService;
  FastingRepository(this._fastingService);

  Future<Either<String, bool?>> create(FastingModel fastingModel) {
    return _fastingService.create(fasting: fastingModel);
  }

  // Future<Either<String, FastingModel>> update(
  //     String email, String password) async {
  //   return _authService.signup(email: email, password: password);
  // }

  Future<Either<String, List<FastingModel>>> getAll(String uid) async {
    return _fastingService.get(uid: uid);
  }
}

final fastingRepositoryProvider = Provider<FastingRepository>((ref) {
  return FastingRepository(ref.read(fastingServiceProvider));
});
