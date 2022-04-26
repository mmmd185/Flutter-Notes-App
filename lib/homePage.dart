import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/CRUD/editNote.dart';
import 'package:notes_app/CRUD/viewNote.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference notesRef = FirebaseFirestore.instance.collection("notes");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Notes"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed("login");
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("newNote");
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder<dynamic>(
            future: notesRef
                .where("userId",
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Dismissible(
                      onDismissed: (direction) async {
                        await notesRef.doc(snapshot.data.docs[i].id).delete();
                        await FirebaseStorage.instance
                            .refFromURL(snapshot.data.docs[i]['imageUrl'])
                            .delete();
                      },
                      child: ListNotes(
                        note: snapshot.data.docs[i].data(),
                        docId: snapshot.data.docs[i].id,
                      ),
                      key: Key("$i"),
                      direction: DismissDirection.endToStart,
                    );
                  },
                  itemCount: snapshot.data.docs.length,
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}

class ListNotes extends StatelessWidget {
  final note;
  final docId;
  ListNotes({Key? key, this.note, this.docId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ViewNotePage(
            list: note,
          );
        }));
      },
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.network(
                note['imageUrl'],
                width: 200,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              flex: 3,
              child: ListTile(
                title: Text("${note['Title']}"),
                subtitle: Text("${note['Body']}"),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditNotePage(
                        docId: docId,
                        list: note,
                      );
                    }));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
