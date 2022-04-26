import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:notes_app/components/loadingAlert.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> fState = new GlobalKey<FormState>();
  var email, password;
  signIn() async {
    var formData = fState.currentState;
    if (formData!.validate()) {
      formData.save();
      try {
        showLoading(context);
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            title: 'User Not Found',
            desc: 'No user found for that email',
            btnOkOnPress: () {},
          )..show();
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Error',
            desc: 'Wrong Password',
            btnOkOnPress: () {},
          )..show();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                        if (val == null || val.length == 0) {
                          return "Enter your email";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        email = val;
                      },
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
                      validator: (pass) {
                        if (pass == null || pass.length == 0) {
                          return "Enter your password";
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
                              borderSide: BorderSide(width: 1))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text("Don't have an account ? "),
                        InkWell(
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacementNamed("registration");
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
                          var uCredentials = await signIn();
                          if (uCredentials != null) {
                            Navigator.of(context).pushReplacementNamed("home");
                          }
                        },
                        child: Text("Login"),
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
