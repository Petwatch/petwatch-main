import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/profile/view_profile_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../state/user_model.dart';
import 'pet-profile/view_pet_profile_page.dart';

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

  Widget displayPet(Map<String, dynamic> petData) {
    List<Map<String, dynamic>> petDataList = [petData];
    debugPrint("$petData");
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ViewPetProfilePage(petDataList, true)));
          },
          child: Card(
            shape: CircleBorder(),
            elevation: 2,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              backgroundImage: petData["pictureUrl"] != null
                  ? NetworkImage(petData["pictureUrl"])
                  : AssetImage('assets/images/petwatch_logo.png')
                      as ImageProvider,
            ),
          ),
        ),
        Text(petData['name'])
      ],
    );
  }

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
    var commentAuthorUID = comment['commentAuthorUID'] as String;

    Map<String, dynamic> commentedBy = {
      'UID': commentAuthorUID,
      'name': commentAuthor,
      'pictureUrl': commentpictureUrl
    };

    return Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: TextButton(
                    onPressed: () {
                      if (commentedBy['UID'] !=
                          FirebaseAuth.instance.currentUser!.uid) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewProfilePage(commentedBy)));
                      }
                    },
                    child: Card(
                      shape: CircleBorder(),
                      elevation: 2,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        backgroundImage: commentpictureUrl != ""
                            ? NetworkImage(commentpictureUrl)
                            : AssetImage('assets/images/petwatch_logo.png')
                                as ImageProvider,
                      ),
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
            if (val["petSitterUid"] == FirebaseAuth.instance.currentUser!.uid)
              {
                requestSent = true,
              }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
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

      List<Widget> petList = [];

      if (thePost['type'] != "Info" && thePost['price'] != null) {
        for (var petData in thePost['petInfo']) {
          petList.add(displayPet(petData));
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
                                          child: Row(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: TextButton(
                                                onPressed: () {
                                                  if (post['postedBy']['UID'] !=
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewProfilePage(
                                                                    post[
                                                                        'postedBy'])));
                                                  }
                                                },
                                                child: Card(
                                                  shape: CircleBorder(),
                                                  elevation: 2,
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage: pictureUrl !=
                                                            ""
                                                        ? NetworkImage(
                                                            pictureUrl)
                                                        : AssetImage(
                                                                'assets/images/petwatch_logo.png')
                                                            as ImageProvider,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                    ),
                                                  ),
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
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  " | \$${post['price']}",
                                                ),
                                              )),
                                          ]),
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
                                              Container(
                                                height: 30,
                                                width: 65,
                                                child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: (() {
                                                            switch (
                                                                post["type"]) {
                                                              case "Info":
                                                                return Colors
                                                                    .blue
                                                                    .withOpacity(
                                                                        0.5);
                                                              case "Request":
                                                                return Colors
                                                                    .green
                                                                    .withOpacity(
                                                                        0.5);
                                                              default:
                                                                return Colors
                                                                    .yellow
                                                                    .withOpacity(
                                                                        0.5);
                                                            }
                                                          })(),
                                                          width: 3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: (() {
                                                        switch (post["type"]) {
                                                          case "Info":
                                                            return Colors.blue
                                                                .withOpacity(
                                                                    0.8);
                                                          case "Request":
                                                            return Colors.green
                                                                .withOpacity(
                                                                    0.8);
                                                          default:
                                                            return Colors.yellow
                                                                .withOpacity(
                                                                    0.8);
                                                        }
                                                      })(),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          post['type'],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              Spacer(),
                                              ...petList
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              if (post["type"] == "Request" &&
                                  post["postedBy"]["UID"] !=
                                      FirebaseAuth.instance.currentUser!.uid &&
                                  post['status'] != 'complete')
                                (Tooltip(
                                  key: tooltipkey,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
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
                                        /* 
                                          needs to also change the status of this transaction
                                        */

                                        /* 
                        Different Status: 
                          Waiting (No Requests Yet)
                          Review (Someone accepted your request, review it)
                          Scheduled (You accepted someones request)
                          In Progress (Happening now)
                          Complete

                          So in transactions, if I accepted someones request, it also needs to show up.
                          but how should it look like? 

                        */
                                        await FirebaseFirestore.instance
                                            .doc(post["docPath"])
                                            .update({
                                          "requests": FieldValue.arrayUnion([
                                            {
                                              "petSitterUid": user.uid['uid'],
                                              "name": user.name["name"],
                                              "stripeExpressId":
                                                  user.stripeExpressId,
                                              "petSitterPictureUrl":
                                                  user.pictureUrl["pictureUrl"],
                                              "status": "pending"
                                            }
                                          ]),
                                          "status": "review"
                                        }).then((value) {
                                          setState(() {
                                            requestLoading = false;
                                            requestSent = true;
                                          });
                                        });
                                        await FirebaseFirestore.instance
                                            .doc(
                                                "/building-codes/${user.buildingCode["buildingCode"]}/users/${user.uid['uid']}")
                                            .update({
                                          "transactions":
                                              FieldValue.arrayUnion([
                                            {
                                              "path": post["docPath"],
                                              "type": "sitter",
                                              "status": "waiting"
                                            }
                                          ])
                                        });
                                        var res = await http.post(
                                            Uri.parse(
                                                "https://us-central1-petwatch-9a46d.cloudfunctions.net/notify/api/v1/request"),
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json',
                                            },
                                            body: jsonEncode(<String, String>{
                                              "path": "${post['docPath']}",
                                              "petSitterName":
                                                  user.name["name"],
                                              "petSitterUID":
                                                  user.uid["uid"] ?? "",
                                              "petSitterUrl": user.hasPicture
                                                  ? user
                                                      .pictureUrl["pictureUrl"]
                                                  : "",
                                            }));
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
                                )),
                              if (post["type"] == "Request" &&
                                  post["postedBy"]["UID"] ==
                                      FirebaseAuth.instance.currentUser!.uid)
                                (ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Routes(1)));
                                  },
                                  child: Text(
                                    "See In Transactions",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                          Size(350, 30)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary)),
                                )),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                                child: Text("Comments",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
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
                      onPressed: () async {
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
                        var res = await http.post(
                            Uri.parse(
                                "https://us-central1-petwatch-9a46d.cloudfunctions.net/notify/api/v1/posts/${post['id']}/comment"),
                            headers: <String, String>{
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, String>{
                              "path": "${post['docPath']}",
                              "commentText": _commentFieldController.text,
                              "commentAuthorName": user.name["name"],
                              "commentAuthorUID": user.uid["uid"] ?? "",
                              "commentAuthorPictureUrl": user.hasPicture
                                  ? user.pictureUrl["pictureUrl"]
                                  : "",
                            }));
                        // debugPrint("${res.body} ${res.statusCode}");
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
