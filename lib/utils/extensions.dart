import 'dart:math';

double calculateBodyMassIndex(double weight, int height) {
  double bmi = 0;
  bmi = (weight / pow(height / 100, 2));
  return bmi;
}

double waterParser(int index) {
  switch (index) {
    case 1:
      return 50.0;
    case 2:
      return 100.0;
    case 3:
      return 150.0;
    case 4:
      return 200.0;
    case 5:
      return 250.0;
    case 6:
      return 400.0;
    case 7:
      return 500.0;
    case 8:
      return 600.0;
    case 9:
      return 800.0;
    case 10:
      return 1000.0;
    default:
      return 50.0;
  }
}
