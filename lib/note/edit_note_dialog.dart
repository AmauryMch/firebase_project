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
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  titleController.text = title;
  contentController.text = content;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String newImageUrl = imageUrl;
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
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      Reference storageReference = FirebaseStorage.instance
                          .ref()
                          .child('images/${DateTime.now().toString()}');
                      UploadTask uploadTask =
                          storageReference.putFile(File(pickedFile.path));

                      await uploadTask.whenComplete(() async {
                        newImageUrl = await storageReference.getDownloadURL();
                      });
                    } else {
                      print('Aucune image sélectionnée');
                    }
                  },
                  child: const Text('Modifier l\'image'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Bouton d'annulation
          ElevatedButton(
            onPressed: () {
              titleController.clear();
              contentController.clear();

              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          // Bouton pour enregistrer les modifications de la note
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                // Mettre à jour les données de la note dans Firestore
                await notes.doc(documentId).update({
                  'title': titleController.text,
                  'content': contentController.text,
                  'userId': userId,
                  'imageUrl': newImageUrl,
                });

                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note modifiée avec succès'),
                  ),
                );

                titleController.clear();
                contentController.clear();

                Navigator.of(context).pop();
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}
