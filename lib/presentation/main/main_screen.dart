import 'package:dnddichas/presentation/home/home_screen.dart';
import 'package:dnddichas/presentation/profile/profile_screen.dart';
import 'package:dnddichas/presentation/srd_browser/srd_browser_screen.dart';
import 'package:dnddichas/presentation/character_sheet/character_list_screen.dart';
import 'package:dnddichas/presentation/character_sheet/character_sheet_screen.dart';
import 'package:dnddichas/data/models/character_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CharacterListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    if (_selectedIndex == 0) {
      // Pestaña de Hechizos
      debugPrint('[UI] Navegando a la pantalla de búsqueda de hechizos.');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SrdBrowserScreen(),
      ));
    } else if (_selectedIndex == 1) {
      // Pestaña de Personajes
      debugPrint('[UI] Creando un nuevo personaje.');
      final characterBox = Hive.box<Character>('characters');
      final newCharacter = Character(
        id: const Uuid().v4(),
        name: 'Nuevo Personaje',
      );
      characterBox.put(newCharacter.id, newCharacter);

      // Navegar directamente a la pantalla de edición del nuevo personaje
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CharacterSheetScreen(characterId: newCharacter.id),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex != 2 // No mostrar en Perfil
          ? FloatingActionButton(
              onPressed: () {
                _onFabPressed();
              },
              tooltip: _selectedIndex == 0 ? 'Buscar Hechizo' : 'Crear Personaje',
              child: _selectedIndex == 0 ? const Icon(Icons.auto_stories) : const Icon(Icons.person_add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Hechizos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Personajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}