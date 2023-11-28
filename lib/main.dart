import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'auth/loggin_page.dart';

// Fonction principale qui initialise Firebase et lance l'application
void main() async {
  // S'assure que la liaison des widgets est initialisée
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase avec les options par défaut pour la plateforme actuelle
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lance l'application en créant une instance de MyApp
  runApp(MyApp());
}

// Classe principale représentant l'application Flutter
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Méthode de construction de l'interface utilisateur de l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuration générale de l'application
      title: 'Flutter Demo',
      theme: ThemeData(
        // Configuration du thème, notamment la couleur de base
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Page d'accueil de l'application, dans ce cas, la page de connexion
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
