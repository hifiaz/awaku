import 'package:logger/logger.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

final StopWatchTimer stopWatchTimer = StopWatchTimer(
  mode: StopWatchMode.countDown,
  presetMillisecond: StopWatchTimer.getMilliSecFromHour(0),
  // onChange: (value) => Logger().d('onChange $value'),
  // onChangeRawSecond: (value) => Logger().d('onChangeRawSecond $value'),
  // onChangeRawMinute: (value) => Logger().d('onChangeRawMinute $value'),
  onStopped: () {
    Logger().d('onStopped');
  },
  onEnded: () {
    Logger().d('onEnded');
  },
);
