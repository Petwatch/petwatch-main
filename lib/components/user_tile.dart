import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:petwatch/components/components.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserTile extends StatefulWidget {
  final String userName;
  final String recipientId;
  final String recipientName;
  const UserTile(String string,
      {Key? key,
      required this.recipientId,
      required this.recipientName,
      required this.userName})
      : super(key: key);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.recipientId,
              groupName: widget.recipientName,
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
              widget.recipientName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.recipientName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Start a conversation",
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        ),
      ),
    );
  }
}
