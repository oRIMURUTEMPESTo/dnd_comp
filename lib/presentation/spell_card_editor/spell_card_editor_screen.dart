import 'package:dnddichas/data/models/spell_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class SpellCardEditorScreen extends StatefulWidget {
  final Spell spell;
  // Recibe el mapa de visibilidad desde la pantalla de selección
  final Map<String, bool> initialVisibility;

  const SpellCardEditorScreen({super.key, required this.spell, required this.initialVisibility});

  @override
  State<SpellCardEditorScreen> createState() => _SpellCardEditorScreenState();
}

class _SpellCardEditorScreenState extends State<SpellCardEditorScreen> {
  // Usaremos un Map para guardar la posición de cada elemento (widget).
  late Map<String, Offset> _elementPositions;
  // Nuevo mapa para controlar la visibilidad de cada elemento.
  late Map<String, bool> _elementVisibility;

  // Dimensiones de la ficha en píxeles (4.25in * 96dpi, 5.5in * 96dpi)
  static const double cardWidth = 408;
  static const double cardHeight = 864; // Aumentamos la altura a 9 pulgadas (a 96dpi)

  @override
  void initState() {
    super.initState();
    _elementVisibility = widget.initialVisibility; // Usa la visibilidad pasada
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final layoutBox = await Hive.openBox('spell_layouts');
    final spellId = widget.spell.id;

    // Cargar posiciones
    final positionsJson = layoutBox.get('${spellId}_positions');
    if (positionsJson != null) {
      final decodedPositions = jsonDecode(positionsJson) as Map<String, dynamic>;
      _elementPositions = decodedPositions.map(
        (key, value) => MapEntry(key, Offset(value['dx'] as double, value['dy'] as double)),
      );
    } else {
      // Posiciones por defecto si no hay nada guardado
      _elementPositions = {
        'name': const Offset(20, 20), 'level_school': const Offset(20, 70),
        'casting_time': const Offset(20, 100), 'range': const Offset(20, 130),
        'components': const Offset(20, 160), 'duration': const Offset(20, 190),
        'description': const Offset(20, 230), 'higher_level': const Offset(20, 400),
        'classes': const Offset(20, 450), 'damage_slot': const Offset(20, 500),
        'damage_char': const Offset(20, 580), 'source': const Offset(20, 620),
        'ritual': const Offset(300, 20), 'concentration': const Offset(250, 20),
      };
    }

    // Cargar visibilidad
    final visibilityJson = layoutBox.get('${spellId}_visibility');
    if (visibilityJson != null) {
      final decodedVisibility = jsonDecode(visibilityJson) as Map<String, dynamic>;
      _elementVisibility = decodedVisibility.map((key, value) => MapEntry(key, value as bool));
    } else {
      // Visibilidad por defecto
      // No se sobreescribe, ya se inicializó desde el widget
    }

    setState(() {});
  }

