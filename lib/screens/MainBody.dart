import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterterminalapp/screens/TerminalScreen.dart';
import 'package:flutterterminalapp/screens/singUpScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalScreen extends StatefulWidget {
  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  String email;
  final ipAdd = new TextEditingController();
  final userName = new TextEditingController();
  final password = new TextEditingController();
  CollectionReference users;
  bool isLoaded = false;

  void currentUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        setState(() {
          email = user.email;
        });
        if (email != null) {
          users = FirebaseFirestore.instance.collection(email);

          setState(() {
            isLoaded = true;
          });
        }
      }
    });
  }

  Future<void> addUser(String user, String password, String ip) {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'User': user,
          'Password': password,
          'Ip': ip,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  void getSystemIpAndData() {
    String ipText = ipAdd.text;
    String userText = userName.text;
    String passText = password.text;

    if (ipText != "" && userText != "" && passText != "") {
      addUser(userText, passText, ipText);
      ipAdd.clear();
      userName.clear();
      password.clear();
      Navigator.pop(context);
    }
  }

  Widget inputFieldStyle(
      {TextEditingController controller,
      String text,
      bool obscure,
      double height}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: text,
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            onSubmitted: (value) {
              controller.text = value;
            },
          ),
        ),
        SizedBox(
          height: height * 0.02,
        ),
      ],
    );
  }

  _showDialog(BuildContext context, double height, double width) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.white70,
            child: Container(
              height: 300,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Add Hosts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  inputFieldStyle(
                    controller: ipAdd,
                    obscure: false,
                    text: "IPAddress",
                    height: height,
                  ),
                  inputFieldStyle(
                    controller: userName,
                    obscure: false,
                    text: "User",
                    height: height,
                  ),
                  inputFieldStyle(
                      controller: password,
                      obscure: true,
                      text: "Password",
                      height: height),
                  RaisedButton(
                    child: Text(
                      "Submit",
                      style: GoogleFonts.robotoMono(
                        color: Colors.white70,
                      ),
                    ),
                    onPressed: () {
                      getSystemIpAndData();
                    },
                    color: Colors.black,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => SystemNavigator.pop(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("YES"),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    currentUser();
  }

  void singOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SingUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
          backgroundColor: Colors.grey,
          onPressed: () {
            // modalBottomSheer(context);
            _showDialog(
              context,
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width,
            );
          },
        ),
        backgroundColor: Color.fromRGBO(235, 235, 235, 1),
        appBar: AppBar(
          leading: Icon(
            Icons.autorenew,
            color: Colors.black,
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.075,
          title: Text(
            "Hosts",
            style: GoogleFonts.robotoMono(color: Colors.black, wordSpacing: 2),
          ),
          actions: [
            OutlineButton(
              onPressed: singOut,
              child: Text(
                "Sing out",
                style: GoogleFonts.robotoMono(color: Colors.black),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Hosts",
                  style: TextStyle(fontSize: 20),
                )),
            isLoaded
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(email)
                        .snapshots(),
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.hasError) return new Text("Error!");
                      return asyncSnapshot.hasData
                          ? newBuild(
                              context,
                              asyncSnapshot.data.docs,
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget newBuild(
      BuildContext context, final List<QueryDocumentSnapshot> data) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final dataNew = data[index].data();
          final QueryDocumentSnapshot deleteData = data[index];
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TerminalScreenSSH(
                      ip: dataNew["Ip"].toString(),
                      password: dataNew["Password"].toString(),
                      user: dataNew["User"].toString(),
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
                child: Icon(
                  Icons.airplay,
                  color: Colors.black,
                ),
              ),
              title: Text("${dataNew["Ip"]}"),
              subtitle: Text("SSH, ${dataNew["User"]} ,Linux"),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .runTransaction((Transaction myTransaction) async {
                      myTransaction.delete(deleteData.reference);
                    });
                  }),
            ),
          );
        },
      ),
    );
  }
}

// class ListTiles extends StatelessWidget {
//   final List<QueryDocumentSnapshot> data;
//
//   ListTiles({this.data});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       width: MediaQuery.of(context).size.width,
//       child: ListView.builder(
//         itemCount: data.length,
//         itemBuilder: (context, index) {
//           final dataNew = data[index].data();
//           final QueryDocumentSnapshot deleteData = data[index];
//           return Container(
//             margin: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white70,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             padding: EdgeInsets.all(10),
//             child: ListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TerminalScreenSSH(
//                       ip: dataNew["Ip"].toString(),
//                       password: dataNew["Password"].toString(),
//                       user: dataNew["User"].toString(),
//                     ),
//                   ),
//                 );
//               },
//               leading: CircleAvatar(
//                 backgroundColor: Colors.grey,
//                 radius: 25,
//                 child: Icon(
//                   Icons.airplay,
//                   color: Colors.black,
//                 ),
//               ),
//               title: Text("${dataNew["Ip"]}"),
//               subtitle: Text("SSH, ${dataNew["User"]} ,Linux"),
//               trailing: IconButton(
//                   icon: Icon(
//                     Icons.delete_forever,
//                     color: Colors.black,
//                   ),
//                   onPressed: () async {
//                     await FirebaseFirestore.instance
//                         .runTransaction((Transaction myTransaction) async {
//                       myTransaction.delete(deleteData.reference);
//                     });
//                   }),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
