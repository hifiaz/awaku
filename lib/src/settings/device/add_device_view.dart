import 'package:awaku/service/provider/devices_provider.dart';
import 'package:awaku/src/settings/device/widget/scan_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddDeviceView extends ConsumerStatefulWidget {
  const AddDeviceView({super.key});
  static const routeName = '/settings/add-device';

  @override
  ConsumerState<AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends ConsumerState<AddDeviceView> {
  @override
  void initState() {
    scanBloethooth();
    super.initState();
  }

  void scanBloethooth() async {
    await FTMS.scanForBluetoothDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ref.invalidate(getDevicesProvider);
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: FTMS.isScanning,
            builder: (c, snapshot) {
              return ElevatedButton(
                onPressed: snapshot.data ?? false
                    ? null
                    : () async => await FTMS.scanForBluetoothDevices(),
                child: snapshot.data ?? false
                    ? const Text("Scanning...")
                    : const Text("Scan Devices"),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<ScanResult>>(
              stream: FTMS.scanResults,
              initialData: const [],
              builder: (c, snapshot) => ScanResults(
                data: (snapshot.data ?? [])
                    .where((element) => element.device.localName.isNotEmpty)
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
