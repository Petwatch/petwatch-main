import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool isLoading = true;
  late List transactionData;
  @override
  void initState() {
    // debugPrint("${transaction}");
    super.initState();
  }

  // Future<List<Widget>> getTransactions(List<dynamic> paths) async {
  //   debugPrint("$paths");
  //   for (var path in paths) {
  //     FirebaseFirestore.instance
  //         .doc(path)
  //         .get()
  //         .then((value) => {debugPrint("${value.data().toString()}")});
  //   }
  //   return [];
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, value, child) {
      // if (value.transactions != []) {
      // setState(() {
      //   isLoading = false;
      // });
      // ignore: unused_local_variable
      // Future<List<Widget>> test = getTransactions(value.transactions);

      return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: TopNavBar(),
          body: SingleChildScrollView(
              child: Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text("Loaded Transactions"))),
        ),
      );
    }));
  }
}
