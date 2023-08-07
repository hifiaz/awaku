import 'package:awaku/service/model/fasting_model.dart';
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
