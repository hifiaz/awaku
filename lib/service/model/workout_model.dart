// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WorkoutModel {
  String workoutActivityType;
  int? totalEnergyBurned;
  String totalEnergyBurnedUnit;
  int? totalDistance;
  String totalDistanceUnit;
  WorkoutModel({
    required this.workoutActivityType,
    this.totalEnergyBurned,
    required this.totalEnergyBurnedUnit,
    this.totalDistance,
    required this.totalDistanceUnit,
  });

  WorkoutModel copyWith({
    String? workoutActivityType,
    int? totalEnergyBurned,
    String? totalEnergyBurnedUnit,
    int? totalDistance,
    String? totalDistanceUnit,
  }) {
    return WorkoutModel(
      workoutActivityType: workoutActivityType ?? this.workoutActivityType,
      totalEnergyBurned: totalEnergyBurned ?? this.totalEnergyBurned,
      totalEnergyBurnedUnit: totalEnergyBurnedUnit ?? this.totalEnergyBurnedUnit,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDistanceUnit: totalDistanceUnit ?? this.totalDistanceUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'workoutActivityType': workoutActivityType,
      'totalEnergyBurned': totalEnergyBurned,
      'totalEnergyBurnedUnit': totalEnergyBurnedUnit,
      'totalDistance': totalDistance,
      'totalDistanceUnit': totalDistanceUnit,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      workoutActivityType: map['workoutActivityType'] as String,
      totalEnergyBurned: map['totalEnergyBurned'] != null ? map['totalEnergyBurned'] as int : null,
      totalEnergyBurnedUnit: map['totalEnergyBurnedUnit'] as String,
      totalDistance: map['totalDistance'] != null ? map['totalDistance'] as int : null,
      totalDistanceUnit: map['totalDistanceUnit'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutModel.fromJson(String source) => WorkoutModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WorkoutModel(workoutActivityType: $workoutActivityType, totalEnergyBurned: $totalEnergyBurned, totalEnergyBurnedUnit: $totalEnergyBurnedUnit, totalDistance: $totalDistance, totalDistanceUnit: $totalDistanceUnit)';
  }

  @override
  bool operator ==(covariant WorkoutModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.workoutActivityType == workoutActivityType &&
      other.totalEnergyBurned == totalEnergyBurned &&
      other.totalEnergyBurnedUnit == totalEnergyBurnedUnit &&
      other.totalDistance == totalDistance &&
      other.totalDistanceUnit == totalDistanceUnit;
  }

  @override
  int get hashCode {
    return workoutActivityType.hashCode ^
      totalEnergyBurned.hashCode ^
      totalEnergyBurnedUnit.hashCode ^
      totalDistance.hashCode ^
      totalDistanceUnit.hashCode;
  }
}
