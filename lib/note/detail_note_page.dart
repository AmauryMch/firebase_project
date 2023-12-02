import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/loggin_page.dart';

class DetailNotePage extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;

  const DetailNotePage({
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12.0),
              // Conteneur pour afficher le contenu de la note avec une bordure
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12.0),
              // Si l'image existe, afficher un conteneur avec l'image et une bordure
              if (imageUrl.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
