// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ProfileModel _$$_ProfileModelFromJson(Map<String, dynamic> json) =>
    _$_ProfileModel(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      height: json['height'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      gender: json['gender'] as String?,
      waterEnable: json['waterEnable'] as bool?,
      dob: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dob'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$$_ProfileModelToJson(_$_ProfileModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'height': instance.height,
      'weight': instance.weight,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'gender': instance.gender,
      'waterEnable': instance.waterEnable,
      'dob': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dob, const TimestampConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
