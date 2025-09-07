//----------------------------- dart_core ------------------------------
import 'dart:convert';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'package:plantcare/history_screen.dart'; // Import HistoryScreen
import 'package:plantcare/login.dart';
import 'package:plantcare/services/api_service.dart';
import 'package:plantcare/services/history_entry.dart'; // Import HistoryEntry model
import 'package:plantcare/theme/colors.dart';
import 'disease_diagnosis.dart';
//----------------------------------------------------------------------

class PlantHealthScreen extends StatefulWidget {
  final String? userName;

  const PlantHealthScreen({super.key, this.userName});

  @override
  _PlantHealthScreenState createState() => _PlantHealthScreenState();
}

class _PlantHealthScreenState extends State<PlantHealthScreen> {
  double? soilMoistureValue;
  double? temperature;
  String _plantStatus = "Healthy";

  @override
  void initState() {
    super.initState();
    // Initial data fetch when the screen loads
    _refreshData();
  }

  // --- MODIFICATION START: Updated function to refresh data and save to history ---
  Future<void> _refreshData() async {
    try {
      final responses = await Future.wait([
        ApiService.getSensorData(),
        ApiService.predictFromCamera(),
      ]);

      if (!mounted) return;

      double? newTemperature;
      double? newSoilMoisture;
      String? newPlantStatus;
      bool needsStateUpdate = false;

      // Process Sensor Data Response
      final sensorResponse = responses[0];
      if (sensorResponse.statusCode == 200) {
        final sensorData = json.decode(sensorResponse.body);
        if (sensorData.containsKey('soil_temperature_c') &&
            sensorData.containsKey('soil_moisture_percent')) {
          newTemperature = (sensorData['soil_temperature_c'] as num).toDouble();
          newSoilMoisture =
              (sensorData['soil_moisture_percent'] as num).toDouble();
          needsStateUpdate = true;
        }
      }

      // Process Plant Status Response
      final statusResponse = responses[1];
      if (statusResponse.statusCode == 200) {
        final statusData = json.decode(statusResponse.body);
        if (statusData.containsKey('class_name_clean')) {
          newPlantStatus = statusData['class_name_clean'];
          needsStateUpdate = true;
        }
      }

      // If a new status was fetched, create and save a history entry
      if (newPlantStatus != null) {
        final historyBox = Hive.box<HistoryEntry>('history');
        final newEntry = HistoryEntry(
          plantStatus: newPlantStatus,
          // Use new data, or fall back to the existing state's data for completeness
          temperature: newTemperature ?? temperature,
          soilMoisture: newSoilMoisture ?? soilMoistureValue,
          timestamp: DateTime.now(),
        );
        await historyBox.add(newEntry);
      }

      // Update the UI state once with all new data if anything changed
      if (needsStateUpdate && mounted) {
        setState(() {
          if (newPlantStatus != null) _plantStatus = newPlantStatus;
          if (newTemperature != null) temperature = newTemperature;
          if (newSoilMoisture != null) soilMoistureValue = newSoilMoisture;
        });
      }
    } catch (e) {
      print('Error refreshing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refresh data.')),
        );
      }
    }
  }
  // --- MODIFICATION END ---

  void _checkSoilMoisture(BuildContext context, double value) {
    String message;
    if (value < 30) {
      message = 'Soil moisture is LOW. Time to water!';
    } else if (value > 70) {
      message = 'Soil moisture is HIGH. Be careful not to overwater.';
    } else {
      message = 'Soil moisture is NORMAL.';
    }

    Flushbar(
      message: message,
      backgroundColor:
          value < 30
              ? AppColors.warning.shade700
              : (value > 70 ? AppColors.info.shade700 : Colors.green.shade600),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _navigateToDiagnosis() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiseaseDiagnosisScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _plantStatus = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = _plantStatus.toLowerCase().contains('healthy');
    final Color statusColor =
        isHealthy ? AppColors.primaryLight : AppColors.warning.shade800;
    final IconData statusIcon =
        isHealthy ? Icons.shield_outlined : Icons.warning_amber_rounded;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primaryLight,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xff173b1f),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/tree.jpg',
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: -25,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(statusIcon, color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _plantStatus,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.water_drop,
                            color: AppColors.info,
                          ),
                          title: const Text(
                            'Soil Moisture',
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            soilMoistureValue != null
                                ? '${soilMoistureValue!.toStringAsFixed(0)}%'
                                : 'Loading...',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap:
                              soilMoistureValue != null
                                  ? () => _checkSoilMoisture(
                                    context,
                                    soilMoistureValue!,
                                  )
                                  : null,
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.thermostat,
                            color: AppColors.warning,
                          ),
                          title: const Text(
                            'Soil Temperature',
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            temperature != null
                                ? '${temperature!.toStringAsFixed(1)}°C'
                                : 'Loading...',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToDiagnosis,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            title: const Text(
                              'Disease Diagnosis',
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                              isHealthy
                                  ? 'Check for diseases'
                                  : 'Last result: $_plantStatus',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // --- MODIFICATION: Navigate to HistoryScreen ---
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _handleLogout,
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
