import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loggin_page.dart';

// Classe représentant la page de connexion réussie
class LoggedPage extends StatelessWidget {
  // Propriété contenant l'adresse e-mail de l'utilisateur connecté
  final String userEmail;

  // Constructeur qui initialise l'adresse e-mail
  const LoggedPage({required this.userEmail});

  // Méthode de déconnexion de l'utilisateur
  void _logout(BuildContext context) async {
    // Appel de la méthode de déconnexion de Firebase
    await FirebaseAuth.instance.signOut();

    // Navigation vers la page de connexion après la déconnexion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  // Méthode de construction de l'interface utilisateur de la page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'app avec le titre "Connexion réussie"
      appBar: AppBar(
        title: const Text('Connexion réussie'),
      ),
      // Corps de la page centré avec des informations sur la connexion et un bouton de déconnexion
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Message indiquant que l'utilisateur est connecté
            const Text(
              'Vous êtes maintenant connecté!',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0), // Espacement vertical
            // Affichage de l'adresse e-mail de l'utilisateur
            Text(
              'Email: $userEmail',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 32.0), // Espacement vertical
            // Bouton élevé pour déclencher la déconnexion
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
