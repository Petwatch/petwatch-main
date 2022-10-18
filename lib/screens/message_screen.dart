import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  Stream? groups;
  bool _isLoading = false;

  //TODO
  // @override
  // void initState() {
  //   super.initState();
  //   getUserData();
  // }

  getUserData() async {
    //get username
    //get email

    //GET LIST OF SNAPSHOTS IN STREAM
    //await FirebaseFirestore.instance.currentUSer!.uid
    //get userGroups()
    //.then((snapshot){ setState((){groups = snapshot})}
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              "Messages",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 27),
            ),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Message Screen Placeholder"),
                  ]),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              popupDialogue(context);
            },
            elevation: 0,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popupDialogue(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Tap the '+' icon to start a new chat!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  popupDialogue(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Start a new chat!",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              // groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                ],
              ),
              // actions: [
              //   ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     style: ElevatedButton.styleFrom(
              //         primary: Theme.of(context).primaryColor),
              //     child: const Text("CANCEL"),
              //   ),
              //   ElevatedButton(
              //     onPressed: () async {
              //       if (groupName != "") {
              //         setState(() {
              //           _isLoading = true;
              //         });

              //         //CREATE GROUP
              //         // DatabaseService(
              //         //         uid: FirebaseAuth.instance.currentUser!.uid)
              //         //     .createGroup(userName,
              //         //         FirebaseAuth.instance.currentUser!.uid, groupName)
              //             // .whenComplete(() {
              //           _isLoading = false;
              //         });
              //         Navigator.of(context).pop();
              //       }
              //     },
              //     style: ElevatedButton.styleFrom(
              //         primary: Theme.of(context).primaryColor),
              //     child: const Text("CREATE"),
              //   )
              // ],
            );
          }));
        });
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          //
          if (snapshot.hasData) {
            if (snapshot.data['groups'].length != null) {
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
        });
  }
}
