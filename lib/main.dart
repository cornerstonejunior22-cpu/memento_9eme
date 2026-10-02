import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MementoApp());
}

class MementoApp extends StatelessWidget {
  const MementoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memento 9ème AF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AccessCodeScreen(),
    );
  }
}

class AccessCodeScreen extends StatefulWidget {
  const AccessCodeScreen({super.key});

  @override
  State<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends State<AccessCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final code = _codeController.text.trim();
      if (code.isEmpty) {
        setState(() {
          _errorMessage = 'Svp rantre yon kod daksè.';
          _isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('codes').doc(code).get();

      if (doc.exists && (doc.data()?['active'] ?? false) == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Kòd sa a pa valid oswa li ekspire.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erè koneksyon ak sèvè a.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Memento 9ème AF',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Antre kòd daksè ou pou w kòmanse'),
                const SizedBox(height: 32),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Kòd daksè',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('KONEKTE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memento 9ème AF - Pwogram'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            leading: Icon(Icons.calculate, color: Colors.blue),
            title: Text('Mathématiques'),
            subtitle: Text('Algèbre, Géométrie & Exercices'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.science, color: Colors.green),
            title: Text('Physique & Chimie'),
            subtitle: Text('Formules et notions clés'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.book, color: Colors.orange),
            title: Text('Français & Communication'),
            subtitle: Text('Grammaire, Orthographe et Textes'),
          ),
        ],
      ),
    );
  }
}
