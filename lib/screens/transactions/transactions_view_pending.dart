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

class ViewPendingPage extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Widget transactionWidget;

  ViewPendingPage(
      {super.key, required this.transaction, required this.transactionWidget});
  @override
  ViewPendingPageState createState() => ViewPendingPageState(
      transaction: this.transaction, transactionWidget: this.transactionWidget);
}

class ViewPendingPageState extends State<ViewPendingPage> {
  final Map<String, dynamic> transaction;
  final Widget transactionWidget;

  ViewPendingPageState(
      {required this.transaction, required this.transactionWidget});

  Widget commentCard(
      BuildContext context, List<dynamic> transaction, int index) {
    Map<String, dynamic> postedBy = {
      'UID': transaction[index]['petSitterUid'],
      'name': transaction[index]['name'],
      'pictureUrl': transaction[index]['petSitterPictureUrl']
    };
    return Card(
        elevation: 2,
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                if (transaction[index]['petSitterUid'] !=
                    FirebaseAuth.instance.currentUser!.uid) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewProfilePage(postedBy)));
                }
              },
              child: Card(
                shape: CircleBorder(),
                elevation: 2,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: transaction[index]['petSitterPictureUrl'] !=
                          ""
                      ? NetworkImage(transaction[index]['petSitterPictureUrl'])
                      : AssetImage('assets/images/petwatch_logo.png')
                          as ImageProvider,
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            Text(transaction[index]['name']),
            Spacer(),
            IconButton(
                onPressed: (() {}),
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: (() {}), icon: Icon(Icons.close, color: Colors.red)),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var transactionList = [];

    for (var i = 0; i < transaction['requests'].length; i++) {
      transactionList.insert(
          0, commentCard(context, transaction['requests'], i));
    }
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        appBar: MessageNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Align(alignment: Alignment.center, child: transactionWidget),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child:
                    Text("Available Sitters:", style: TextStyle(fontSize: 25)),
              ),
              Divider(
                thickness: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [...transactionList],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
