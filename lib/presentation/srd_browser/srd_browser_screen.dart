import 'dart:convert';
import 'package:dnddichas/data/models/spell_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SrdBrowserScreen extends StatefulWidget {
  const SrdBrowserScreen({super.key});

  @override
  State<SrdBrowserScreen> createState() => _SrdBrowserScreenState();
}

class _SrdBrowserScreenState extends State<SrdBrowserScreen> {
  List<Spell> _allSpells = [];
  List<Spell> _filteredSpells = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  int? _selectedLevel;
  String? _selectedSchool;
  String? _selectedSource;
  List<String> _allSources = [];

  final List<String> dndSchoolsOfMagic = const [
    'Abjuración',
    'Conjuración',
    'Adivinación',
    'Encantamiento',
    'Evocación',
    'Ilusión',
    'Nigromancia',
    'Transmutación',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpellsFromAsset();
    _searchController.addListener(() {
      _filterSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpellsFromAsset() async {
    debugPrint('[SRD] Cargando hechizos desde assets...');
    final List<Spell> allSpells = [];

    // Iteramos de nivel 0 a 9 para cargar todos los archivos
    for (int i = 0; i <= 9; i++) {
      try {
        final assetPath = 'assets/level$i.json';
        debugPrint('[SRD] Cargando $assetPath');
        final String jsonString = await rootBundle.loadString(assetPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        allSpells.addAll(jsonList.map((json) => Spell.fromJson(json)));
      } catch (e) {
        debugPrint('[SRD] No se encontró el archivo para el nivel $i, continuando...');
      }
    }
    
    // Ordenamos los hechizos por nivel y luego por nombre
    allSpells.sort((a, b) {
      int levelComp = a.level.compareTo(b.level);
      if (levelComp != 0) return levelComp;
      return a.name.compareTo(b.name);
    });

    // Extraemos las fuentes (libros) únicas de todos los hechizos cargados
    final sources = allSpells.map((spell) => spell.source).toSet();
    sources.removeWhere((source) => source.isEmpty); // Quitamos las fuentes vacías
    final sortedSources = sources.toList()..sort();

    setState(() {
      _allSpells = allSpells;
      _filteredSpells = allSpells;
      _isLoading = false;
      _allSources = sortedSources;
    });
    debugPrint('[SRD] Fuentes encontradas: $_allSources');
    debugPrint('[SRD] ${_allSpells.length} hechizos cargados y ordenados.');
  }

  void _filterSpells() {
    List<Spell> tempSpells = _allSpells;
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      tempSpells = tempSpells.where((spell) => spell.name.toLowerCase().contains(query)).toList();
    }
    if (_selectedLevel != null) {
      tempSpells = tempSpells.where((spell) => spell.level == _selectedLevel).toList();
    }
    if (_selectedSchool != null) {
      tempSpells = tempSpells.where((spell) => spell.school == _selectedSchool).toList();
    }
    if (_selectedSource != null) {
      tempSpells = tempSpells.where((spell) => spell.source == _selectedSource).toList();
    }

    setState(() {
      _filteredSpells = tempSpells;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Hechizo desde SRD'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) :
          // Usamos un ListView para que toda la pantalla sea desplazable
          ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombre',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedLevel,
                          hint: const Text('Nivel'),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedLevel = value == -1 ? null : value;
                              _filterSpells();
                            });
                          },
                          items: [
                            const DropdownMenuItem<int>(value: -1, child: Text('Todos los niveles')),
                            ...List.generate(10, (index) => DropdownMenuItem(value: index, child: Text('Nivel $index')))
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSchool,
                          hint: const Text('Escuela'),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedSchool = value == 'TODAS' ? null : value;
                              _filterSpells();
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(value: 'TODAS', child: Text('Todas las escuelas')),
                            ...dndSchoolsOfMagic.map((school) => DropdownMenuItem(value: school, child: Text(school)))
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpiar filtros',
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedLevel = null;
                            _selectedSchool = null;
                            _selectedSource = null;
                            _filterSpells();
                          });
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSource,
                    hint: const Text('Fuente (Libro)'),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSource = value == 'TODAS' ? null : value;
                        _filterSpells();
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(value: 'TODAS', child: Text('Todas las fuentes')),
                      ..._allSources.map((source) => DropdownMenuItem(value: source, child: Text(source)))
                    ],
                  ),
                ),
                // Mostramos la lista de hechizos o un mensaje si está vacía
                if (_filteredSpells.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No se encontraron hechizos con esos filtros.')),
                  )
                else
                  ..._filteredSpells.map((spell) => 
                    ListTile(
                      title: Text(spell.name),
                      subtitle: Text('Nivel ${spell.level} - ${spell.school}'),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () async {
                        // 1. Guardar en Hive
                        final spellBox = Hive.box<Spell>('spells');
                        await spellBox.put(spell.id, spell);

                        // 2. Guardar en Firestore
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('spells')
                              .doc(spell.id)
                              .set(spell.toJson());
                        }

                        // 3. Mostrar confirmación y cerrar
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${spell.name} añadido a tu libro de hechizos.')),
                        );
                        Navigator.of(context).pop();
                      },
                    )
                  ),
              ],
            ),
    );
  }
}