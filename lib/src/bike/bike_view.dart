import 'package:awaku/service/ftms_service.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class BikeView extends ConsumerStatefulWidget {
  final BluetoothDevice ftmsDevice;

  const BikeView({Key? key, required this.ftmsDevice}) : super(key: key);

  @override
  ConsumerState<BikeView> createState() => _BikeViewState();
}

class _BikeViewState extends ConsumerState<BikeView> {
  DateTime start = DateTime.now();
  DeviceDataParameterValue? totalDistance;
  DeviceDataParameterValue? cal;
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => showAlertDialog(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: StreamBuilder<DeviceData?>(
        stream: ftmsService.ftmsDeviceDataControllerStream,
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FTMS.useDeviceDataCharacteristic(widget.ftmsDevice,
                          (DeviceData data) {
                        ftmsService.ftmsDeviceDataControllerSink.add(data);
                      });
                    },
                    child: const Text("Start"),
                  ),
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
          final energy = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Expended Energy');
          totalDistance = distance;
          cal = energy;
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
                          Text('${energy.value} ${energy.unit}'),
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
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: snapshot.data!
                      //       .getDeviceDataParameterValues()
                      //       .map((parameterValue) => Text(
                      //             '${parameterValue.toString()} - ${parameterValue.flag?.name}',
                      //           ))
                      //       .toList(),
                      // ),
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

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        context.pop();
      },
    );

    Widget exitButton = TextButton(
      child: const Text("Exit"),
      onPressed: () {
        context.pop();
        context.pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Exit & Save"),
      onPressed: () async {
        Logger().d(
            'start $start end ${DateTime.now()} cal $cal distance $totalDistance');
        await ref.read(healthProvider).addBike(
            start: start,
            end: DateTime.now(),
            calories: cal!.value,
            distance: totalDistance!.value);
        if (context.mounted) {
          context.pop();
          context.pop();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Exit"),
      content: const Text("Are you sure want to exit from this page?"),
      actions: [
        cancelButton,
        exitButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
