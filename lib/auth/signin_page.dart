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
  bool _obscurePassword = true;

  // Vérifier si le mot de passe contient au moins une lettre majuscule
  bool _containsUppercase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  // Vérifier si le mot de passe contient au moins un caractère spécial
  bool _containsSpecialCharacter(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool _containsNumber(String value) {
    // Vérifie si la chaîne contient au moins un chiffre
    return value.contains(RegExp(r'\d'));
  }

  // Méthode d'enregistrement de l'utilisateur
  void _register() async {
    try {
      // Vérifier si l'e-mail est vide
      if (_emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir une adresse e-mail.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      // Vérifier si le mot de passe est vide
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un mot de passe.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Vérifier si le mot de passe répond aux critères
      if (_passwordController.text.length < 8 ||
          !_containsUppercase(_passwordController.text) ||
          !_containsSpecialCharacter(_passwordController.text) ||
          !_containsNumber(_passwordController.text)) {
        // Afficher un message d'erreur si le mot de passe est invalide
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Mot de passe invalide. Assurez-vous qu\'il a au moins 8 caractères, une majuscule et un caractère spécial.'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      // Tentative de création d'un nouvel utilisateur avec l'e-mail et le mot de passe fournis
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
      // Gestion des exceptions FirebaseAuth
      if (e.code == 'email-already-in-use') {
        // L'e-mail est déjà associé à un compte existant
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cet e-mail est déjà associé à un compte existant.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Autre erreur lors de l'inscription
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
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  onPressed: () {
                    // Inverse l'état d'obscuration du mot de passe lors du clic sur le bouton
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    // Utilise une icône différente selon l'état d'obscuration
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText:
                  _obscurePassword, // Mot de passe masqué en fonction de l'état
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
