import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signin_page.dart';
import 'firestore_page.dart';

// Classe représentant la page de connexion
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// Classe d'état pour la page de connexion
class _LoginPageState extends State<LoginPage> {
  // Contrôleurs pour gérer la saisie de l'utilisateur dans les champs d'e-mail et de mot de passe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Méthode de connexion de l'utilisateur
  void _login() async {
    try {
      // Tentative de connexion de l'utilisateur avec l'e-mail et le mot de passe fournis
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Affichage d'un message de réussite à l'aide d'un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie!'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigation vers la page suivante après une connexion réussie
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // builder: (context) => LoggedPage(
          //   userEmail: userCredential.user?.email ?? '',
          // ),
          builder: (context) => FirestorePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Gestion des exceptions FirebaseAuth, telles qu'un e-mail ou un mot de passe incorrect
      print("Erreur lors de la connexion: $e");

      // Affichage d'un message d'erreur à l'aide d'un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la connexion'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Méthode pour accéder à la page d'inscription
  void _goToRegistration() {
    // Redirection vers la page d'inscription
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
    );
  }

  // Méthode de construction de l'interface utilisateur de la page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'app avec le titre "Connexion"
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      // Corps de la page avec des champs de saisie d'e-mail et de mot de passe, et des boutons d'action
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Champ de texte pour saisir l'e-mail
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0), // Espacement vertical
            // Champ de texte pour saisir le mot de passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true, // Mot de passe masqué
            ),
            const SizedBox(height: 32.0), // Espacement vertical
            // Bouton élevé pour déclencher la connexion
            ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 16.0), // Espacement vertical
            // Bouton de texte pour accéder à la page d'inscription
            TextButton(
              onPressed: _goToRegistration,
              child: const Text('Pas de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
