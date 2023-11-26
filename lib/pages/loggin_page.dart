import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'logged_page.dart';
import 'signin_page.dart';
import 'firestore_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie!'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // builder: (context) => LoggedPage(
          //   userEmail: userCredential.user?.email ?? '',
          // ),
          builder: (context) => FirestorePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("Erreur lors de la connexion: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la connexion'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _goToRegistration() {
    // Rediriger vers la page d'inscription
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Se connecter'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _goToRegistration,
              child: Text('Pas de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
