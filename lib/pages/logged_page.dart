import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loggin_page.dart';

class LoggedPage extends StatelessWidget {
  final String userEmail;

  LoggedPage({required this.userEmail});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Naviguer vers la page de connexion après la déconnexion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion réussie'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vous êtes maintenant connecté!',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Email: $userEmail',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
