import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/homePage.dart';
import 'package:notes_app/auth/registration.dart';
import 'package:notes_app/auth/login.dart';
import 'package:notes_app/CRUD/addNote.dart';
import 'package:notes_app/CRUD/editNote.dart';

bool isLoggedIn = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    isLoggedIn = false;
  } else {
    isLoggedIn = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn == false ? LoginPage() : HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        "home": (context) => HomePage(),
        "registration": (context) => RegistrationPage(),
        "login": (context) => LoginPage(),
        "newNote": (context) => NewNotePage(),
      },
    );
  }
}
