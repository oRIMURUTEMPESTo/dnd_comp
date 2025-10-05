import 'package:dnddichas/data/models/spell_model.dart';
import 'package:dnddichas/presentation/spell_card_editor/spell_card_editor_screen.dart';
import 'package:flutter/material.dart';

class SpellComponentSelectorScreen extends StatefulWidget {
  final Spell spell;

  const SpellComponentSelectorScreen({super.key, required this.spell});

  @override
  State<SpellComponentSelectorScreen> createState() => _SpellComponentSelectorScreenState();
}

class _SpellComponentSelectorScreenState extends State<SpellComponentSelectorScreen> {
  // Mapa para mantener el estado de los checkboxes
  late Map<String, bool> _selectedComponents;

  // Mapa para los nombres legibles de los componentes
  final Map<String, String> _componentLabels = {
    'name': 'Nombre',
    'level_school': 'Nivel y Escuela',
    'casting_time': 'Tiempo de Lanzamiento',
    'range': 'Alcance',
    'components': 'Componentes',
    'duration': 'Duración',
    'description': 'Descripción',
    'higher_level': 'A Niveles Superiores',
    'classes': 'Clases',
    'damage_slot': 'Daño por Nivel de Conjuro',
    'damage_char': 'Daño por Nivel de Personaje',
    'source': 'Fuente',
    'ritual': 'Etiqueta de Ritual',
    'concentration': 'Etiqueta de Concentración',
  };

  @override
  void initState() {
    super.initState();
    // Inicializa todos los componentes como seleccionados por defecto
    _selectedComponents = {
      'name': true,
      'level_school': true,
      'casting_time': true,
      'range': true,
      'components': true,
      'duration': true,
      'description': true,
      'higher_level': true,
      'classes': true,
      'damage_slot': true,
      'damage_char': true,
      'source': true,
      'ritual': true,
      'concentration': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Componentes'),
      ),
      body: ListView(
        children: _componentLabels.keys.map((key) {
          return CheckboxListTile(
            title: Text(_componentLabels[key]!),
            value: _selectedComponents[key],
            onChanged: (bool? value) {
              setState(() {
                _selectedComponents[key] = value!;
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega al editor, pasando los componentes seleccionados
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SpellCardEditorScreen(
                spell: widget.spell,
                initialVisibility: _selectedComponents,
              ),
            ),
          );
        },
        label: const Text('Ir al Editor'),
        icon: const Icon(Icons.edit),
      ),
    );
  }
}