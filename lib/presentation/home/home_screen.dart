import 'package:dnddichas/logic/providers.dart';
import 'package:dnddichas/presentation/spell_card_editor/spell_component_selector_screen.dart';
import 'package:dnddichas/presentation/spell_card_viewer/spell_card_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa el nuevo StreamProvider para obtener la lista de hechizos de forma reactiva.
    final spellsAsyncValue = ref.watch(spellsStreamProvider);
    return Scaffold( // Mantenemos el Scaffold para tener un fondo consistente
      appBar: AppBar(title: const Text('Mis Hechizos')),
      body: spellsAsyncValue.when( // Usa .when para manejar los estados de carga, error y datos del stream.
        data: (spells) {
          if (spells.isEmpty) {
            return const Center(child: Text('Aún no tienes hechizos. ¡Crea uno!'));
          }
          return ListView.builder(
            itemCount: spells.length,
            itemBuilder: (context, index) {
              final spell = spells[index];
              return ListTile(
                // Un toque normal abre la vista de solo lectura
                onTap: () {
                  debugPrint('[UI] Navegando para ver el hechizo: ${spell.name}');
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SpellCardViewerScreen(spell: spell),
                  ));
                },
                // Una pulsación larga abre el editor
                onLongPress: () {
                  debugPrint('[UI] Navegando para editar el hechizo: ${spell.name}');
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SpellComponentSelectorScreen(spell: spell),
                  ));
                },
                title: Text(spell.name),
                subtitle: Text('Nivel ${spell.level} - ${spell.school}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}