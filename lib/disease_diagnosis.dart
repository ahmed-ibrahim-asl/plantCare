//----------------------------- dart_core ------------------------------
import 'dart:io';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantcare/theme/colors.dart';
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'LiveFeedScreen.dart';
import 'model/detect_cubit.dart';
import 'model/state.dart';
import 'services/api_service.dart';
//----------------------------------------------------------------------

class DiseaseDiagnosisScreen extends StatefulWidget {
  const DiseaseDiagnosisScreen({super.key});

  @override
  State<DiseaseDiagnosisScreen> createState() => _DiseaseDiagnosisScreenState();
}

class _DiseaseDiagnosisScreenState extends State<DiseaseDiagnosisScreen> {
  File? capturedImage;
  bool isLoadingImage = false;

  void fetchImageAndPredict() async {
    setState(() => isLoadingImage = true);

    final imageFile = await ApiService.captureImageAndSave();

    if (imageFile != null) {
      setState(() {
        capturedImage = imageFile;
        isLoadingImage = false;
      });

      // Send the captured image to the Cubit for prediction
      await context
          .read<DiseaseDetectionCubit>()
          .detectDiseaseFromCapturedImage(capturedImage!);
    } else {
      setState(() => isLoadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to capture image.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PlantCare AI',
          style: TextStyle(color: AppColors.primaryDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.primaryDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.live_tv, color: AppColors.primaryDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveFeedScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<DiseaseDetectionCubit, DiseaseDetectionState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disease Diagnosis',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: fetchImageAndPredict,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child:
                        isLoadingImage
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryDark,
                              ),
                            )
                            : capturedImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                capturedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to capture image',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: 20),
                if (state is DiseaseLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryDark,
                    ),
                  ),
                if (state is DiseaseSuccess) ...[
                  Text(
                    state.result.diseaseClean,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.result.recommendation,
                    style: const TextStyle(fontSize: 18, height: 1.4),
                  ),
                ],
                if (state is DiseaseFailure)
                  Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // This is the correct logic to send the result back
                          if (state is DiseaseSuccess) {
                            Navigator.pop(context, state.result.diseaseClean);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
