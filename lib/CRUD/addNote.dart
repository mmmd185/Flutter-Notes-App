import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/components/loadingAlert.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class NewNotePage extends StatefulWidget {
  final docId;
  NewNotePage({Key? key, this.docId}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  var noteTitle, noteBody;

  late Reference storageRef;

  File? file;

  ImagePicker imagePicker = ImagePicker();

  addNote() async {
    if (file == null) {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        title: 'No Image',
        desc: 'Please choose an image to proceed',
        btnOkOnPress: () {},
      )..show();
    }

    var fData = formState.currentState;

    if (fData?.validate() == true) {
      showLoading(context);
      fData?.save();
      await storageRef.putFile(file!);
      var imageUrl = await storageRef.getDownloadURL();
      FirebaseFirestore.instance
          .collection("notes")
          .add({
            "Title": noteTitle,
            "Body": noteBody,
            "imageUrl": imageUrl,
            "userId": FirebaseAuth.instance.currentUser?.uid
          })
          .then((value) => Navigator.of(context).pushReplacementNamed("home"))
          .catchError((e) {
            print("$e");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Note"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formState,
          child: Column(
            children: [
              TextFormField(
                validator: (val) {
                  if (val!.length < 1) {
                    return "Add a title";
                  }

                  return null;
                },
                onSaved: (val) {
                  noteTitle = val;
                },
                maxLength: 30,
                maxLines: 1,
                decoration: InputDecoration(labelText: "Note Title"),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: (val) {
                  if (val!.length < 1) {
                    return "Add a note";
                  }

                  return null;
                },
                onSaved: (val) {
                  noteBody = val;
                },
                maxLength: 200,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(labelText: "Note"),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    showBottomSheet();
                  },
                  child: Text("Add Image")),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 400,
                  child: ElevatedButton(
                      onPressed: () async {
                        await addNote();
                      },
                      child: Text("Add Note"))),
            ],
          ),
        ),
      ),
    );
  }

  showBottomSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            height: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please Choose Image",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () async {
                    var pickedImage = await imagePicker.pickImage(
                        source: ImageSource.gallery);

                    if (pickedImage != null) {
                      file = File(pickedImage.path);
                      var imageName = Path.basename(pickedImage.path);

                      var timestamp =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      storageRef = FirebaseStorage.instance
                          .ref("GalleryImages/$timestamp$imageName");

                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_outlined,
                            size: 30,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Add an existing image")
                        ],
                      )),
                ),
                InkWell(
                  onTap: () async {
                    var pickedImage =
                        await imagePicker.pickImage(source: ImageSource.camera);

                    if (pickedImage != null) {
                      file = File(pickedImage.path);
                      var imageName = Path.basename(pickedImage.path);

                      storageRef = FirebaseStorage.instance
                          .ref("CameraImages/$imageName");

                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("New image")
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }
}
