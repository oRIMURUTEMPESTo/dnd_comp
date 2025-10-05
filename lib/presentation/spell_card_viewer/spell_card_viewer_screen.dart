import 'package:dnddichas/data/models/spell_model.dart';
import 'package:dnddichas/presentation/spell_card_editor/spell_component_selector_screen.dart';
import 'package:flutter/material.dart';

// SOLUCIÓN 2.1: Importar para usar jsonDecode
import 'dart:convert'; 
// SOLUCIÓN 2.2: Importar para usar Hive
import 'package:hive/hive.dart'; 

// SOLUCIÓN 1: La clase principal DEBE extender StatefulWidget
class SpellCardViewerScreen extends StatefulWidget {
  final Spell spell;

  const SpellCardViewerScreen({super.key, required this.spell});

  // Dimensiones de la ficha (las mismas que en el editor)
  // Se mantienen como 'static const' para que la clase State las acceda
  static const double cardWidth = 408;
  static const double cardHeight = 864;

  @override
  // SOLUCIÓN 1: createState() ahora está correctamente implementado en StatefulWidget
  State<SpellCardViewerScreen> createState() => _SpellCardViewerScreenState();
}

// La clase de estado está bien definida, pero ahora accede a las variables estáticas
class _SpellCardViewerScreenState extends State<SpellCardViewerScreen> {
  Map<String, Offset> _elementPositions = {};
  Map<String, bool> _elementVisibility = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    // Hive.openBox y jsonDecode ahora funcionan gracias a las importaciones
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
      _elementVisibility = _elementPositions.map((key, value) => MapEntry(key, true));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se accede a las variables estáticas usando el nombre de la clase
    const cardWidth = SpellCardViewerScreen.cardWidth;
    const cardHeight = SpellCardViewerScreen.cardHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spell.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Ficha',
            onPressed: () {
              // Reemplazamos la vista actual por el editor
              Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SpellComponentSelectorScreen(spell: widget.spell),
                  ))
                  .then((_) => _loadLayout()); // Recarga el layout al volver del editor
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              // Advertencia de withOpacity: Se mantuvo, ya que es estándar para Color de Flutter.
              BoxShadow(
                color: Colors.black.withAlpha(128),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    _buildVisibleWidget(
                      elementKey: 'name',
                      child: _buildTextWidget(widget.spell.name, Theme.of(context).textTheme.headlineSmall),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'level_school',
                      child: _buildTextWidget(
                        'Nivel ${widget.spell.level} - ${widget.spell.school}',
                        Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'casting_time',
                      child: _buildInfoRow('Lanzamiento:', widget.spell.castingTime),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'range',
                      child: _buildInfoRow('Alcance:', widget.spell.range),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'components',
                      child: _buildInfoRow('Componentes:', widget.spell.components),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'duration',
                      child: _buildInfoRow('Duración:', widget.spell.duration),
                    ),
                    _buildVisibleWidget(
                      elementKey: 'description',
                      child: SizedBox(
                        // Acceso a cardWidth corregido
                        width: cardWidth - 40,
                        child: _buildTextWidget(widget.spell.description, Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                    if (widget.spell.higherLevel.isNotEmpty)
                      _buildVisibleWidget(
                        elementKey: 'higher_level',
                        child: SizedBox(
                          // Acceso a cardWidth corregido
                          width: cardWidth - 40,
                          child: _buildInfoRow('A niveles superiores:', widget.spell.higherLevel),
                        ),
                      ),
                    if (widget.spell.classes.isNotEmpty)
                      _buildVisibleWidget(
                        elementKey: 'classes',
                        child: SizedBox(
                          // Acceso a cardWidth corregido
                          width: cardWidth - 40,
                          child: _buildInfoRow('Clases:', widget.spell.classes.join(', ')),
                        ),
                      ),
                    if (widget.spell.damageAtSlotLevel.isNotEmpty)
                      _buildVisibleWidget(
                        elementKey: 'damage_slot',
                        child: SizedBox(
                          // Acceso a cardWidth corregido
                          width: cardWidth - 40,
                          child: _buildInfoRow('Daño por Nivel de Conjuro:', _formatMap(widget.spell.damageAtSlotLevel)),
                        ),
                      ),
                    if (widget.spell.damageAtCharacterLevel.isNotEmpty)
                      _buildVisibleWidget(
                        elementKey: 'damage_char',
                        child: SizedBox(
                          // Acceso a cardWidth corregido
                          width: cardWidth - 40,
                          child: _buildInfoRow('Daño por Nivel de Personaje:', _formatMap(widget.spell.damageAtCharacterLevel)),
                        ),
                      ),
                    if (widget.spell.source.isNotEmpty)
                      _buildVisibleWidget(
                        elementKey: 'source',
                        child: _buildInfoRow('Fuente:', widget.spell.source),
                      ),
                    if (widget.spell.isRitual)
                      _buildVisibleWidget(
                        elementKey: 'ritual',
                        child: _buildTagWidget('Ritual', Colors.blueGrey),
                      ),
                    if (widget.spell.isConcentration)
                      _buildVisibleWidget(
                        elementKey: 'concentration',
                        child: _buildTagWidget('Concentración', Colors.purple),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildVisibleWidget({required String elementKey, required Widget child}) {
    if (_elementVisibility[elementKey] ?? false) {
      final position = _elementPositions[elementKey] ?? const Offset(0, 0);
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: child,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextWidget(String text, TextStyle? style) => Text(text, style: style);

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

  Widget _buildTagWidget(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  String _formatMap(Map<String, String> map) {
    return map.entries.map((e) => 'Nivel ${e.key}: ${e.value}').join('\n');
  }
}