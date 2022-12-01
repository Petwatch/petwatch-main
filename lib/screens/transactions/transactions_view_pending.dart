import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/profile/view_profile_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/services/stripe-backend-service.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ViewPendingPage extends StatefulWidget {
  final int amount;
  final Map<String, dynamic> transaction;
  final Widget transactionWidget;

  ViewPendingPage(
      {super.key,
      required this.transaction,
      required this.transactionWidget,
      required this.amount});
  @override
  ViewPendingPageState createState() => ViewPendingPageState(
      transaction: this.transaction,
      transactionWidget: this.transactionWidget,
      amount: this.amount);
}

class ViewPendingPageState extends State<ViewPendingPage> {
  final Map<String, dynamic> transaction;
  final Widget transactionWidget;
  final int amount;

  ViewPendingPageState(
      {required this.transaction,
      required this.transactionWidget,
      required this.amount});

  Widget commentCard(BuildContext context, List<dynamic> transaction, int index,
      UserModel user) {
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
                onPressed: (() async {
                  var email = FirebaseAuth.instance.currentUser!.email ?? "";
                  var data = await CreatePaymentSheet.getPaymentIntent(
                      transaction[index]["stripeExpressId"],
                      amount,
                      "building-codes/${user.buildingCode['buildingCode']}/users/${user.uid['uid']}",
                      email);
                  await stripe.Stripe.instance.initPaymentSheet(
                      paymentSheetParameters:
                          stripe.SetupPaymentSheetParameters(
                    merchantDisplayName: "Petwatch",
                    paymentIntentClientSecret: data["paymentIntent"],
                    customerEphemeralKeySecret: data['ephemeralKey'],
                    customerId: data["customer"],
                    // applePay: PaymentSheetApplePay,
                    // googlePay: true,
                  ));

                  try {
                    await stripe.Stripe.instance.presentPaymentSheet();
                    await FirebaseFirestore.instance
                        .doc(this.transaction['documentPath'])
                        .get()
                        .then((value) {
                      List<dynamic> requestsArr = value.data()?['requests'];
                      for (var request in requestsArr) {
                        if (request['petSitterUid'] !=
                            transaction[index]['petSitterUid']) {
                          request['status'] = "rejected";
                        } else {
                          request['status'] = "approved";
                        }
                      }
                      value.reference.update(
                          {"status": "scheduled", "requests": requestsArr});
                    });

                    var petNames =
                        this.transaction['petInfo'].map((pet) => pet['name']);
                    Map<String, dynamic> scheduleApiBody = {
                      "postType": "scheduledNotification",
                      "startTimeStamp": this.transaction['dateRange']
                          ['startTime'],
                      "endTimeStamp": this.transaction['dateRange']['endTime'],
                      "petSitterUID": transaction[index]['petSitterUid'],
                      "customerUID": this.transaction['postedBy']["UID"],
                      "petNames": petNames.toList(),
                      "sitterName": transaction[index]["name"],
                      "ownerName": this.transaction['postedBy']["name"]
                    };
                    var res = await http.post(
                        Uri.parse(
                            "https://us-central1-petwatch-9a46d.cloudfunctions.net/notify/api/v1/schedule"),
                        headers: <String, String>{
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(scheduleApiBody));

                    debugPrint("${res.statusCode}");

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Routes(1)));

                    /*
                    So, on success, we need to: 
                      - Update the post from review to scheduled - DONE
                      - Update the array of requests, every single array that - DONE
                      - On click event can't be the same now, it is no longer pending
                      - Create a message thread between the two people - Will Temporarily just do navigator.pop, but will do this later.
                      - Send notification to the pet sitter. - need to do this, should be simple
                      - Schedule the notifications to be sent out day before and day of, to both parties.
                     */
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                }),
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
    return Consumer<UserModel>(builder: ((context, user, child) {
      var transactionList = [];

      for (var i = 0; i < transaction['requests'].length; i++) {
        transactionList.insert(
            0, commentCard(context, transaction['requests'], i, user));
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
                  child: Text("Available Sitters:",
                      style: TextStyle(fontSize: 25)),
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
    }));
  }
}
