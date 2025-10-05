import 'package:dnddichas/data/models/character_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CharacterSheetScreen extends StatefulWidget {
  final String characterId;

  const CharacterSheetScreen({super.key, required this.characterId});

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  late Box<Character> _characterBox;
  late Character _character;
  final _formKey = GlobalKey<FormState>();

  // Controladores para todos los campos
  late final TextEditingController _nameController;
  late final TextEditingController _campaignNameController;
  late final TextEditingController _classController;
  late final TextEditingController _raceController;
  late final TextEditingController _levelController;
  late final TextEditingController _backgroundController;
  late final TextEditingController _alignmentController;
  late final TextEditingController _strController;
  late final TextEditingController _dexController;
  late final TextEditingController _conController;
  late final TextEditingController _intController;
  late final TextEditingController _wisController;
  late final TextEditingController _chaController;

  @override
  void initState() {
    super.initState();
    _characterBox = Hive.box<Character>('characters');
    // Es importante clonar el personaje para no modificar el original hasta guardar.
    final sourceCharacter = _characterBox.get(widget.characterId)!;
    _character = Character(
      id: sourceCharacter.id,
      name: sourceCharacter.name,
      characterClass: sourceCharacter.characterClass,
      level: sourceCharacter.level,
      race: sourceCharacter.race,
      background: sourceCharacter.background,
      alignment: sourceCharacter.alignment,
      strength: sourceCharacter.strength,
      dexterity: sourceCharacter.dexterity,
      constitution: sourceCharacter.constitution,
      intelligence: sourceCharacter.intelligence,
      wisdom: sourceCharacter.wisdom,
      charisma: sourceCharacter.charisma,
      campaignName: sourceCharacter.campaignName,
    );

    _nameController = TextEditingController(text: _character.name);
    _campaignNameController = TextEditingController(text: _character.campaignName);
    _classController = TextEditingController(text: _character.characterClass);
    _raceController = TextEditingController(text: _character.race);
    _levelController = TextEditingController(text: _character.level.toString());
    _backgroundController = TextEditingController(text: _character.background);
    _alignmentController = TextEditingController(text: _character.alignment);
    _strController = TextEditingController(text: _character.strength.toString());
    _dexController = TextEditingController(text: _character.dexterity.toString());
    _conController = TextEditingController(text: _character.constitution.toString());
    _intController = TextEditingController(text: _character.intelligence.toString());
    _wisController = TextEditingController(text: _character.wisdom.toString());
    _chaController = TextEditingController(text: _character.charisma.toString());
  }

  @override
  void dispose() {
    // Liberamos todos los controladores
    _nameController.dispose();
    _campaignNameController.dispose();
    _classController.dispose();
    _raceController.dispose();
    _levelController.dispose();
    _backgroundController.dispose();
    _alignmentController.dispose();
    _strController.dispose();
    _dexController.dispose();
    _conController.dispose();
    _intController.dispose();
    _wisController.dispose();
    _chaController.dispose();
    super.dispose();
  }

  void _saveCharacter() {
    if (_formKey.currentState?.validate() ?? false) {
      // Actualizamos el objeto _character con los datos del formulario
      _character.name = _nameController.text;
      _character.campaignName = _campaignNameController.text;
      _character.characterClass = _classController.text;
      _character.race = _raceController.text;
      _character.level = int.tryParse(_levelController.text) ?? 1;
      _character.background = _backgroundController.text;
      _character.alignment = _alignmentController.text;
      _character.strength = int.tryParse(_strController.text) ?? 10;
      _character.dexterity = int.tryParse(_dexController.text) ?? 10;
      _character.constitution = int.tryParse(_conController.text) ?? 10;
      _character.intelligence = int.tryParse(_intController.text) ?? 10;
      _character.wisdom = int.tryParse(_wisController.text) ?? 10;
      _character.charisma = int.tryParse(_chaController.text) ?? 10;

      // Guardamos el personaje actualizado en la base de datos de Hive
      _characterBox.put(_character.id, _character);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personaje guardado.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_character.name.isEmpty ? 'Nuevo Personaje' : 'Editar Personaje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Personaje',
            onPressed: _saveCharacter,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('Información Básica'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Personaje'),
              validator: (value) => (value?.isEmpty ?? true) ? 'El nombre es obligatorio' : null,
            ),
            TextFormField(
              controller: _campaignNameController,
              decoration: const InputDecoration(labelText: 'Nombre de la Partida'),
            ),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _classController, decoration: const InputDecoration(labelText: 'Clase'))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _raceController, decoration: const InputDecoration(labelText: 'Especie'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _levelController, decoration: const InputDecoration(labelText: 'Nivel'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _alignmentController, decoration: const InputDecoration(labelText: 'Alineamiento'))),
              ],
            ),
            TextFormField(
              controller: _backgroundController,
              decoration: const InputDecoration(labelText: 'Trasfondo'),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Estadísticas de Atributo'),
            Row(children: [
              Expanded(child: _buildStatField('FUE', _strController)),
              Expanded(child: _buildStatField('DES', _dexController)),
              Expanded(child: _buildStatField('CON', _conController)),
            ]),
            Row(children: [
              Expanded(child: _buildStatField('INT', _intController)),
              Expanded(child: _buildStatField('SAB', _wisController)),
              Expanded(child: _buildStatField('CAR', _chaController)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}