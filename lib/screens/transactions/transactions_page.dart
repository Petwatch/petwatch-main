import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/view_pet_profile_page.dart';
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
    // getTransactions(paths)
    super.initState();
  }

  Future<List<dynamic>> getTransactions(String path) async {
    List<dynamic> paths = [];
    await FirebaseFirestore.instance.doc(path).get().then((value) {
      if (value.data()!['transactions'] != null) {
        paths = value.data()!['transactions'];
      }
    });
    List<dynamic> transactions = [];
    for (var path in paths) {
      await FirebaseFirestore.instance.doc(path['path']).get().then((value) {
        Map<String, dynamic>? postData = value.data();
        postData?.putIfAbsent("documentPath", () => value.reference.path);
        if (path["type"] != null) {
          Map<String, dynamic>? test = postData;
          test?.putIfAbsent("transactionType", () => path['type']);
          test?.putIfAbsent("transactionStatus", () => path['status']);
          transactions.insert(0, test);
        } else {
          transactions.insert(0, postData);
        }
      });
    }
    return transactions;
  }

  Widget displayPet(Map<String, dynamic> petData) {
    List<Map<String, dynamic>> petDataList = [petData];
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
              backgroundImage: petData["pictureUrl"] != ""
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, value, child) {
      return Scaffold(
        appBar: const TopNavBar(),
        body: FutureBuilder(
          future: getTransactions(
              "building-codes/${value.buildingCode['buildingCode']}/users/${value.uid['uid']}"),
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
                      if (snapshot.data![index]['transactionType'] == null) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: GestureDetector(
                              onTap: () {
                                if (snapshot.data![index]['status'] ==
                                    'review') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewPendingPage(
                                              transaction:
                                                  snapshot.data![index],
                                              transactionWidget:
                                                  selfTransaction(
                                                      snapshot, index),
                                              amount: int.parse(snapshot
                                                  .data![index]['price']))));
                                }
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
    List<Widget> petList = [];
    if (snapshot.data![index]['type'] != "Info" &&
        snapshot.data![index]['price'] != null) {
      for (var petData in snapshot.data![index]['petInfo']) {
        petList.add(displayPet(petData));
      }
    }

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
                              case "scheduled":
                                return Colors.blue;
                              default:
                                return Colors.yellow;
                            }
                          })(),
                          label: Text(snapshot.data![index]["status"])),
                      Spacer(),
                      ...petList
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
    var transactionStatus = "";
    for (var request in snapshot.data![index]['requests']) {
      if (request["petSitterUid"] == FirebaseAuth.instance.currentUser!.uid) {
        transactionStatus = request['status'];
      }
    }
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
                            switch (transactionStatus) {
                              case "waiting":
                                return Colors.yellow;
                              case "in_progress":
                                return Colors.blue;
                              case "approved":
                                return Colors.green;
                              case "denied":
                                return Colors.red;
                              default:
                                return Colors.yellow;
                            }
                          })(),
                          label: Text(transactionStatus)),
                      Spacer(),
                      Column(
                        children: [
                          Row(
                            children: [
                              Card(
                                shape: CircleBorder(),
                                elevation: 2,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  backgroundImage: snapshot.data![index]
                                              ["postedBy"]["pictureUrl"] !=
                                          ""
                                      ? NetworkImage(snapshot.data![index]
                                          ["postedBy"]["pictureUrl"])
                                      : AssetImage(
                                              'assets/images/petwatch_logo.png')
                                          as ImageProvider,
                                ),
                              ),
                              Text(snapshot.data![index]["postedBy"]["name"]),
                            ],
                          ),
                          Row(
                            children: [
                              Card(
                                shape: CircleBorder(),
                                elevation: 2,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  backgroundImage: snapshot.data![index]
                                              ["postedBy"]["pictureUrl"] !=
                                          ""
                                      ? NetworkImage(snapshot.data![index]
                                          ["postedBy"]["pictureUrl"])
                                      : AssetImage(
                                              'assets/images/petwatch_logo.png')
                                          as ImageProvider,
                                ),
                              ),
                              Text("Pet")
                            ],
                          )
                        ],
                      )

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
