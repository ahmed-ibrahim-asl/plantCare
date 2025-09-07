class DiseaseDetectionModel {
  final String diseaseClass;
  final String diseaseClean;
  final String status;
  final String recommendation;

  DiseaseDetectionModel({
    required this.diseaseClass,
    required this.diseaseClean,
    required this.status,
    required this.recommendation,
  });

  factory DiseaseDetectionModel.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionModel(
      diseaseClass: json['class_name_raw'] ?? 'Unknown',
      diseaseClean: json['class_name_clean'] ?? 'Unknown',
      status: json['status'] ?? '',
      recommendation: json['recommendation'] ?? 'No Recommendation',
    );
  }
}
