import 'package:dnddichas/logic/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a Fichas D&D'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login), // Idealmente un icono de Google
          label: const Text('Iniciar sesión con Google'),
          onPressed: () async {
            // Guardar el ScaffoldMessenger antes de la operación asíncrona
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            try {
              await ref.read(authRepositoryProvider).signInWithGoogle();
              // La navegación es automática gracias al AuthGate
            } catch (e, stackTrace) {
              // Usar la referencia guardada
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Error al iniciar sesión: $e')),
              );
              // Imprime el error en la terminal para depuración
              print('Error durante el inicio de sesión con Google: $e');
              print('Stack trace: $stackTrace');
            }
          },
        ),
      ),
    );
  }
}