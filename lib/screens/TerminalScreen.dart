import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterterminalapp/screens/MainBody.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ssh/ssh.dart';

class TerminalScreenSSH extends StatefulWidget {
  final String user;
  final String ip;
  final String password;
  TerminalScreenSSH({this.ip, this.user, this.password});
  @override
  _TerminalScreenSSHState createState() => _TerminalScreenSSHState();
}

class _TerminalScreenSSHState extends State<TerminalScreenSSH> {
  SSHClient newClient;
  String connectedStatusResult;

  //String commandResult;
  //List<Widget> array;
  int item = 1;
  final textEditor = new TextEditingController();
  List<String> sshClientResult = ["start"];
  String userEnteredCommands;
  String currentDirectory = "/";
  String shellStatus;

  SSHClient _client(String ip, String user, String password) {
    return SSHClient(
      host: ip,
      port: 22,
      username: user,
      passwordOrKey: password,
    );
  }

  Future<SSHClient> onClickCmd(SSHClient client) async {
    try {
      connectedStatusResult = await client.connect();
      if (connectedStatusResult == "session_connected") {
        String result = await client.startShell(
            ptyType: "ansi",
            callback: (dynamic res) {
              //sshClientResult += res;
            });
        setState(() {
          shellStatus = result;
        });

        Fluttertoast.showToast(
            msg: "Connected",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        return client;
      }
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  void addLocalHost() {
    setState(() {
      item = item + 1;
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit Terminal'),
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
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TerminalScreen())),
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
    newClient = _client(widget.ip, widget.user, widget.password);
  }

  @override
  void dispose() {
    super.dispose();
    newClient.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff323232),
          actions: [
            OutlineButton(
              onPressed: () {
                onClickCmd(newClient);
              },
              child: Text(
                connectedStatusResult == "session_connected"
                    ? "Connected"
                    : "Connect",
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
          color: Colors.black,
          child: ListView.builder(
              itemCount: item,
              itemBuilder: (context, item) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sshClientResult[item] == 'start'
                          ? "hii"
                          : sshClientResult[item],
                      style: TextStyle(
                          color: sshClientResult[item] == "start"
                              ? Colors.black
                              : Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "\$${widget.user}@localhost:",
                              style: GoogleFonts.robotoMono(
                                  color: Colors.green, fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            // maxLines: null,
                            //controller: textEditor,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            onChanged: (value) {
                              setState(() {
                                userEnteredCommands = value;
                              });
                            },
                            onSubmitted: (_) async {
                              print("hi");
                              // newResult.add(value);
                              setState(() async {
                                // final result =
                                //     await newClient.execute(userEnteredCommands);
                                // sshClientResult.add(result);
                                // currentDirectory = await newClient.execute("pwd");
                                if (shellStatus == "shell_started") {
                                  final result = await newClient
                                      .writeToShell(userEnteredCommands);

                                  sshClientResult.add(result);
                                  print(sshClientResult
                                      .map((e) => print(e.length)));
                                  addLocalHost();
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
