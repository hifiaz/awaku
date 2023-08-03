import 'package:awaku/src/settings/device/widget/scan_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';

class AddDeviceView extends StatelessWidget {
  const AddDeviceView({super.key});
  static const routeName = '/settings/add-device';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: StreamBuilder<bool>(
                stream: FTMS.isScanning,
                builder: (c, snapshot) {
                  return ElevatedButton(
                    onPressed: snapshot.data ?? false
                        ? null
                        : () async => await FTMS.scanForBluetoothDevices(),
                    child: snapshot.data ?? false
                        ? const Text("Scanning...")
                        : const Text("Scan FTMS Devices"),
                  );
                },
              ),
            ),
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
