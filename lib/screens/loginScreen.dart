import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterterminalapp/screens/MainBody.dart';
import 'package:flutterterminalapp/screens/singUpScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String password;
  String email;
  final assetName = 'images/log.svg';
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        inAsyncCall: isLoaded,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.77,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60)),
            // image: DecorationImage(
            //   image: AssetImage("images/second.jpg"),
            //   fit: BoxFit.fitHeight,
            // ),
          ),
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SvgPicture.asset(
                assetName,
                semanticsLabel: 'Acme Logo',
                width: MediaQuery.of(context).size.width * 0.25,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              TextField(
                cursorColor: Colors.white,
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              TextField(
                cursorColor: Colors.black,
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Material(
                      color: Color(0xFFff5200),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            isLoaded = true;
                          });
                          if (email != null && password != null) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              setState(() {
                                isLoaded = false;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TerminalScreen()));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                print('No user found for that email.');
                                SnackBar snackBar1 = SnackBar(
                                  content: Text(
                                    "No user found for that email.",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 3),
                                );
                                setState(() {
                                  isLoaded = false;
                                });
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar1);
                              } else if (e.code == 'wrong-password') {
                                print('Wrong password provided for that user.');
                                SnackBar snackBar2 = SnackBar(
                                  content: Text(
                                    "Wrong password provided for that user.",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 2),
                                );
                                setState(() {
                                  isLoaded = false;
                                });
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar2);
                              }
                            }
                          }
                        },
                        minWidth: MediaQuery.of(context).size.width * 0.45,
                        child: Text(
                          'Log In',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Material(
                      color: Color(0xFFff5200),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          Navigator.of(context).push(_signUpRoute());
                        },
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          'Sign in',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route _signUpRoute() {
  return PageRouteBuilder(
    transitionDuration: Duration(seconds: 1),
    pageBuilder: (context, animation, secondaryAnimation) => SingUpScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
