import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/transactions/transactions_view_pending.dart';
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
      debugPrint("Type: ${path["type"]}");
      await FirebaseFirestore.instance.doc(path['path']).get().then((value) {
        if (path["type"] != null) {
          debugPrint("This is happening");
          Map<String, dynamic>? test = value.data();
          test?.putIfAbsent("transactionType", () => path['type']);
          test?.putIfAbsent("transactionStatus", () => path['status']);
          transactions.insert(0, test);
          debugPrint(test.toString());
        } else {
          transactions.insert(0, value.data());
          debugPrint(value.data().toString());
        }
      });
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, value, child) {
      return Scaffold(
        appBar: const TopNavBar(),
        body: FutureBuilder(
          future: getTransactions(value.transactions),
          builder: (context, snapshot) {
            // debugPrint("${snapshot.data}");
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
                      debugPrint("${snapshot.data![index]['transactionType']}");
                      if (snapshot.data![index]['transactionType'] == null) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewPendingPage(
                                            transaction: snapshot.data![index],
                                            transactionWidget: selfTransaction(
                                                snapshot, index),
                                            amount: int.parse(snapshot
                                                .data![index]['price']))));
                              },
                              child: selfTransaction(snapshot, index),
                            ));
                      } else {
                        return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: otherTransaction(snapshot, index));
                      }
                    },
                  );
                }
            }
          },
        ),
      );
    }));
  }

  FractionallySizedBox selfTransaction(
      AsyncSnapshot<List<dynamic>> snapshot, int index) {
    final requestPostDateFormat = new DateFormat('MMMd');
    return FractionallySizedBox(
      widthFactor: .95,
      child: Card(
          elevation: 2,
          child: IntrinsicHeight(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Pet Sitting" + " | "),
                    ),
                    if (snapshot.data![index]['type'] != "Info" &&
                        snapshot.data![index]['price'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: (Row(
                          children: [
                            Text(
                              "-\$${snapshot.data![index]["price"]}",
                              style: TextStyle(color: Colors.red),
                            ),
                            Text(" | "),
                          ],
                        )),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(requestPostDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(snapshot
                                  .data![index]['dateRange']['startTime'])) +
                          " - " +
                          requestPostDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(snapshot
                                  .data![index]['dateRange']['endTime']))),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        snapshot.data![index]['desc'],
                        softWrap: false,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            switch (snapshot.data![index]["status"]) {
                              case "waiting":
                                return Colors.yellow;
                              case "review":
                                return Colors.green;
                              case "in progress":
                                return Colors.blue;
                              default:
                                return Colors.yellow;
                            }
                          })(),
                          label: Text(snapshot.data![index]["status"])),
                      //Make text color white
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  FractionallySizedBox otherTransaction(
      AsyncSnapshot<List<dynamic>> snapshot, int index) {
    final requestPostDateFormat = new DateFormat('MMMd');
    return FractionallySizedBox(
      widthFactor: .95,
      child: Card(
          elevation: 2,
          child: IntrinsicHeight(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Pet Sitting" + " | "),
                    ),
                    if (snapshot.data![index]['type'] != "Info" &&
                        snapshot.data![index]['price'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: (Row(
                          children: [
                            Text("+\$${snapshot.data![index]["price"]}",
                                style: TextStyle(color: Colors.green)),
                            Text(" | ")
                          ],
                        )),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(requestPostDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(snapshot
                                  .data![index]['dateRange']['startTime'])) +
                          " - " +
                          requestPostDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(snapshot
                                  .data![index]['dateRange']['endTime']))),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        snapshot.data![index]['desc'],
                        softWrap: false,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            switch (snapshot.data![index]
                                ["transactionStatus"]) {
                              case "waiting":
                                return Colors.yellow;
                              case "in progress":
                                return Colors.green;
                              case "scheduled":
                                return Colors.blue;
                              default:
                                return Colors.yellow;
                            }
                          })(),
                          label:
                              Text(snapshot.data![index]["transactionStatus"])),
                      Spacer(),
                      Card(
                        shape: CircleBorder(),
                        elevation: 2,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          backgroundImage: snapshot.data![index]["postedBy"]
                                      ["pictureUrl"] !=
                                  ""
                              ? NetworkImage(snapshot.data![index]["postedBy"]
                                  ["pictureUrl"])
                              : AssetImage('assets/images/petwatch_logo.png')
                                  as ImageProvider,
                        ),
                      ),
                      Text(snapshot.data![index]["postedBy"]["name"])

                      //Make text color white
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
