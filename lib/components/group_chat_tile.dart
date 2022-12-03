import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:petwatch/components/components.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  String memberName = "";
  @override
  void initState() {
    tet();
  }

  void tet() async {
    await FirebaseFirestore.instance
        .collection('groups')
        .where('groupId', isEqualTo: widget.groupId)
        .get()
        .then(
      (value) {
        var memberNames = value.docs[0].data()['memberNames'];
        for (var member in memberNames) {
          if (member['uid'] != FirebaseAuth.instance.currentUser!.uid)
            setState(() {
              memberName = member["name"];
            });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Group name: ${widget.groupName}");
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: memberName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              memberName.isNotEmpty
                  ? memberName.substring(0, 1).toUpperCase()
                  : "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            memberName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "recent message",
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        ),
      ),
    );
  }
}
