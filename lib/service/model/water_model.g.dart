// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterModel _$WaterModelFromJson(Map<String, dynamic> json) => WaterModel(
      uid: json['uid'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$WaterModelToJson(WaterModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'amount': instance.amount,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'note': instance.note,
    };
