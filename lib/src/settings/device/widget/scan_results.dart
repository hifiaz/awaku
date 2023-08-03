import 'package:awaku/service/ftms_service.dart';
import 'package:awaku/src/bike/bike_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';

class ScanResults extends StatelessWidget {
  final List<ScanResult> data;
  const ScanResults({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
                        d.device.localName.isEmpty
                            ? "(unknown device)"
                            : d.device.localName,
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
                          return ElevatedButton(
                            child: const Text("Connect"),
                            onPressed: () async {
                              final snackBar = SnackBar(
                                content: Text(
                                    'Connecting to ${d.device.localName}...'),
                                duration: const Duration(seconds: 2),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);

                              await FTMS.connectToFTMSDevice(d.device);
                              d.device.connectionState.listen((state) async {
                                if (state ==
                                        BluetoothConnectionState.disconnected ||
                                    state ==
                                        BluetoothConnectionState
                                            .disconnecting) {
                                  ftmsService.ftmsDeviceDataControllerSink
                                      .add(null);
                                  return;
                                }
                              });
                            },
                          );
                        case BluetoothConnectionState.connected:
                          return SizedBox(
                            width: 250,
                            child: Wrap(
                              spacing: 2,
                              alignment: WrapAlignment.end,
                              direction: Axis.horizontal,
                              children: [
                                FutureBuilder<bool>(
                                  future: FTMS
                                      .isBluetoothDeviceFTMSDevice(d.device),
                                  initialData: false,
                                  builder: (c, snapshot) => (snapshot.data ??
                                          false)
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
                            ),
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
