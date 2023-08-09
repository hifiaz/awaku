import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fasting_service.g.dart';

class FastingService {
  final FirebaseFirestore _firebaseStore;

  FastingService(this._firebaseStore);

  Future<Either<String, bool>> create({required FastingModel fasting}) async {
    try {
      await _firebaseStore.collection('fasting').add(fasting.toMap());
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something Wrong');
    }
  }

  Future<Either<String, List<FastingModel>>> get({required String uid}) async {
    try {
      final data = await _firebaseStore
          .collection('fasting')
          .where("uid", isEqualTo: uid)
          .get();

      List<FastingModel> result = List<FastingModel>.from(data.docs
          .map((data) => FastingModel.fromJson(data.data().toString())));
      return right(result);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something Wrong');
    }
  }

  // Future<Either<String, bool>> update({
  //   required String uid,
  //   String? url,
  //   String? name,
  //   String? gender,
  //   DateTime? dob,
  //   bool? enableWater,
  //   bool? enableFasting,
  //   double? weight,
  //   int? height,
  // }) async {
  //   try {
  //     var params = {
  //       'name': name,
  //       'photoUrl': url,
  //       'weight': weight,
  //       'height': height,
  //       'dob': dob,
  //       'gender': gender,
  //       'waterEnable': enableWater,
  //       'enableFasting': enableFasting,
  //     };
  //     params.removeWhere((key, value) => value == null);
  //     await _firebaseStore.collection('user').doc(uid).update(params);
  //     return right(true);
  //   } on FirebaseAuthException catch (e) {
  //     return left(e.message ?? 'Something Wrong on Create Account');
  //   }
  // }
}

@riverpod
FastingService fastingService(FastingServiceRef ref) =>
    FastingService(ref.read(firebaseFirestoreProvider));
