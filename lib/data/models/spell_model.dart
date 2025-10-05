import 'package:hive/hive.dart';

part 'spell_model.g.dart'; // Generado por build_runner

@HiveType(typeId: 0)
class Spell extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int level;

  @HiveField(3)
  String school;

  @HiveField(4)
  String castingTime;

  @HiveField(5)
  String range;

  @HiveField(6)
  String components;

  @HiveField(7)
  String duration;

  @HiveField(8)
  String description;

  @HiveField(9)
  bool isRitual;

  @HiveField(10)
  bool isConcentration;

  @HiveField(11)
  String higherLevel;

  @HiveField(12)
  Map<String, String> damageAtSlotLevel;

  @HiveField(13)
  List<String> classes;

  @HiveField(14)
  Map<String, String> damageAtCharacterLevel;

  @HiveField(15)
  String source;

  Spell({
    required this.id,
    this.name = '',
    this.level = 0,
    this.school = '',
    this.castingTime = '',
    this.range = '',
    this.components = '',
    this.duration = '',
    this.description = '',
    this.isRitual = false,
    this.isConcentration = false,
    this.higherLevel = '',
    this.damageAtSlotLevel = const {},
    this.classes = const [],
    this.damageAtCharacterLevel = const {},
    this.source = '',
  });

  // Métodos para futura sincronización con Firebase
  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int? ?? 0,
      school: json['school'] as String? ?? '',
      castingTime: json['castingTime'] as String? ?? '',
      range: json['range'] as String? ?? '',
      components: json['components'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isRitual: json['isRitual'] as bool? ?? false,
      isConcentration: json['isConcentration'] as bool? ?? false,
      higherLevel: json['higherLevel'] as String? ?? '',
      damageAtSlotLevel: json['damageAtSlotLevel'] != null
          ? Map<String, String>.from(json['damageAtSlotLevel'])
          : const {},
      classes: json['classes'] != null
          ? List<String>.from(json['classes'])
          : const [],
      damageAtCharacterLevel: json['damageAtCharacterLevel'] != null
          ? Map<String, String>.from(json['damageAtCharacterLevel'])
          : const {},
      source: json['source'] as String? ?? '', // Usamos 'source' que es el estándar
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'school': school,
        'castingTime': castingTime,
        'range': range,
        'components': components,
        'duration': duration,
        'description': description,
        'isRitual': isRitual,
        'isConcentration': isConcentration,
        'higherLevel': higherLevel,
        'damageAtSlotLevel': damageAtSlotLevel,
        'classes': classes,
        'damageAtCharacterLevel': damageAtCharacterLevel,
        'source': source,
      };
}