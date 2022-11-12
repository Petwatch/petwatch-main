import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/home-page/home_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _CreatePostState();
  }
}

class _CreatePostState extends State<CreatePost> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Info", child: Text("info")),
      const DropdownMenuItem(value: "Request", child: Text("request")),
      const DropdownMenuItem(value: "Available", child: Text("available")),
    ];
    return menuItems;
  }

  final _PostTitle = TextEditingController();
  final _PostContents = TextEditingController();

  final _PostTitleNode = FocusNode();
  final _PostContentsNode = FocusNode();

  bool postCreating = false;

  Widget infoPostForm(BuildContext context, UserModel value) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                labelText: "Title", border: OutlineInputBorder()),
            controller: _PostTitle,
            focusNode: _PostTitleNode,
          ),
          TextField(
            decoration:
                InputDecoration(hintText: "Post", border: OutlineInputBorder()),
            controller: _PostContents,
            keyboardType: TextInputType.multiline,
            focusNode: _PostContentsNode,
            // minLines: 10,
            maxLines: 20,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () {
                    List<Map<String, dynamic>> emptyCommentsArr = [];
                    Map post = <String, dynamic>{
                      "postedBy": <String, dynamic>{
                        "name": value.name['name'],
                        "UID": value.uid['uid'],
                      },
                      "title": _PostTitle.text,
                      "desc": _PostContents.text,
                      "postedTime": Timestamp.now(),
                      "type": selectedPostValue,
                      "comments": emptyCommentsArr
                    };

                    FirebaseFirestore.instance
                        .collection(
                            "/building-codes/${value.buildingCode["buildingCode"]}/posts/")
                        .add({...post})
                        .then((value) => {
                              FirebaseFirestore.instance
                                  .doc(value.path)
                                  .update({"documentID": value.id}),
                            })
                        .then((_) => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Routes())),
                              value.getPosts(),
                            });
                    // debugPrint("$post");
                  },
                  child: Text("Post")))
        ],
      ),
    );
  }

  String selectedPostValue = "Request";

  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, value, child) {
        return GestureDetector(
            onTap: (() {
              _PostTitleNode.unfocus();
              _PostContentsNode.unfocus();
            }),
            child: Scaffold(
              appBar: MessageNavBar(),
              body: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton(
                      value: selectedPostValue,
                      items: dropdownItems,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPostValue = value!;
                        });
                      },
                    ),
                    if (selectedPostValue == "Info") ...[
                      infoPostForm(context, value)
                    ]
                  ],
                ),
              ),
            ));
      },
    );
  }
}
