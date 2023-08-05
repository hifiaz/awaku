import 'package:awaku/service/ftms_service.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ftms/flutter_ftms.dart';

class BikeView extends StatefulWidget {
  final BluetoothDevice ftmsDevice;

  const BikeView({Key? key, required this.ftmsDevice}) : super(key: key);

  @override
  State<BikeView> createState() => _BikeViewState();
}

class _BikeViewState extends State<BikeView> {
  List<double> data = [0.0];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DeviceData?>(
        stream: ftmsService.ftmsDeviceDataControllerStream,
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text("No FTMSData found!")),
                ElevatedButton(
                  onPressed: () async {
                    await FTMS.useDeviceDataCharacteristic(widget.ftmsDevice,
                        (DeviceData data) {
                      ftmsService.ftmsDeviceDataControllerSink.add(data);
                    });
                  },
                  child: const Text("Start"),
                ),
              ],
            );
          }
          final power = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere(
                  (element) => element.flag?.name == 'Instantaneous Power');
          final speed = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'More Data');
          final instan = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere(
                  (element) => element.flag?.name == 'Instantaneous Cadence');
          final time = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Elapsed Time');
          final distance = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Total Distance');
          data.add(power.value.toDouble());
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Sparkline(data: data),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                              '${(instan.value / 60).toStringAsFixed(2)} ${instan.unit}'),
                          const SizedBox(width: 10),
                          Text('${time.value} ${time.unit}'),
                          const SizedBox(width: 10),
                          Text('${distance.value} ${distance.unit}'),
                          const SizedBox(width: 10),
                          Text('${speed.value / 100} ${speed.unit}'),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${power.value}',
                              textScaleFactor: 4,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            const Text('Power')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    FTMS.convertDeviceDataTypeToString(
                        snapshot.data!.deviceDataType),
                    textScaleFactor: 2,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
