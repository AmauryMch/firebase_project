import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/loggin_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'add_note_dialog.dart';
import 'edit_note_dialog.dart';

// Page principale pour gérer les notes dans Firestore
class NotePage extends StatelessWidget {
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
                            showEditNoteDialog(
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
          showNoteDialog(context, notes, user?.uid);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
