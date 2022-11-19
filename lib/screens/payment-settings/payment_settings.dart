import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/stripe-backend-service.dart';

class PaymentSettingsPage extends StatefulWidget {
  // PaymentSettingsPage();
  const PaymentSettingsPage({super.key});

  State<StatefulWidget> createState() {
    return PaymentSettingsPageState();
  }
}

class PaymentSettingsPageState extends State<PaymentSettingsPage> {
  bool isLoading = true;
  bool hasConnectExpress = false;

  _checkForStripeAccount() async {
    await FirebaseFirestore.instance
        .collectionGroup('users')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((res) => {
              res.docs.forEach((element) {
                if (element.data().containsKey("connectExpressId")) {
                  hasConnectExpress = true;
                }
              }),
            });
    debugPrint("This");
  }

  _launchStripeConnect() async {
    CreateAccountResponse response =
        await StripeBackendService.createSellerAccount();
    final Uri _url = Uri.parse(response.url);
    final String _connectExpressId = Uri.parse(response.accountId).toString();
    debugPrint(_connectExpressId);
    FirebaseFirestore.instance
        .collection('building-codes')
        .doc("123456789")
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(<String, String>{"connectExpressId": _connectExpressId});

    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    _checkForStripeAccount();
    setState(() {
      isLoading = false;
    });
    return Scaffold(
        appBar: MessageNavBar(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Payment Methods: "),
                    ElevatedButton(
                        onPressed: () {}, child: Text("Add Payment Method")),
                    !hasConnectExpress
                        ? ElevatedButton(
                            onPressed: (() async {
                              setState(() {
                                isLoading = true;
                              });
                              await _launchStripeConnect();
                            }),
                            child: Text("Become a pet sitter"),
                          )
                        : Text("You have a seller account")
                  ],
                ),
              ));
  }
}
