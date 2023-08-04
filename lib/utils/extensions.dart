import 'dart:math';

double calculateBodyMassIndex(double weight, double height) {
  double bmi = 0;
  bmi = (weight / pow(height / 100, 2));
  return bmi;
}
