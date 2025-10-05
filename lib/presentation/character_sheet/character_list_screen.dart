import 'package:dnddichas/data/models/character_model.dart';
import 'package:dnddichas/presentation/character_sheet/character_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  late Box<Character> _characterBox;

  @override
  void initState() {
    super.initState();
    _characterBox = Hive.box<Character>('characters');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Personajes'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _characterBox.listenable(),
        builder: (context, Box<Character> box, _) {
          final characters = box.values.toList();
          if (characters.isEmpty) {
            return const Center(
              child: Text('Aún no tienes personajes. ¡Crea uno!'),
            );
          }
          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return ListTile(
                title: Text(character.name),
                subtitle: Text('Nivel ${character.level} ${character.characterClass}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CharacterSheetScreen(characterId: character.id),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}