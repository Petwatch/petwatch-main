import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';

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
        child: IntrinsicHeight(
          child: Column(
            children: [
              Padding(
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
                  Text(post['comments'][0]['commentAuthorName']),
                  Container(
                    child: const VerticalDivider(
                      width: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                  ),
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
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
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
      commentList.add(commentCard(context, comment, index));
    });
    return Scaffold(
        appBar: MessageNavBar(),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FractionallySizedBox(
                  widthFactor: .95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                          elevation: 2,
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Padding(
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
                                    Text(post['postedBy']['name']),
                                    Container(
                                      child: const VerticalDivider(
                                        width: 20,
                                        thickness: 1,
                                        indent: 20,
                                        endIndent: 0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(formattedDate),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Flexible(
                                        child: Text(
                                          description,
                                          // softWrap: false,
                                          // maxLines: 2,
                                          overflow: TextOverflow.clip,
                                        ),
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
                      ElevatedButton(onPressed: () {}, child: Text("Reply")),
                      ...commentList
                    ],
                  ))),
        ));
  }
}
