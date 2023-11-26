# Application Flutter de Gestion de Notes

Application Flutter vous permettant de gérer vos notes de manière simple et efficace. Vous pouvez ajouter, modifier et supprimer des notes, les données étant stockées dans Firestore, la base de données cloud de Firebase.

## Instructions pour exécuter l'application Flutter avec un émulateur Android Studio

### Installer Flutter et Android Studio
- Suivez les instructions d'installation de Flutter sur le site officiel de Flutter : [Flutter Installation](https://flutter.dev/docs/get-started/install)
- Installez Android Studio en suivant les instructions sur le site officiel d'Android Studio : [Android Studio Installation](https://developer.android.com/studio/install)

### Cloner le projet
- Clonez ce dépôt sur votre machine en utilisant la commande suivante dans le terminal :
  ```bash
  git clone https://github.com/AmauryMch/firebase_project.git

## Ouvrir le projet dans VSCode
- Assurez-vous que le plugin Flutter est installé dans VSCode.
- Ouvrez le terminal dans VSCode et accédez au répertoire du projet en utilisant la commande `cd`.

## Vérifier les dépendances
- Dans le terminal de VSCode, exécutez la commande suivante pour obtenir les dépendances nécessaires :
  ```bash
  flutter pub get

## Lancer l'émulateur Android Studio
- Ouvrez Android Studio.
- Cliquez sur "Configure" en bas à droite.
- Sélectionnez "AVD Manager" (Android Virtual Device Manager).
- Créez un nouvel émulateur Android en suivant les étapes guidées. Si vous avez déjà un émulateur configuré, vous pouvez le lancer à partir d'ici.
- Ou depuis VSCode, sélectionnez l'émulateur en bas à droite.

## Utilisation

1. **Connexion :**
   - Connectez-vous à l'application avec votre compte. Si vous n'avez pas de compte, appuyez sur le bouton "Pas de compte ? S'inscrire". Remplissez les informations nécessaires et appuyez sur "S'inscrire". Vous pouvez maintenant vous connecter.

2. **Écran principal :**
   - Sur l'écran principal, vous verrez la liste de vos notes existantes.

3. **Ajouter une note :**
   - Pour ajouter une nouvelle note, appuyez sur le bouton "+" en bas à droite.

4. **Modifier une note :**
   - Pour modifier une note existante, appuyez sur le bouton d'édition à côté de la note. Modifiez les détails dans la boîte de dialogue et appuyez sur "Enregistrer". Notez que vous pouvez uniquement modifier les notes non complètes.

5. **Compléter une note :**
   - Chaque note a une case à cocher à côté du titre. Cochez la case pour indiquer que la note est complète. Le contenu de la note sera barré pour indiquer son achèvement.

6. **Supprimer une note :**
   - Pour supprimer une note, faites glisser la note vers la gauche.

7. **Déconnexion :**
   - Pour vous déconnecter, appuyez sur l'icône de déconnexion dans la barre d'applications.
