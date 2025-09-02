import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/service/repository/fasting_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startFastingProvider = StateProvider<bool>((ref) => false);

final selectedFastingProvider = StateProvider<FastingModel?>((ref) => null);

final createFastingProvider = FutureProvider.family<void, FastingModel>((ref, fasting) async {
  await ref.read(fastingRepositoryProvider).create(fasting);
});
