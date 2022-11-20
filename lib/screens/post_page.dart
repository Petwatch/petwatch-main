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
    var commentpictureUrl = comment.containsKey("commentAuthorPictureUrl")
        ? comment['commentAuthorPictureUrl'] as String
        : "";

    return Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    backgroundImage: commentpictureUrl != ""
                        ? NetworkImage(commentpictureUrl)
                        : AssetImage('assets/images/petwatch_logo.png')
                            as ImageProvider,
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
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

  bool requestSent = false;

  @override
  void initState() {
    super.initState();
    if (!widget.post.containsKey("requests")) {
      requestSent = false;
    } else {
      widget.post["requests"].forEach((val) => {
            debugPrint(val.toString()),
            debugPrint(val["petSitterUid"]),
            if (val["petSitterUid"] == FirebaseAuth.instance.currentUser!.uid)
              {
                requestSent = true,
              }
          });
    }
  }
  // List<dynamic> requests = post["requests"];

  @override
  Widget build(BuildContext context) {
    // debugPrint("$post");
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    final _commentFieldController = TextEditingController();
    final _focusCommentField = FocusNode();
    final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);
    var pictureUrl = post['postedBy'].containsKey("pictureUrl")
        ? post['postedBy']['pictureUrl'] as String
        : "";

    var description = post['desc'] as String;
    UserModel userModel = UserModel();
    userModel.addListener(() {
      debugPrint("New Comment has been added");
    });
    bool requestLoading = false;
    bool isSeller;

    return Consumer<UserModel>(builder: ((context, user, child) {
      List<Widget> commentList = [];

      final Map<String, dynamic> thePost = user.posts.firstWhere(
          (e) => e["documentID"]! == post["documentID"], orElse: (() {
        return {};
      }));

      // debugPrint(post["requests"].toString());

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
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0, top: 8.0),
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: pictureUrl !=
                                                          ""
                                                      ? NetworkImage(pictureUrl)
                                                      : AssetImage(
                                                              'assets/images/petwatch_logo.png')
                                                          as ImageProvider,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Text(
                                                    "${post['postedBy']['name']} | "),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Text(formattedDate),
                                              ),
                                              if (post['type'] != "Info" &&
                                                  post['price'] != null)
                                                (Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Text(
                                                    " | \$${post['price']}",
                                                  ),
                                                )),
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
                                                  label: Text(
                                                    post['type'],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              Tooltip(
                                key: tooltipkey,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ]),
                                triggerMode: TooltipTriggerMode.manual,
                                showDuration: const Duration(seconds: 1),
                                richMessage: TextSpan(
                                    text:
                                        "Become a pet sitter to accept requests.",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!user.isSitter) {
                                      tooltipkey.currentState
                                          ?.ensureTooltipVisible();
                                    } else if (!requestSent) {
                                      setState(() {
                                        requestLoading = true;
                                      });
                                      await FirebaseFirestore.instance
                                          .doc(post["docPath"])
                                          .update({
                                        "requests": [
                                          {
                                            "petSitterUid": user.uid['uid'],
                                            "name": user.name["name"],
                                            "stripeExpressId":
                                                user.stripeExpressId,
                                            "petSitterPictureUrl":
                                                user.pictureUrl["pictureUrl"],
                                            "status": "pending"
                                          }
                                        ]
                                      }).then((value) {
                                        setState(() {
                                          requestLoading = false;
                                          requestSent = true;
                                        });
                                      });
                                    }
                                  },
                                  child: requestLoading
                                      ? CircularProgressIndicator()
                                      : Text(
                                          requestSent
                                              ? "Request Pending"
                                              : "Accept Request",
                                          style: TextStyle(
                                              color: user.isSitter
                                                  ? Colors.white
                                                  : Colors.grey[600]),
                                        ),
                                  style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                          Size(350, 30)),
                                      backgroundColor: user.isSitter
                                          ? requestSent
                                              ? MaterialStateProperty.all(
                                                  Colors.orange[400])
                                              : MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary)
                                          : MaterialStateProperty.all(
                                              Colors.grey[400])),
                                  // enabled: false
                                ),
                              ),
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
                          "commentAuthorPictureUrl": user.hasPicture
                              ? user.pictureUrl["pictureUrl"]
                              : "",
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
