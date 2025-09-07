//------------------------ third_part_packages -------------------------
import 'package:hive/hive.dart';
//----------------------------------------------------------------------

//----------------------------- hive_part ------------------------------
part 'history_entry.g.dart'; // Generated adapter part file
//----------------------------------------------------------------------

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  late String plantStatus;

  @HiveField(1)
  late double? temperature;

  @HiveField(2)
  late double? soilMoisture;

  @HiveField(3)
  late DateTime timestamp;

  // --- THIS IS THE CORRECTED CONSTRUCTOR ---
  HistoryEntry({
    required this.plantStatus,
    this.temperature,
    this.soilMoisture,
    required this.timestamp,
  });
}
