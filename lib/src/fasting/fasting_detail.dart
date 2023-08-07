import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/service/stop_watch_service.dart';
import 'package:awaku/utils/extensions.dart';
import 'package:awaku/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class FastingDetail extends StatefulWidget {
  final FastingModel fasting;
  const FastingDetail({
    Key? key,
    required this.fasting,
  }) : super(key: key);

  @override
  State<FastingDetail> createState() => _FastingDetailState();
}

class _FastingDetailState extends State<FastingDetail> {
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  @override
  void initState() {
    setEndTime(DateTime.now());
    super.initState();
  }

  void setEndTime(DateTime date) {
    setState(() {
      end = date.add(Duration(hours: widget.fasting.end));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(widget.fasting.title,
                style: Theme.of(context).textTheme.displaySmall),
            const Text('Fasting'),
            // if (stopWatchTimer.isRunning)
            Column(
              children: [
                StreamBuilder<int>(
                  stream: stopWatchTimer.rawTime,
                  initialData: stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data!;
                    final displayTime =
                        StopWatchTimer.getDisplayTime(value, hours: true);
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            displayTime,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Text('End (expected)'),
                Text(formatTime.format(end)),
              ],
            ),
            // else ...[
            ListTile(
              minLeadingWidth: 10,
              leading: const Icon(
                Icons.circle,
                size: 15,
                color: Colors.green,
              ),
              title: const Text('Start'),
              subtitle: Text(formatDayTime.format(start)),
              trailing: const Icon(Icons.edit),
              onTap: showTimePicker,
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Icon(
                Icons.circle,
                size: 15,
                color: Colors.red,
              ),
              title: const Text('End (expected)'),
              subtitle: Text(formatDayTime.format(end)),
            ),
            // ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                  backgroundColor: Colors.blue,
                  width: double.infinity,
                  isDisabled: false,
                  title: stopWatchTimer.isRunning
                      ? 'End fasting'
                      : 'Start fasting',
                  onPressed: () {
                    if (stopWatchTimer.isRunning) {
                      stopWatchTimer.onStopTimer();
                      stopWatchTimer.onResetTimer();
                    } else {
                      stopWatchTimer.clearPresetTime();
                      stopWatchTimer.setPresetHoursTime(widget.fasting.start);
                      stopWatchTimer.onStartTimer();
                    }
                    setState(() {});
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: start,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      start = newDateTime;
                      setEndTime(newDateTime);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
