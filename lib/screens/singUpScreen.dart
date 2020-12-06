import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterterminalapp/screens/MainBody.dart';
import 'package:flutterterminalapp/screens/loginScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SingUpScreen extends StatefulWidget {
  @override
  _SingUpScreenState createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  String password;
  String email;
  bool isLoaded = false;
  final assetName = 'images/log.svg';
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        inAsyncCall: isLoaded,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
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
                style: TextStyle(
                  //color: Colors.white,
                  decorationColor: Colors.white,
                ),
                // style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  //hintText: 'Enter your email',
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
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              TextField(
                cursorColor: Colors.white,
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.005,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Color(0xFFff5200),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            isLoaded = true;
                          });
                          FocusScope.of(context).unfocus();
                          if (email != null && password != null) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              final snackbar = SnackBar(
                                content: Text(
                                  "Singed in Successfully",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.black,
                                duration: Duration(seconds: 2),
                              );
                              _scaffoldKey.currentState.showSnackBar(snackbar);
                              setState(() {
                                isLoaded = false;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TerminalScreen()));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                print('The password provided is too weak.');
                                final snackBar = SnackBar(
                                  content: Text(
                                    "The password provided is too weak.",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.black,
                                  duration: Duration(seconds: 2),
                                );
                                setState(() {
                                  isLoaded = false;
                                });
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              } else if (e.code == 'email-already-in-use') {
                                print(
                                    'The account already exists for that email.');
                                final snackBar = SnackBar(
                                  content: Text(
                                    "The account already exists for that email.",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.black,
                                  duration: Duration(seconds: 2),
                                );
                                isLoaded = false;
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              }
                            } catch (e) {
                              final snackBar = SnackBar(
                                content: Text(
                                  e,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.black,
                                duration: Duration(seconds: 2),
                              );
                              setState(() {
                                isLoaded = false;
                              });
                              Scaffold.of(context).showSnackBar(snackBar);
                            }
                          }
                        },
                        minWidth: MediaQuery.of(context).size.width * 0.45,
                        height: 42.0,
                        child: Text(
                          'Sing Up',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.08,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Color(0xFFff5200),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          Navigator.of(context).push(_loginRoute());
                        },
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        height: 42.0,
                        child: Text(
                          'Log in',
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

Route _loginRoute() {
  return PageRouteBuilder(
    transitionDuration: Duration(seconds: 1),
    pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
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
