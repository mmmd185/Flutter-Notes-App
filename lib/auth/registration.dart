import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:notes_app/components/loadingAlert.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  GlobalKey<FormState> fState = new GlobalKey<FormState>();

  var username, email, password;

  register() async {
    var fData = fState.currentState;
    if (fData!.validate()) {
      fData.save();
      try {
        showLoading(context);
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Password Error',
            desc: 'The password provided is too weak',
            btnOkOnPress: () {},
          )..show();
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Email Error',
            desc: 'The account already exists for that email',
            btnOkOnPress: () {},
          )..show();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: 80,
          ),
          Image.asset(
            "images/Daco_5732595.png",
            height: 200,
            width: 400,
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                key: fState,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.length < 2) {
                          return "Username cannot be less than 2 characters";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        username = val;
                      },
                      decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.length < 2) {
                          return "Email cannot be less than 2 characters";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        email = val;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.mail),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.length < 2) {
                          return "Password cannot be less than 2 characters";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        password = val;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text("Already have an account ? "),
                        InkWell(
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed("login");
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: 600,
                      child: ElevatedButton(
                        onPressed: () async {
                          var uCredential = await register();
                          if (uCredential != null) {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .add({"username": username, "email": email});
                            Navigator.of(context).pushReplacementNamed("home");
                          }
                        },
                        child: Text("Register"),
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
