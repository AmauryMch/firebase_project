import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loggin_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Page principale pour gérer les notes dans Firestore
class FirestorePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Référence à la collection Firestore 'notes'
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    // Obtenir l'utilisateur actuel
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Écoute des modifications de la collection 'notes' pour l'utilisateur actuel
        stream: notes.where('userId', isEqualTo: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          // Affichage de la liste des notes
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              String imageUrl = data['imageUrl'] ?? '';

              // Composant Dismissible pour permettre la suppression de la note
              return Dismissible(
                key: Key(document.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    if (imageUrl.isNotEmpty) {
                      Reference storageReference =
                          FirebaseStorage.instance.refFromURL(imageUrl);
                      await storageReference.delete();
                    }

                    await notes.doc(document.id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note supprimée'),
                      ),
                    );
                  }
                },
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: ListTile(
                  // Affichage du titre et du contenu de la note
                  title: Text(
                    data['title'],
                    style: TextStyle(
                      decoration: data['isCompleted'] ?? false
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['content'],
                        style: TextStyle(
                          decoration: data['isCompleted'] ?? false
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          height: 100.0,
                        ),
                    ],
                  ),

                  // Cases à cocher et bouton d'édition de la note
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: data['isCompleted'] ?? false,
                        onChanged: (bool? value) {
                          notes.doc(document.id).update({'isCompleted': value});
                        },
                      ),
                      if (!(data['isCompleted'] ?? false))
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditNoteDialog(
                              context,
                              notes,
                              user?.uid,
                              data['title'],
                              data['content'],
                              data['isCompleted'] ?? false,
                              document.id,
                              data['imageUrl'],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      // Bouton flottant pour ajouter une nouvelle note
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoteDialog(context, notes, user?.uid);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Affiche une boîte de dialogue pour ajouter une nouvelle note
  void _showNoteDialog(
      BuildContext context, CollectionReference notes, String? userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String imageUrl = '';

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

  // Affiche une boîte de dialogue pour modifier une note existante
  void _showEditNoteDialog(
    BuildContext context,
    CollectionReference notes,
    String? userId,
    String title,
    String content,
    bool isCompleted,
    String documentId,
    String imageUrl,
  ) {
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
}
