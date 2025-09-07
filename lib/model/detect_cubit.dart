//----------------------------- dart_core ------------------------------
import 'dart:convert';
import 'dart:io';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:bloc/bloc.dart';
//----------------------------------------------------------------------

//--------------------------- app_local --------------------------------
import '../services/api_service.dart';
import 'model.dart';
import 'state.dart';
//----------------------------------------------------------------------

class DiseaseDetectionCubit extends Cubit<DiseaseDetectionState> {
  DiseaseDetectionCubit() : super(DiseaseInitial());

  Future<void> detectDiseaseFromCapturedImage(File imageFile) async {
    try {
      emit(DiseaseLoading());

      final response = await ApiService.predictFromImage(imageFile);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final result = DiseaseDetectionModel.fromJson(jsonData);

        // Optionally, you can save to Flask backend if you have a save API
        // await ApiService.savePrediction(result, imageFile);

        emit(DiseaseSuccess(result));
      } else {
        emit(DiseaseFailure("Prediction failed: ${response.statusCode}"));
      }
    } catch (e) {
      emit(DiseaseFailure("Error: $e"));
    }
  }
}
