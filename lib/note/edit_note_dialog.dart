import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// Affiche une boîte de dialogue pour modifier une note existante
void showEditNoteDialog(
  BuildContext context,
  CollectionReference notes,
  String? userId,
  String title,
  String content,
  bool isCompleted,
  String documentId,
  String imageUrl,
) {
  // Contrôleurs pour les champs de saisie de titre et de contenu
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // Préremplissage des champs de saisie avec les valeurs actuelles
  titleController.text = title;
  contentController.text = content;

  // Barre de progression pour le téléchargement de la nouvelle image
  double _uploadProgress = 0.0;
  bool uploadCompleted = false;

  // Affichage de la boîte de dialogue
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Variable pour stocker l'ancienne URL de l'image
      String? previousImageUrl = '';
      String originalImageUrl = imageUrl;

      // Construction de la boîte de dialogue
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Modifier la Note'),
            content: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Contenu'),
                      maxLines: null,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Utilisation de l'ImagePicker pour sélectionner une nouvelle image depuis la galerie
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          // Supprimer la nouvelle image si l'upload est annulé
                          if (uploadCompleted && imageUrl.isNotEmpty) {
                            FirebaseStorage.instance
                                .refFromURL(imageUrl)
                                .delete();
                          }

                          // Restaurer l'ancienne image (si elle existe)
                          if (previousImageUrl != null) {
                            imageUrl = previousImageUrl!;
                          }

                          // Téléchargement de la nouvelle image vers Firebase Storage
                          Reference storageReference = FirebaseStorage.instance
                              .ref()
                              .child('images/${DateTime.now().toString()}');
                          UploadTask uploadTask =
                              storageReference.putFile(File(pickedFile.path));

                          uploadTask.snapshotEvents
                              .listen((TaskSnapshot snapshot) {
                            setState(() {
                              _uploadProgress = snapshot.bytesTransferred /
                                  snapshot.totalBytes;
                            });
                          });

                          await uploadTask.whenComplete(() async {
                            // Mise à jour de l'URL de l'image après téléchargement
                            imageUrl = await storageReference.getDownloadURL();
                            setState(() {
                              _uploadProgress =
                                  1.0; // Définir la progression à 100% une fois l'upload terminé
                              uploadCompleted =
                                  true; // Indiquer que l'upload est terminé
                              previousImageUrl = imageUrl;
                            });
                          });
                        } else {
                          print('Aucune image sélectionnée');
                        }
                      },
                      child: const Text('Modifier l\'image'),
                    ),
                    if (_uploadProgress > 0.0)
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            uploadCompleted ? Colors.green : Colors.blue),
                      ),
                    if (_uploadProgress == 1.0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '100% Image enregistrée',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              // Bouton d'annulation
              ElevatedButton(
                onPressed: () {
                  // Effacement des champs de saisie
                  titleController.clear();
                  contentController.clear();

                  // Supprimer la nouvelle image si l'upload est annulé
                  if (uploadCompleted && imageUrl.isNotEmpty) {
                    FirebaseStorage.instance.refFromURL(imageUrl).delete();
                  }

                  // Réinitialiser la barre de progression
                  setState(() {
                    _uploadProgress = 0.0;
                    uploadCompleted = false;
                  });

                  // Fermeture de la boîte de dialogue
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              // Bouton pour enregistrer les modifications de la note
              ElevatedButton(
                onPressed: (_uploadProgress == 1.0)
                    ? () async {
                        // Vérification si les champs obligatoires sont remplis
                        if (titleController.text.trim().isEmpty ||
                            contentController.text.trim().isEmpty) {
                          // Affichage d'un message d'erreur
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          // Supprimer l'ancienne image si une nouvelle image a été ajoutée
                          if (uploadCompleted && originalImageUrl.isNotEmpty) {
                            await FirebaseStorage.instance
                                .refFromURL(originalImageUrl)
                                .delete();
                          }
                          // Mise à jour des données de la note dans Firestore
                          await notes.doc(documentId).update({
                            'title': titleController.text,
                            'content': contentController.text,
                            'userId': userId,
                            'imageUrl': imageUrl,
                          });

                          // Affichage d'un message de confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note modifiée avec succès'),
                            ),
                          );

                          // Réinitialiser la barre de progression
                          setState(() {
                            _uploadProgress = 0.0;
                            uploadCompleted = false;
                          });

                          // Effacement des champs de saisie
                          titleController.clear();
                          contentController.clear();

                          // Fermeture de la boîte de dialogue
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );
    },
  );
}
