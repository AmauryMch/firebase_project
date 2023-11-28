import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loggin_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Contrôleurs pour gérer la saisie de l'utilisateur dans les champs d'e-mail et de mot de passe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Méthode d'enregistrement de l'utilisateur
  void _register() async {
    try {
      // Tentative de création d'un nouvel utilisateur avec l'e-mail et le mot de passe fournis
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Affichage d'un message de réussite à l'aide d'un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie !'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigation vers la page de connexion après une inscription réussie
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Gestion des exceptions FirebaseAuth, telles qu'un e-mail ou un mot de passe invalide
      print("Erreur lors de l'inscription : $e");

      // Affichage d'un message d'erreur à l'aide d'un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'inscription'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Méthode pour accéder à la page de connexion
  void _goToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  // Méthode build pour créer l'interface utilisateur de la page d'authentification
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'app avec le titre "Inscription"
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      // Corps de la page contenant les champs de saisie de l'utilisateur et les boutons
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Champ de texte pour saisir l'e-mail
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            // Champ de texte pour saisir le mot de passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true, // Mot de passe masqué
            ),
            const SizedBox(height: 32.0),
            // Bouton élevé pour déclencher l'enregistrement
            ElevatedButton(
              onPressed: _register,
              child: const Text("S'inscrire"),
            ),
            const SizedBox(height: 16.0),
            // Bouton de texte pour accéder à la page de connexion
            TextButton(
              onPressed: _goToLoginPage,
              child: const Text('Déjà un compte ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
