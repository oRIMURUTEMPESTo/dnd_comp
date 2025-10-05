import 'dart:io';
import 'package:dnddichas/data/models/character_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final ImagePicker _picker = ImagePicker();

  // Controladores para todos los campos
  late final TextEditingController _nameController;
  late final TextEditingController _campaignNameController;
  late final TextEditingController _levelController;
  late final TextEditingController _alignmentController;
  late final TextEditingController _strController;
  late final TextEditingController _dexController;
  late final TextEditingController _conController;
  late final TextEditingController _intController;
  late final TextEditingController _wisController;
  late final TextEditingController _chaController;

  final List<String> _classes = ['Bárbaro', 'Bardo', 'Clérigo', 'Druida', 'Guerrero', 'Monje', 'Paladín', 'Explorador', 'Pícaro', 'Hechicero', 'Brujo', 'Mago'];
  final List<String> _backgrounds = ['Acólito', 'Artesano Gremial', 'Artista', 'Charlatán', 'Criminal', 'Ermitaño', 'Forastero', 'Héroe del Pueblo', 'Noble', 'Sabio', 'Soldado', 'Huérfano'];
  final List<String> _races = ['Dracónido', 'Elfo', 'Enano', 'Gnomo', 'Humano', 'Mediano', 'Semielfo', 'Semiorco', 'Tiflin'];

  @override
  void initState() {
    super.initState();
    _characterBox = Hive.box<Character>('characters');
    final sourceCharacter = _characterBox.get(widget.characterId)!;
    _character = sourceCharacter.clone();

    _nameController = TextEditingController(text: _character.name);
    _campaignNameController = TextEditingController(text: _character.campaignName);
    _levelController = TextEditingController(text: _character.level.toString());
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
    _nameController.dispose();
    _campaignNameController.dispose();
    _levelController.dispose();
    _alignmentController.dispose();
    _strController.dispose();
    _dexController.dispose();
    _conController.dispose();
    _intController.dispose();
    _wisController.dispose();
    _chaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _character.imagePath = image.path;
      });
    }
  }

  Future<void> _saveCharacter() async {
    if (_formKey.currentState?.validate() ?? false) {
      _character.name = _nameController.text;
      _character.campaignName = _campaignNameController.text;
      _character.level = int.tryParse(_levelController.text) ?? 1;
      _character.alignment = _alignmentController.text;
      _character.strength = int.tryParse(_strController.text) ?? 10;
      _character.dexterity = int.tryParse(_dexController.text) ?? 10;
      _character.constitution = int.tryParse(_conController.text) ?? 10;
      _character.intelligence = int.tryParse(_intController.text) ?? 10;
      _character.wisdom = int.tryParse(_wisController.text) ?? 10;
      _character.charisma = int.tryParse(_chaController.text) ?? 10;

      // 1. Guardar en la base de datos local (Hive)
      _characterBox.put(_character.id, _character);

      // 2. Guardar en Firebase Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('characters')
              .doc(_character.id)
              .set(_character.toJson());
        } catch (e) {
          debugPrint('Error al guardar en Firestore: $e');
          // Opcional: Mostrar un error al usuario
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personaje guardado.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deleteCharacter() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Personaje'),
          content: const Text('¿Estás seguro de que quieres eliminar este personaje? Esta acción no se puede deshacer.'),
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
                _characterBox.delete(_character.id);

                // 2. Eliminar de Firestore
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('characters')
                      .doc(_character.id)
                      .delete();
                }
                if (mounted) {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Regresa a la lista
                }
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
        title: Text(_character.name.isEmpty ? 'Nuevo Personaje' : 'Editar Personaje'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_forever), tooltip: 'Eliminar', onPressed: _deleteCharacter),
          IconButton(icon: const Icon(Icons.save), tooltip: 'Guardar', onPressed: _saveCharacter),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _character.imagePath.isNotEmpty
                      ? FileImage(File(_character.imagePath))
                      : null,
                  child: _character.imagePath.isEmpty
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Personaje'), validator: (v) => (v?.isEmpty ?? true) ? 'El nombre es obligatorio' : null),
            TextFormField(controller: _campaignNameController, decoration: const InputDecoration(labelText: 'Nombre de la Partida')),
            _buildDropdown('Clase', _character.characterClass, _classes, (val) => setState(() => _character.characterClass = val ?? '')),
            _buildDropdown('Especie', _character.race, _races, (val) => setState(() => _character.race = val ?? '')),
            _buildDropdown('Trasfondo', _character.background, _backgrounds, (val) => setState(() => _character.background = val ?? '')),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _levelController, decoration: const InputDecoration(labelText: 'Nivel'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _alignmentController, decoration: const InputDecoration(labelText: 'Alineamiento'))),
              ],
            ),
            const SizedBox(height: 24),
            Text('Estadísticas de Atributo', style: Theme.of(context).textTheme.titleLarge),
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

  Widget _buildDropdown(String label, String? currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      // Si el valor actual es una cadena vacía, lo tratamos como nulo para que se muestre el hint.
      // Esto evita el error cuando el personaje es nuevo y no tiene un valor seleccionado.
      initialValue: (currentValue?.isEmpty ?? true) ? null : currentValue,
      decoration: InputDecoration(labelText: label),
      items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}