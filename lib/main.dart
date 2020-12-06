import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterterminalapp/screens/MainBody.dart';
import 'package:flutterterminalapp/screens/singUpScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void navigateThrough(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => SingUpScreen()));
      } else {
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => TerminalScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    navigateThrough(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(
          "images/login.jpg",
        ),
        fit: BoxFit.fill,
      )),
    );
  }
}
