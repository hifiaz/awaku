import 'dart:math';

double calculateBodyMassIndex(double weight, int height) {
  double bmi = 0;
  bmi = (weight / pow(height / 100, 2));
  return bmi;
}
