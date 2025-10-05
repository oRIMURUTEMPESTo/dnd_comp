import 'package:dnddichas/data/models/spell_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- AUTHENTICATION PROVIDERS ---

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Pega aquí el ID de cliente web que copiaste de la consola de Firebase.
  const webClientId = "973818078815-ceb5lqjhfntf56urueq6bv909ks5g8sv.apps.googleusercontent.com";

  return GoogleSignIn(
    clientId: webClientId,
  );
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._firebaseAuth, this._googleSignIn);

  Future<UserCredential?> signInWithGoogle() async {
    debugPrint('[Auth] Iniciando sesión con Google...');
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    debugPrint('[Auth] Sesión con Google exitosa.');
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    debugPrint('[Auth] Sesión cerrada.');
  }
}

// --- SPELL DATA PROVIDERS ---

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// -- Hive (Local) --
final spellBoxProvider = Provider<Box<Spell>>((ref) => Hive.box<Spell>('spells'));

final localSpellRepositoryProvider = Provider<SpellRepository>((ref) {
  return SpellRepository(
    ref.watch(spellBoxProvider),
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class SpellRepository {
  final Box<Spell> _spellBox;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SpellRepository(this._spellBox, this._auth, this._firestore);

  List<Spell> getAllSpells() => _spellBox.values.toList();

  Future<void> saveSpell(Spell spell) async {
    debugPrint('[Storage] Guardando hechizo: ${spell.name} (ID: ${spell.id})');
    // Guardado local
    await _spellBox.put(spell.id, spell);

    // Sincronización con Firebase
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('[Sync] Sincronizando hechizo ${spell.id} con Firestore.');
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('spells')
          .doc(spell.id)
          .set(spell.toJson());
    }
  }

  // Listener para cuando los hechizos cambian
  Stream<BoxEvent> watchSpells() => _spellBox.watch();

  Future<void> deleteSpell(String spellId) async {
    debugPrint('[Storage] Eliminando hechizo (ID: $spellId)');
    // Eliminación local
    await _spellBox.delete(spellId);

    // Sincronización con Firebase
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('[Sync] Eliminando hechizo $spellId de Firestore.');
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('spells')
          .doc(spellId)
          .delete();
    }
  }

  /// Descarga todos los hechizos de Firestore y los guarda en la caja local.
  /// Esto asegura que los datos estén sincronizados al iniciar sesión en un nuevo dispositivo.
  Future<void> syncSpellsFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[Sync] No hay usuario logueado, no se puede sincronizar.');
      return;
    }

    debugPrint('[Sync] Iniciando sincronización desde Firestore...');
    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('spells')
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint('[Sync] No se encontraron hechizos en Firestore para este usuario.');
      return;
    }

    for (final doc in querySnapshot.docs) {
      final spell = Spell.fromJson(doc.data());
      await _spellBox.put(spell.id, spell);
    }

    debugPrint('[Sync] Sincronización completada. ${querySnapshot.docs.length} hechizos guardados localmente.');
  }
}

/// Este provider escucha los cambios en la caja de hechizos y emite
/// la lista actualizada de hechizos.
final spellsStreamProvider = StreamProvider<List<Spell>>((ref) async* {
  final repository = ref.watch(localSpellRepositoryProvider);

  // 1. Emite la lista inicial de hechizos inmediatamente.
  yield repository.getAllSpells();

  // 2. Se queda escuchando cambios y emite la lista actualizada cada vez.
  await for (final _ in repository.watchSpells()) {
    yield repository.getAllSpells();
  }
});

/// Este provider observa los cambios de autenticación y dispara la sincronización
/// de datos cuando un usuario inicia sesión.
final syncControllerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) async {
    final user = next.value;
    if (user != null) {
      // El usuario ha iniciado sesión.
      debugPrint('[SyncController] Usuario detectado, iniciando sincronización...');
      await ref.read(localSpellRepositoryProvider).syncSpellsFromFirebase();
    } else {
      // El usuario ha cerrado sesión. Podríamos limpiar la base de datos local aquí si quisiéramos.
      debugPrint('[SyncController] Usuario ha cerrado sesión.');
    }
  });
});