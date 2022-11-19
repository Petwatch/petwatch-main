import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:provider/provider.dart';

import '../state/user_model.dart';

class PostPage extends StatefulWidget {
  final Map<String, dynamic> post;

  PostPage({super.key, required this.post});
  @override
  PostPageState createState() => PostPageState(post: this.post);
}

class PostPageState extends State<PostPage> {
  final Map<String, dynamic> post;

  PostPageState({required this.post});

  // If the request post is not mine, and the person that clicks on it is a registered pet sitter, show the button

  Widget commentCard(
      BuildContext context, Map<String, dynamic> comment, int index) {
    final commentDateFormat = new DateFormat('MMMd');
    final timestamp = comment['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    var formattedDate = commentDateFormat.format(datePosted);

    var commentText = comment['commentText'] as String;
    var commentAuthor = comment['commentAuthorName'] as String;

    return Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(children: [
                CircleAvatar(
                  // radius: 75,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.asset(
                      'assets/images/petwatch_logo.png',
                    ),
                  ),
                ),
                Text("${commentAuthor}  |  "),
                Text(formattedDate),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    commentText,
                    softWrap: false,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("$post");
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    final _commentFieldController = TextEditingController();
    final _focusCommentField = FocusNode();
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);

    var description = post['desc'] as String;
    UserModel userModel = UserModel();
    userModel.addListener(() {
      debugPrint("New Comment has been added");
    });

    return Consumer<UserModel>(builder: ((context, user, child) {
      // final test = Provider.of<UserModel>(context).posts;
      // debugPrint("${test[0]["comments"].toString()}");
      debugPrint("ReRendering");
      // debugPrint("${post["comments"].length}");
      // debugPrint("${post['comments'].length}");
      List<Widget> commentList = [];

      final Map<String, dynamic> thePost = user.posts.firstWhere(
          (e) => e["documentID"]! == post["documentID"], orElse: (() {
        return {};
      }));

      // Map<String, dynamic> myPost = user.getPost(post["id"]);
      // debugPrint("myPost: $myPost");
      if (thePost["comments"] != null) {
        for (var i = 0; i < thePost["comments"].length; i++) {
          commentList.insert(
              0, commentCard(context, thePost["comments"][i], i));
        }
      }

      return GestureDetector(
        onTap: () {
          _focusCommentField.unfocus();
        },
        child: Scaffold(
          appBar: MessageNavBar(),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    return user.getPosts();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: IntrinsicHeight(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Card(
                                  elevation: 2,
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(children: [
                                              CircleAvatar(
                                                // radius: 75,
                                                backgroundColor: Colors.white,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  child: Image.asset(
                                                    'assets/images/petwatch_logo.png',
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                  "${post['postedBy']['name']}  |  "),
                                              Text(formattedDate),
                                            ]),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                description,
                                                // softWrap: false,
                                                // maxLines: 2,
                                                overflow: TextOverflow.clip,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Chip(
                                                  backgroundColor: (() {
                                                    switch (post["type"]) {
                                                      case "Info":
                                                        return Colors.yellow;
                                                      case "Request":
                                                        return Colors.green;
                                                      case "Available":
                                                        return Colors.blue;
                                                      default:
                                                        return Colors.yellow;
                                                    }
                                                  })(),
                                                  label: Text(post['type'])),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              Divider(
                                thickness: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              ...commentList
                            ],
                          )),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Container(
                      child: TextFormField(
                        minLines: 1,
                        maxLines: 4,
                        controller: _commentFieldController,
                        focusNode: _focusCommentField,
                        decoration: InputDecoration(hintText: "Comment..."),
                      ),
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        // debugPrint("${post["id"]}");
                        Map comment = <String, dynamic>{
                          "commentAuthorName": user.name["name"],
                          "commentAuthorUID": user.uid["uid"],
                          "commentText": _commentFieldController.text,
                          "postedTime": Timestamp.now()
                        };

                        // debugPrint("$comment");
                        FirebaseFirestore.instance
                            .collection(
                                "/building-codes/${user.buildingCode["buildingCode"]}/posts/")
                            .doc(post["id"])
                            .update({
                          "comments": FieldValue.arrayUnion([comment])
                        }).then((value) => {
                                  setState(() {
                                    user.getPost(thePost["documentID"],
                                        user.buildingCode["buildingCode"]);
                                  }),
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             PostPage(post: post)))
                                });

                        // context.dispatchNotification(notification)
                      },
                      icon: Icon(Icons.send))
                ],
              )
            ],
          ),
        ),
      );
    }));
  }
}