  Future<void> _saveLayout() async {
    final layoutBox = await Hive.openBox('spell_layouts');
    final spellId = widget.spell.id;

    // Guardar posiciones
    final positionsToSave = _elementPositions.map(
      (key, value) => MapEntry(key, {'dx': value.dx, 'dy': value.dy}),
    );
    await layoutBox.put('${spellId}_positions', jsonEncode(positionsToSave));

    // Guardar visibilidad
    await layoutBox.put('${spellId}_visibility', jsonEncode(_elementVisibility));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Ficha de Conjuro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Eliminar Hechizo',
            onPressed: _deleteSpell,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Diseño',
            onPressed: () async {
              await _saveLayout();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diseño guardado localmente.')));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Cambiado a SingleChildScrollView para evitar problemas de tamaño
        child: Center(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850], // Un color de fondo para la ficha
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(128),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none, // Permite que los widgets se vean fuera del Stack si se mueven
                children: [
                  _buildVisibleDraggableWidget(
                    elementKey: 'name',
                    child: _buildTextWidget(widget.spell.name, Theme.of(context).textTheme.headlineSmall),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'level_school',
                    child: _buildTextWidget(
                      'Nivel ${widget.spell.level} - ${widget.spell.school}',
                      Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'casting_time',
                    child: _buildInfoRow('Lanzamiento:', widget.spell.castingTime),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'range',
                    child: _buildInfoRow('Alcance:', widget.spell.range),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'components',
                    child: _buildInfoRow('Componentes:', widget.spell.components),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'duration',
                    child: _buildInfoRow('Duración:', widget.spell.duration),
                  ),
                  _buildVisibleDraggableWidget(
                    elementKey: 'description',
                    child: SizedBox(
                      width: cardWidth - 40, // Ancho máximo para la descripción
                      child: _buildTextWidget(widget.spell.description, Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  if (widget.spell.higherLevel.isNotEmpty)
                    _buildVisibleDraggableWidget(
                      elementKey: 'higher_level',
                      child: SizedBox(
                        width: cardWidth - 40,
                        child: _buildInfoRow('A niveles superiores:', widget.spell.higherLevel),
                      ),
                    ),
                  if (widget.spell.classes.isNotEmpty)
                    _buildVisibleDraggableWidget(
                      elementKey: 'classes',
                      child: SizedBox(
                        width: cardWidth - 40,
                        child: _buildInfoRow('Clases:', widget.spell.classes.join(', ')),
                      ),
                    ),
                  if (widget.spell.damageAtSlotLevel.isNotEmpty)
                    _buildVisibleDraggableWidget(
                      elementKey: 'damage_slot',
                      child: SizedBox(
                        width: cardWidth - 40,
                        child: _buildInfoRow('Daño por Nivel de Conjuro:', _formatMap(widget.spell.damageAtSlotLevel)),
                      ),
                    ),
                  if (widget.spell.damageAtCharacterLevel.isNotEmpty)
                    _buildVisibleDraggableWidget(
                      elementKey: 'damage_char',
                      child: SizedBox(
                        width: cardWidth - 40,
                        child: _buildInfoRow('Daño por Nivel de Personaje:', _formatMap(widget.spell.damageAtCharacterLevel)),
                      ),
                    ),
                  if (widget.spell.source.isNotEmpty)
                    _buildVisibleDraggableWidget(
                      elementKey: 'source',
                      child: _buildInfoRow('Fuente:', widget.spell.source),
                    ),
                  if (widget.spell.isRitual)
                    _buildVisibleDraggableWidget(
                      elementKey: 'ritual',
                      child: _buildTagWidget('Ritual', Colors.blueGrey),
                    ),
                  if (widget.spell.isConcentration)
                    _buildVisibleDraggableWidget(
                      elementKey: 'concentration',
                      child: _buildTagWidget('Concentración', Colors.purple),
                    ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  // Nuevo método que comprueba la visibilidad antes de construir el widget
  Widget _buildVisibleDraggableWidget({required String elementKey, required Widget child}) {
    if (_elementVisibility[elementKey] == true) {
      return _buildDraggableWidget(elementKey: elementKey, child: child);
    }
    return const SizedBox.shrink(); // Devuelve un widget vacío si no es visible
  }

  // Widget genérico para crear un elemento movible con GestureDetector
  Widget _buildDraggableWidget({required String elementKey, required Widget child}) {
    return Positioned(
      left: _elementPositions[elementKey]!.dx,
      top: _elementPositions[elementKey]!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Actualizamos la posición del elemento sumando el delta del arrastre.
            _elementPositions[elementKey] = _elementPositions[elementKey]! + details.delta;
          });
        },
        child: child,
      ),
    );
  }

  // Widget para mostrar texto simple
  Widget _buildTextWidget(String text, TextStyle? style) {
    return Text(
      text,
      style: style,
    );
  }

  // Widget para mostrar una fila de "Etiqueta: Valor"
  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // Widget para mostrar etiquetas como 'Ritual' o 'Concentración'
  Widget _buildTagWidget(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper para formatear los mapas de daño en un string legible
  String _formatMap(Map<String, String> map) {
    return map.entries.map((e) => 'Nivel ${e.key}: ${e.value}').join('\n');
  }

  Future<void> _deleteSpell() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Hechizo'),
          content: const Text('¿Estás seguro de que quieres eliminar este hechizo? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () async {
                // 1. Eliminar de Hive
                final spellBox = Hive.box<Spell>('spells');
                await spellBox.delete(widget.spell.id);

                // 2. Eliminar de Firestore
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('spells')
                      .doc(widget.spell.id)
                      .delete();
                }

                if (!mounted) return;
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
