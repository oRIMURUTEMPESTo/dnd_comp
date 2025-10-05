import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _feedbackController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un comentario.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('feedback').add({
        'comment': _feedbackController.text,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tus comentarios!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      setState(() {
        // No need for mounted check here as setState does it internally.
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Comentarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Tienes alguna sugerencia o encontraste un error? ¡Déjanos tus comentarios!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Tus comentarios',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendFeedback,
              icon: _isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: Text(_isSending ? 'Enviando...' : 'Enviar Comentarios'),
            ),
          ],
        ),
      ),
    );
  }
}