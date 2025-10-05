import 'dart:convert';
import 'package:dnddichas/data/models/spell_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to fetch all spells from the local JSON asset.
///
/// This is much more efficient than fetching from an API and translating on the fly.
final allSpellsProvider = FutureProvider<List<Spell>>((ref) async {
  print('[Assets] Loading spells from local JSON...');
  final String response = await rootBundle.loadString('assets/srd_spells_es.json');
  final List<dynamic> data = await json.decode(response);
  final spells = data.map((json) => Spell.fromJson(json)).toList();
  print('[Assets] Loaded ${spells.length} spells.');
  return spells;
});

/// Provider to filter the list of all spells based on a search query.
final filteredSpellsProvider = Provider.family<List<Spell>, String>((ref, query) {
  final allSpells = ref.watch(allSpellsProvider).asData?.value ?? [];
  if (query.isEmpty) {
    return allSpells;
  }
  return allSpells.where((spell) => spell.name.toLowerCase().contains(query.toLowerCase())).toList();
});