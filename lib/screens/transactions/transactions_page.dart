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
    super.initState();
  }

  Future<List<dynamic>> getTransactions(List<dynamic> paths) async {
    List<dynamic> transactions = [];
    for (var path in paths) {
      debugPrint("${path['path']}");
      await FirebaseFirestore.instance.doc(path['path']).get().then((value) {
        transactions.add(value.data());
        debugPrint("Here:  ${value.data().toString()}");
      });
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, value, child) {
      return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: const TopNavBar(),
          body: FutureBuilder(
            future: getTransactions(value.transactions),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return Text("There has been an error: ${snapshot.error}");
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 50,
                          child: Center(
                              child: Text("${snapshot.data?[0]['status']}")),
                        );
                      },
                    );
                  }
              }
            },
          ),
        ),
      );
    }));
  }
}
