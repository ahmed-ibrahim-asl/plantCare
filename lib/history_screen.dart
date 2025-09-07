//------------------------ third_part_packages -------------------------
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'package:plantcare/services/history_entry.dart';
import 'package:plantcare/theme/colors.dart';
//----------------------------------------------------------------------

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box<HistoryEntry>('history');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnosis History',
          style: TextStyle(
            color: Color(0xff173b1f),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xff173b1f)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.error,
            ),
            onPressed: () {
              // Show a confirmation dialog before clearing
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text(
                      'Clear History?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Are you sure you want to delete all history records? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          historyBox.clear();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box<HistoryEntry> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Display newest records first
          final sortedEntries =
              box.values.toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final isHealthy = entry.plantStatus.toLowerCase().contains(
                'healthy',
              );

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    isHealthy
                        ? Icons.shield_outlined
                        : Icons.warning_amber_rounded,
                    color: isHealthy ? AppColors.success : AppColors.warning,
                    size: 36,
                  ),
                  title: Text(
                    entry.plantStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Temp: ${entry.temperature?.toStringAsFixed(1) ?? 'N/A'}°C, '
                    'Moisture: ${entry.soilMoisture?.toStringAsFixed(0) ?? 'N/A'}%',
                  ),
                  trailing: Text(
                    DateFormat('MMM d, hh:mm a').format(entry.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
