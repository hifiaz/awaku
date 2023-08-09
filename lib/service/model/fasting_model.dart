// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FastingModel {
  String? uid;
  int id;
  String title;
  int start;
  int end;
  int? minuteLeft;
  FastingModel({
    this.uid,
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.minuteLeft,
  });
  

  FastingModel copyWith({
    String? uid,
    int? id,
    String? title,
    int? start,
    int? end,
    int? minuteLeft,
  }) {
    return FastingModel(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      minuteLeft: minuteLeft ?? this.minuteLeft,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'id': id,
      'title': title,
      'start': start,
      'end': end,
      'minuteLeft': minuteLeft,
    };
  }

  factory FastingModel.fromMap(Map<String, dynamic> map) {
    return FastingModel(
      uid: map['uid'] != null ? map['uid'] as String : null,
      id: map['id'] as int,
      title: map['title'] as String,
      start: map['start'] as int,
      end: map['end'] as int,
      minuteLeft: map['minuteLeft'] != null ? map['minuteLeft'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FastingModel.fromJson(String source) => FastingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FastingModel(uid: $uid, id: $id, title: $title, start: $start, end: $end, minuteLeft: $minuteLeft)';
  }

  @override
  bool operator ==(covariant FastingModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.id == id &&
      other.title == title &&
      other.start == start &&
      other.end == end &&
      other.minuteLeft == minuteLeft;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      id.hashCode ^
      title.hashCode ^
      start.hashCode ^
      end.hashCode ^
      minuteLeft.hashCode;
  }
}
