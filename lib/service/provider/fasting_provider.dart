import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/service/provider/states/general_states.dart';
import 'package:awaku/service/repository/fasting_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fasting_provider.g.dart';

@Riverpod(keepAlive: true)
class StartFasting extends _$StartFasting {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
class SelectedFasting extends _$SelectedFasting {
  @override
  FastingModel? build() => null;

  void set(FastingModel value) {
    state = value;
  }
}

class FastingProvider extends StateNotifier<GeneralState> {
  FastingProvider(this.ref) : super(const GeneralStateInitial());

  final Ref ref;

  void create(FastingModel user) async {
    state = const GeneralStateLoading();
    final response = await ref.read(fastingRepositoryProvider).create(user);
    state = response.fold(
      (l) => GeneralStateError(l.toString()),
      (r) => const GeneralStateSuccess(),
    );
  }

  // void update({
  //   required String uid,
  //   String? url,
  //   String? name,
  //   DateTime? dob,
  //   String? gender,
  //   bool? enableWater,
  //   bool? enableFasting,
  //   double? weight,
  //   int? height,
  // }) async {
  //   state = const ProfileStateLoading();
  //   final response = await ref.read(profileRepositoryProvider).update(
  //         uid,
  //         name: name,
  //         dob: dob,
  //         enableWater: enableWater,
  //         enableFasting: enableFasting,
  //         gender: gender,
  //         weight: weight,
  //         height: height,
  //       );
  //   state = response.fold(
  //     (l) => ProfileStateError(l.toString()),
  //     (r) => const ProfileStateSuccess(),
  //   );
  // }
}

final fastingProvider =
    StateNotifierProvider<FastingProvider, GeneralState>((ref) {
  return FastingProvider(ref);
});
