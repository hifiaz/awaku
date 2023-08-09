import 'dart:convert';
import 'dart:math';

import 'package:awaku/service/model/workout_model.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

double calculateBodyMassIndex(double weight, int height) {
  double bmi = 0;
  bmi = (weight / pow(height / 100, 2));
  return bmi;
}

double totalWater(double? weight) {
  return (0.03 * (weight ?? 0).toDouble());
}

final formateDate = DateFormat("yyyy-MM-dd");
final formatWithTime12H = DateFormat('MMM d, h:mm a');
final formatDayTime = DateFormat('E, hh:mm a');
final formatTime = DateFormat('hh:mm a');

double waterParser(int index) {
  switch (index) {
    case 0:
      return 50;
    case 1:
      return 100;
    case 2:
      return 150;
    case 3:
      return 200;
    case 4:
      return 250;
    case 5:
      return 400;
    case 6:
      return 500;
    case 7:
      return 600;
    case 8:
      return 800;
    case 9:
      return 1000;
    default:
      return 50;
  }
}

String dataHealthConverter(HealthDataPoint data) {
  if (data.type == HealthDataType.WORKOUT) {
    WorkoutModel result = WorkoutModel.fromJson(jsonEncode(data.value));
    return '${result.workoutActivityType}, ${result.totalDistance ?? 0} ${result.totalDistanceUnit}';
  }
  return '${data.value}';
}

bool checkTypeData(String type) {
  if (type == 'WATER') {
    return true;
  } else if (type == 'HEIGHT') {
    return true;
  } else if (type == 'WEIGHT') {
    return true;
  } else {
    return false;
  }
}
