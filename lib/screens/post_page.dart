import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:provider/provider.dart';

import '../state/user_model.dart';

class PostPage extends StatelessWidget {
  final Map<String, dynamic> post;
  PostPage({required this.post});

  Widget commentCard(
      BuildContext context, Map<String, dynamic> comment, int index) {
    final commentDateFormat = new DateFormat('MMMd');
    final timestamp = comment['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    var formattedDate = commentDateFormat.format(datePosted);

    var commentText = comment['commentText'] as String;

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
                Text("${post['comments'][0]['commentAuthorName']}  |  "),
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

    List<Widget> commentList = [];
    // for (var comment in post['comments']) {
    //   commentList.add(commentCard(context, comment, 0));
    // }
    // var commentArr = post['comments'] as List<
    post['comments'].asMap().forEach((index, comment) {
      // commentList.
      commentList.insert(0, commentCard(context, comment, index));
    });

    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
        onTap: () {
          _focusCommentField.unfocus();
        },
        child: Scaffold(
          appBar: MessageNavBar(),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                                                borderRadius: BorderRadius.zero,
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
                                                backgroundColor: Colors.yellow,
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
                        debugPrint("${post["id"]}");
                        Map comment = <String, dynamic>{
                          "commentAuthorName": user.name["name"],
                          "commentAuthorUID": user.uid["uid"],
                          "commentText": _commentFieldController.text,
                          "postedTime": Timestamp.now()
                        };

                        debugPrint("$comment");
                        FirebaseFirestore.instance
                            .collection("/building-codes/123456789/posts/")
                            .doc(post["id"])
                            .update({
                          "comments": FieldValue.arrayUnion([comment])
                        });

                        user.getPosts();
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
