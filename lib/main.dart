//-------------------------- flutter_core ------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
//----------------------------------------------------------------------

//--------------------------- app_local --------------------------------
import 'model/detect_cubit.dart';
import 'services/history_entry.dart'; // history model
import 'splash.dart';
import 'login.dart';
//----------------------------------------------------------------------

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock screen orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Initialize Hive for local storage
  await Hive.initFlutter();

  // --- ADDITION b: Register the adapter for your history model
  Hive.registerAdapter(HistoryEntryAdapter());

  // 4. Open all the Hive boxes you will be using
  await Hive.openBox('auth');
  await Hive.openBox<HistoryEntry>(
    'history',
  ); // --- ADDITION c: Open the new history box

  // 5. Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => DiseaseDetectionCubit())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {'/login': (context) => const LoginScreen()},
      ),
    );
  }
}
