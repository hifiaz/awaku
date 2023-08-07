// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FastingModel {
  int id;
  String title;
  int start;
  int end;
  FastingModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  FastingModel copyWith({
    int? id,
    String? title,
    int? start,
    int? end,
  }) {
    return FastingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'start': start,
      'end': end,
    };
  }

  factory FastingModel.fromMap(Map<String, dynamic> map) {
    return FastingModel(
      id: map['id'] as int,
      title: map['title'] as String,
      start: map['start'] as int,
      end: map['end'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FastingModel.fromJson(String source) => FastingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FastingModel(id: $id, title: $title, start: $start, end: $end)';
  }

  @override
  bool operator ==(covariant FastingModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.start == start &&
      other.end == end;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      start.hashCode ^
      end.hashCode;
  }
}
