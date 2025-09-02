import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'water_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class WaterModel {
  final String uid;
  final double amount; // in milliliters
  @TimestampConverter()
  final DateTime timestamp;
  final String? note;

  WaterModel({
    required this.uid,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  factory WaterModel.fromJson(Map<String, dynamic> json) =>
      _$WaterModelFromJson(json);

  Map<String, dynamic> toJson() => _$WaterModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}