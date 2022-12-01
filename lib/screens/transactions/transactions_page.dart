import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:petwatch/components/CustomRatingDialog.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/view_pet_profile_page.dart';
import 'package:petwatch/screens/transactions/transactions_view_pending.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

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
                  return Text("");
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
                            child: otherTransaction(snapshot, index, value));
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

    // String completedSitterUid = "";
    // if (post.containsKey('requests')) {
    //   for (var request in post['requests']) {
    //     if (request['status'] == "approved" &&
    //         user.uid['uid'] == request['petSitterUid']) {
    //       completedSitterUid = request['petSitterUid'];
    //     }
    //   }
    // }

    // void _showRatingAppDialog() {
    //   final _ratingDialog = CustomRatingDialog(
    //     starColor: Colors.amber,
    //     starSize: 30,
    //     title: [Center(child: Text('Reviewing ${post['postedBy']['name']}'))],
    //     submitButtonText: 'Submit',
    //     submitButtonTextStyle: TextStyle(color: Colors.white),
    //     onCancelled: () => print('cancelled'),
    //     onSubmitted: (response) async {
    //       await FirebaseFirestore.instance
    //           .doc(
    //               'building-codes/${user.buildingCode['buildingCode']}/users/${post['postedBy']['UID']}')
    //           .update({
    //         "reviews": FieldValue.arrayUnion([
    //           {
    //             "reviewerName": user.name['name'],
    //             "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
    //             "comment": response.comment,
    //             "stars": response.rating
    //           }
    //         ])
    //       });
    //     },
    //     commentHint: "Tell us about your sitter",
    //   );

    //   showDialog(
    //     useSafeArea: false,
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => _ratingDialog,
    //   );
    // }

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
                      Container(
                        height: 30,
                        width: 75,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: (() {
                                    switch (snapshot.data![index]["status"]) {
                                      case "waiting":
                                        return Colors.orange.withOpacity(.5);
                                      case "in_progress":
                                        return Colors.blue.withOpacity(.5);
                                      case "approved":
                                        return Colors.green.withOpacity(.5);
                                      case "denied":
                                        return Colors.red.withOpacity(.5);
                                      case "complete":
                                        return Colors.indigo.withOpacity(.5);
                                      default:
                                        return Colors.orange.withOpacity(.5);
                                    }
                                  })(),
                                  width: 3),
                              borderRadius: BorderRadius.circular(5),
                              color: (() {
                                switch (snapshot.data![index]["status"]) {
                                  case "waiting":
                                    return Colors.orange.withOpacity(.8);
                                  case "in_progress":
                                    return Colors.blue.withOpacity(.8);
                                  case "approved":
                                    return Colors.green.withOpacity(.8);
                                  case "denied":
                                    return Colors.red.withOpacity(.8);
                                  case "complete":
                                    return Colors.indigo.withOpacity(.5);
                                  default:
                                    return Colors.orange.withOpacity(.8);
                                }
                              })(),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  toBeginningOfSentenceCase(
                                          snapshot.data![index]["status"])
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            )),
                      ),
                      Spacer(),
                      ...petList
                    ],
                  ),
                ),
                // if (snapshot.data![index]["status"] == 'complete' &&
                //     completedSitterUid == user.uid['uid'])
                //   Padding(
                //     padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                //     child: (ElevatedButton(
                //       onPressed: () {
                //         _showRatingAppDialog();
                //       },
                //       child: Text(
                //         "Leave a review",
                //         style: TextStyle(color: Colors.white),
                //       ),
                //       style: ButtonStyle(
                //           fixedSize: MaterialStateProperty.all(Size(350, 30)),
                //           backgroundColor: MaterialStateProperty.all(
                //               Theme.of(context).colorScheme.primary)),
                //     )),
                //   )
              ],
            ),
          )),
    );
  }

  FractionallySizedBox otherTransaction(
      AsyncSnapshot<List<dynamic>> snapshot, int index, UserModel user) {
    var transactionStatus = "";
    for (var request in snapshot.data![index]['requests']) {
      if (request["petSitterUid"] == FirebaseAuth.instance.currentUser!.uid) {
        transactionStatus = request['status'];
      }
    }
    final requestPostDateFormat = new DateFormat('MMMd');

    List<Widget> petList = [];
    if (snapshot.data![index]['type'] != "Info" &&
        snapshot.data![index]['price'] != null) {
      for (var petData in snapshot.data![index]['petInfo']) {
        petList.add(displayPet(petData));
      }
    }

    void _showRatingAppDialog() {
      final _ratingDialog = CustomRatingDialog(
        starColor: Colors.amber,
        starSize: 30,
        title: [
          Center(
              child: Text(
                  'Reviewing ${snapshot.data![index]["postedBy"]["name"]}'))
        ],
        submitButtonText: 'Submit',
        submitButtonTextStyle: TextStyle(color: Colors.white),
        onCancelled: () => print('cancelled'),
        onSubmitted: (response) async {
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${snapshot.data![index]['postedBy']['UID']}')
              .update({
            "reviews": FieldValue.arrayUnion([
              {
                "reviewerName": user.name['name'],
                "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                "comment": response.comment,
                "stars": response.rating
              }
            ])
          });
        },
        commentHint: "Tell us about your sitter",
      );

      showDialog(
        useSafeArea: false,
        context: context,
        barrierDismissible: false,
        builder: (context) => _ratingDialog,
      );
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
                      Container(
                        height: 30,
                        width: 75,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.green.withOpacity(.5),
                                  width: 3),
                              borderRadius: BorderRadius.circular(5),
                              color: (() {
                                switch (transactionStatus) {
                                  case "waiting":
                                    return Colors.orange;
                                  case "in_progress":
                                    return Colors.blue;
                                  case "approved":
                                    return Colors.green.withOpacity(.8);
                                  case "denied":
                                    return Colors.red;
                                  default:
                                    return Colors.orange;
                                }
                              })(),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  toBeginningOfSentenceCase(transactionStatus)
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            )),
                      ),
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
                            children: [...petList],
                          ),
                        ],
                      )
                      //Make text color white
                    ],
                  ),
                ),
                if (transactionStatus == 'complete')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: (ElevatedButton(
                      onPressed: () {
                        _showRatingAppDialog();
                      },
                      child: Text(
                        "Leave a review",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(350, 30)),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary)),
                    )),
                  )
              ],
            ),
          )),
    );
  }
}
