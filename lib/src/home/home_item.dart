/// A placeholder class that represents an entity or model.
class SampleItem {
  const SampleItem(this.id);

  final int id;
}

class HeartRateModel {
  int? heartRate;

  HeartRateModel({this.heartRate});

  HeartRateModel.fromJson(Map<String, dynamic> json) {
    heartRate = json['heart_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['heart_rate'] = heartRate;
    return data;
  }
}

