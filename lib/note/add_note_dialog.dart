import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// Affiche une boîte de dialogue pour ajouter une nouvelle note
void showNoteDialog(
    BuildContext context, CollectionReference notes, String? userId) {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  String imageUrl = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Nouvelle Note'),
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
                        imageUrl = await storageReference.getDownloadURL();
                      });
                    } else {
                      print('Aucune image sélectionnée');
                    }
                  },
                  child: const Text('Uploader l\'image'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Bouton d'annulation
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          // Bouton pour enregistrer la nouvelle note
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
                await notes.add({
                  'title': titleController.text,
                  'content': contentController.text,
                  'userId': userId,
                  'isCompleted': false,
                  'imageUrl': imageUrl,
                });

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
