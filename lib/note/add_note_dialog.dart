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
  double _uploadProgress = 0.0;
  bool uploadCompleted = false;
  String previousImageUrl = '';
  var pickedFile;


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                        pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          // Supprimer l'image précédente si elle existe
                          if (previousImageUrl.isNotEmpty) {
                            await FirebaseStorage.instance
                                .refFromURL(previousImageUrl)
                                .delete();
                          }

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
                            imageUrl = await storageReference.getDownloadURL();
                            setState(() {
                              // Définir la progression à 100% une fois l'upload terminé
                              _uploadProgress = 1.0;
                              // Indiquer que l'upload est terminé
                              uploadCompleted = true;
                              previousImageUrl = imageUrl;
                            });
                          });
                        } else {
                          print('Aucune image sélectionnée');
                        }
                      },
                      child: const Text('Uploader l\'image'),
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
                  // Supprimer la nouvelle image si l'upload est annulé
                  if (uploadCompleted && imageUrl.isNotEmpty) {
                    FirebaseStorage.instance.refFromURL(imageUrl).delete();
                  }
                  setState(() {
                    _uploadProgress = 0.0;
                    uploadCompleted = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              // Bouton pour enregistrer la nouvelle note
              ElevatedButton(
                onPressed: (pickedFile == null || uploadCompleted)
                    ? () async {
                        if (titleController.text.trim().isEmpty ||
                            contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          // Récupérer la date actuelle
                          Timestamp createdAt = Timestamp.now();

                          await notes.add({
                            'title': titleController.text,
                            'content': contentController.text,
                            'userId': userId,
                            'isCompleted': false,
                            'imageUrl': imageUrl,
                            'createdAt': createdAt,
                          });

                          setState(() {
                            _uploadProgress = 0.0;
                            uploadCompleted = false;
                          });

                          titleController.clear();
                          contentController.clear();

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
