import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 1)
class Character extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String characterClass;

  @HiveField(3)
  int level;

  @HiveField(4)
  String race;

  @HiveField(5)
  String background;

  @HiveField(6)
  String alignment;

  @HiveField(7)
  int strength;

  @HiveField(8)
  int dexterity;

  @HiveField(9)
  int constitution;

  @HiveField(10)
  int intelligence;

  @HiveField(11)
  int wisdom;

  @HiveField(12)
  int charisma;

  @HiveField(13)
  String campaignName;

  @HiveField(14)
  int maxHp;

  @HiveField(15)
  int currentHp;

  @HiveField(16)
  int armorClass;

  @HiveField(17)
  int speed;

  @HiveField(18)
  String imagePath;

  // ... más campos como HP, AC, skills, etc.

  Character({
    required this.id,
    this.name = '',
    this.characterClass = '',
    this.level = 1,
    this.race = '',
    this.background = '',
    this.alignment = '',
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.campaignName = '',
    this.maxHp = 10,
    this.currentHp = 10,
    this.armorClass = 10,
    this.speed = 30,
    this.imagePath = '',
  });

  Character clone() {
    return Character(
      id: id,
      name: name,
      characterClass: characterClass,
      level: level,
      race: race,
      background: background,
      alignment: alignment,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      campaignName: campaignName,
      maxHp: maxHp,
      currentHp: currentHp,
      armorClass: armorClass,
      speed: speed,
      imagePath: imagePath,
    );
  }

  // Nuevo método para convertir el personaje a un Map para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'characterClass': characterClass,
      'level': level,
      'race': race,
      'background': background,
      'alignment': alignment,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'campaignName': campaignName,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'armorClass': armorClass,
      'speed': speed,
      'imagePath': imagePath,
      // Nota: La imagen no se guarda en Firestore, solo la ruta.
    };
  }
}