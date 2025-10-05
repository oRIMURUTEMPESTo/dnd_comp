import 'package:dnddichas/data/models/spell_model.dart';
import 'package:dnddichas/presentation/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnddichas/logic/providers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dnddichas/data/models/character_model.dart';
import 'firebase_options.dart'; // Importa las opciones generadas por FlutterFire CLI

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase (descomenta cuando lo hayas configurado)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(SpellAdapter());
  Hive.registerAdapter(CharacterAdapter()); // <-- AÑADIR ESTA LÍNEA
  await Hive.openBox<Character>('characters');
  await Hive.openBox<Spell>('spells'); // Abre la "caja" de hechizos

  // Envuelve la app en un ProviderScope para que Riverpod funcione
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leemos el provider aquí para que se inicialice y empiece a escuchar.
    ref.watch(syncControllerProvider);

    return MaterialApp(
      title: 'Fichas D&D Interactivas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(), // El AuthGate decide la pantalla inicial
    );
  }
}