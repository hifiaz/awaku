import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@riverpod
Stream<List<BluetoothDevice>> getDevices(GetDevicesRef ref) {
  return Stream.fromFuture(FTMS.listDevices());
}
