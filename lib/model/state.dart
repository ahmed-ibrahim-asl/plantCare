// cubit/disease_detection_state.dart

import 'model.dart';

abstract class DiseaseDetectionState {}

class DiseaseInitial extends DiseaseDetectionState {}

class DiseaseLoading extends DiseaseDetectionState {}

class DiseaseSuccess extends DiseaseDetectionState {
  final DiseaseDetectionModel result;
  DiseaseSuccess(this.result);
}

class DiseaseFailure extends DiseaseDetectionState {
  final String error;
  DiseaseFailure(this.error);
}
