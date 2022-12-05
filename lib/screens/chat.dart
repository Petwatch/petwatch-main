import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/components/components.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/group_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/message_tile.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:petwatch/utils/db_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final storage = FirebaseStorage.instance;
// Points to the root reference
final storageRef = FirebaseStorage.instance.ref();

// Points to "images"

// Note that you can use variables to create child values

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String? notifyUID;
  const ChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
    this.notifyUID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  File? imageFile;

  Future getImage() async {
    // ImagePicker _picker = ImagePicker();

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      imageFile = File(result.files.single.path.toString());
      uploadImage();
    }
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(fileName)
        .set({
      "sender": widget.userName,
      "message": "",
      "type": "image/jpeg",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    final metadata = SettableMetadata(contentType: "image/jpeg");
    var uploadTask =
        await ref.putFile(imageFile!, metadata).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .update({'imageUrl': imageUrl});

      NetworkImage(imageUrl);
    }
  }

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sender": widget.userName,
        "message": messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
        "imageUrl": ""
      };

      messageController.clear();
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(messages);
    } else {
      print("Message send failure. Try again later.");
    }
  }

  getChatandAdmin() {
    //get chatsr
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });

    //get chat admin/owner
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      debugPrint(val.toString());
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () => getImage(),
                      icon: const Icon(Icons.photo),
                    ),
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();
  _scrollToEnd() {
    final position = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(position);
    // _scrollControllerlistScrollController.jumpTo(position);.animateTo(_scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  chatMessages() {
    if (_scrollController.hasClients) {
      _scrollToEnd();
    }
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: FirebaseAuth.instance.currentUser!.uid ==
                            snapshot.data.docs[index]['uid'],
                        url: snapshot.data.docs[index]["imageUrl"] ?? "");
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      // debugPrint(widget.)
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "time": FieldValue.serverTimestamp(),
        "type": "text",
        "imageUrl": ""
      };

      if (widget.notifyUID != null) {
        http.post(
            Uri.parse(
                "https://us-central1-petwatch-9a46d.cloudfunctions.net/notify/api/v1/message"),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              "name": widget.userName,
              "message": messageController.text,
              "groupPath": "groups/${widget.groupId}",
              "senderUID": FirebaseAuth.instance.currentUser!.uid
            }));
      }

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
