import 'package:awaku/service/ftms_service.dart';
import 'package:awaku/src/bike/bike_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanResults extends ConsumerWidget {
  final List<ScanResult> data;
  const ScanResults({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: data
          .map(
            (d) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: FutureBuilder<bool>(
                    future: FTMS.isBluetoothDeviceFTMSDevice(d.device),
                    initialData: false,
                    builder: (c, snapshot) {
                      return Text(
                        d.device.platformName.isEmpty
                            ? "(unknown device)"
                            : d.device.platformName,
                      );
                    },
                  ),
                  subtitle: Text(d.device.remoteId.str),
                  trailing: SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(d.rssi.toString()),
                    ),
                  ),
                ),
                StreamBuilder<BluetoothConnectionState>(
                    stream: d.device.connectionState,
                    builder: (c, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }
                      var deviceState = snapshot.data!;
                      switch (deviceState) {
                        case BluetoothConnectionState.disconnected:
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ElevatedButton(
                              child: const Text("Connect"),
                              onPressed: () async {
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Connecting to ${d.device.platformName}...'),
                                  duration: const Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                await FTMS.connectToFTMSDevice(d.device);
                                d.device.connectionState.listen((state) async {
                                  if (state ==
                                          BluetoothConnectionState
                                              .disconnected) {
                                    // Note: disconnecting state is deprecated and not streamed on Android & iOS
                                    ftmsService.ftmsDeviceDataControllerSink
                                        .add(null);
                                    return;
                                  }
                                });
                              },
                            ),
                          );
                        case BluetoothConnectionState.connected:
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FutureBuilder<bool>(
                                future:
                                    FTMS.isBluetoothDeviceFTMSDevice(d.device),
                                initialData: false,
                                builder: (c, snapshot) =>
                                    (snapshot.data ?? false)
                                        ? ElevatedButton(
                                            child: const Text("FTMS"),
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BikeView(
                                                  ftmsDevice: d.device,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                              ),
                              OutlinedButton(
                                child: const Text("Disconnect"),
                                onPressed: () =>
                                    FTMS.disconnectFromFTMSDevice(d.device),
                              )
                            ],
                          );
                        default:
                          return Text(deviceState.name);
                      }
                    })
              ],
            ),
          )
          .toList(),
    );
  }
}
