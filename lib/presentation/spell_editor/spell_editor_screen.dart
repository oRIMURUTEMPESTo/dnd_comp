import 'package:dnddichas/data/models/spell_model.dart';
import 'package:dnddichas/logic/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const List<String> dndSchoolsOfMagic = [
  'Abjuración',
  'Adivinación',
  'Conjuración',
  'Encantamiento',
  'Evocación',
  'Ilusión',
  'Nigromancia',
  'Transmutación',
];

// Mapeo de nombres en inglés (de la API) a español (para la UI)
const Map<String, String> schoolTranslationMap = {
  'Abjuration': 'Abjuración',
  'Divination': 'Adivinación',
  'Conjuration': 'Conjuración',
  'Enchantment': 'Encantamiento',
  'Evocation': 'Evocación',
  'Illusion': 'Ilusión',
  'Necromancy': 'Nigromancia',
  'Transmutation': 'Transmutación',
};

class SpellEditorScreen extends ConsumerStatefulWidget {
  /// Si el hechizo es nulo, estamos creando uno nuevo.
  /// Si se proporciona un hechizo, estamos editando uno existente.
  final Spell? spell;

  const SpellEditorScreen({super.key, this.spell});

  @override
  ConsumerState<SpellEditorScreen> createState() => _SpellEditorScreenState();
}

class _SpellEditorScreenState extends ConsumerState<SpellEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _levelController;
  late final TextEditingController _castingTimeController;
  late final TextEditingController _rangeController;
  late final TextEditingController _componentsController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _higherLevelController;
  late final TextEditingController _sourceController;
  late bool _isRitual;
  late bool _isConcentration;

  String? _selectedSchool;
  bool get _isEditing => widget.spell != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.spell?.name ?? '');
    _levelController =
        TextEditingController(text: widget.spell?.level.toString() ?? '0');
    _castingTimeController = TextEditingController(text: widget.spell?.castingTime ?? '');
    _rangeController = TextEditingController(text: widget.spell?.range ?? '');
    _componentsController = TextEditingController(text: widget.spell?.components ?? '');
    _durationController = TextEditingController(text: widget.spell?.duration ?? '');
    _descriptionController = TextEditingController(text: widget.spell?.description ?? '');
    _higherLevelController = TextEditingController(text: widget.spell?.higherLevel ?? '');
    _sourceController = TextEditingController(text: widget.spell?.source ?? '');
    _isRitual = widget.spell?.isRitual ?? false;
    _isConcentration = widget.spell?.isConcentration ?? false;
    
    // Si estamos editando y el hechizo tiene una escuela válida, la preseleccionamos.
    // Usamos el mapa para encontrar el nombre en español correspondiente.
    if (_isEditing) {
      final schoolInSpanish = schoolTranslationMap[widget.spell!.school] ?? widget.spell!.school;
      if (dndSchoolsOfMagic.contains(schoolInSpanish)) {
        _selectedSchool = schoolInSpanish;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _castingTimeController.dispose();
    _rangeController.dispose();
    _componentsController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _higherLevelController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _saveSpell() {
    debugPrint('[UI] Intentando guardar hechizo...');
    if (_formKey.currentState?.validate() ?? false) {
      final spellToSave = Spell(
        id: widget.spell?.id ?? const Uuid().v4(),
        name: _nameController.text,
        level: int.tryParse(_levelController.text) ?? 0,
        school: _selectedSchool ?? '',
        castingTime: _castingTimeController.text,
        range: _rangeController.text,
        components: _componentsController.text,
        duration: _durationController.text,
        description: _descriptionController.text,
        isRitual: _isRitual,
        isConcentration: _isConcentration,
        higherLevel: _higherLevelController.text,
        damageAtSlotLevel: widget.spell?.damageAtSlotLevel ?? {},
        damageAtCharacterLevel: widget.spell?.damageAtCharacterLevel ?? {},
        source: _sourceController.text,
      );

      ref.read(localSpellRepositoryProvider).saveSpell(spellToSave);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _deleteSpell() {
    if (!_isEditing) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${widget.spell!.name}"? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                ref.read(localSpellRepositoryProvider).deleteSpell(widget.spell!.id);
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Vuelve a la lista de hechizos
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Hechizo' : 'Nuevo Hechizo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSpell,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar Hechizo',
              onPressed: _deleteSpell,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Hechizo'),
              validator: (value) => (value?.isEmpty ?? true) ? 'El nombre no puede estar vacío' : null,
            ),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(labelText: 'Fuente (Libro)'),
            ),
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Nivel'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSchool,
              decoration: const InputDecoration(
                labelText: 'Escuela de Magia',
                border: OutlineInputBorder(),
              ),
              items: dndSchoolsOfMagic.map((String school) {
                return DropdownMenuItem<String>(
                  value: school,
                  child: Text(school),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSchool = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _castingTimeController,
              decoration: const InputDecoration(labelText: 'Tiempo de Lanzamiento'),
            ),
            TextFormField(
              controller: _rangeController,
              decoration: const InputDecoration(labelText: 'Alcance'),
            ),
            TextFormField(
              controller: _componentsController,
              decoration: const InputDecoration(labelText: 'Componentes (V, S, M)'),
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duración'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ritual'),
              value: _isRitual,
              onChanged: (bool value) {
                setState(() {
                  _isRitual = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Concentración'),
              value: _isConcentration,
              onChanged: (bool value) {
                setState(() {
                  _isConcentration = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _higherLevelController,
              decoration: const InputDecoration(
                labelText: 'A niveles superiores',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            // Mostramos el escalado de daño por nivel de conjuro si existe
            if (widget.spell != null && widget.spell!.level >= 1) ...[
              const SizedBox(height: 24),
              TextFormField(
                readOnly: true,
                initialValue: (widget.spell!.damageAtSlotLevel.isNotEmpty)
                    ? widget.spell!.damageAtSlotLevel.entries
                        .map((entry) => 'Nivel ${entry.key}: ${entry.value}')
                        .join('\n')
                    : 'Este hechizo no tiene un escalado de daño directo por nivel de conjuro.',
                maxLines: null, // Permite que el campo crezca
                decoration: const InputDecoration(
                  labelText: 'Daño por Nivel de Conjuro',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (widget.spell?.damageAtCharacterLevel.isNotEmpty ?? false) ...[
              const SizedBox(height: 24),
              TextFormField(
                readOnly: true,
                initialValue: widget.spell!.damageAtCharacterLevel.entries
                    .map((entry) => 'A nivel ${entry.key}: ${entry.value}')
                    .join('\n'),
                maxLines: null, // Permite que el campo crezca
                decoration: const InputDecoration(
                  labelText: 'Daño por Nivel de Personaje',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}