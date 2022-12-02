import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:petwatch/components/CustomRatingDialog.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/view_pet_profile_page.dart';
import 'package:petwatch/screens/profile/view_profile_page.dart';
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
                                                      snapshot, index, value),
                                              amount: int.parse(snapshot
                                                  .data![index]['price']))));
                                }
                              },
                              child: selfTransaction(snapshot, index, value),
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
      // RegExp removeUnderscore = new RegExp(r"(/_/g)");
      AsyncSnapshot<List<dynamic>> snapshot,
      int index,
      UserModel user) {
    final requestPostDateFormat = new DateFormat('MMMd');
    List<Widget> petList = [];
    if (snapshot.data![index]['type'] != "Info" &&
        snapshot.data![index]['price'] != null) {
      for (var petData in snapshot.data![index]['petInfo']) {
        petList.add(displayPet(petData));
      }
    }

    bool showReviewButton = true;
    String petSitterUid = "";
    String petSitterName = "";
    String petSitterPictureUrl = "";
    Map<String, dynamic> petSitterData = {};

    if (snapshot.data![index].containsKey('requests')) {
      for (var request in snapshot.data![index]['requests']) {
        petSitterUid = request['petSitterUid'];
        petSitterName = request['name'];
        petSitterPictureUrl = request['petSitterPictureUrl'];
        petSitterData = {
          'UID': petSitterUid,
          'name': petSitterName,
          'pictureUrl': petSitterPictureUrl
        };
      }
      if (snapshot.data![index]['reviewed'] == true) showReviewButton = false;
    }
    void _showRatingAppDialog() {
      final _ratingDialog = CustomRatingDialog(
        starColor: Colors.amber,
        starSize: 30,
        title: [Center(child: Text('Reviewing ${petSitterName}'))],
        submitButtonText: 'Submit',
        submitButtonTextStyle: TextStyle(color: Colors.white),
        onCancelled: () => print('cancelled'),
        onSubmitted: (response) async {
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${petSitterUid}')
              .get()
              .then((value) {
            if (value.data()!['reviews'] != null) {
              List<dynamic> oldReviewArray = value.data()!['reviews'];
              bool found = false;
              for (var reviewedUser in user.reviewedUsers) {
                if (reviewedUser['reviewedUserUID'] == petSitterUid) {
                  found = true;
                  oldReviewArray.asMap().forEach((index, value) => {
                        if (value['reviewerUid'] == user.uid['uid'])
                          {
                            oldReviewArray[index] = {
                              "reviewerName": user.name['name'],
                              "reviewerPictureUrl":
                                  user.pictureUrl['pictureUrl'],
                              "reviewerUid": user.uid['uid'],
                              "comment": response.comment,
                              "stars": response.rating
                            }
                          }
                      });
                }
              }
              if (!found) {
                value.reference.update({
                  "reviews": FieldValue.arrayUnion([
                    {
                      "reviewerName": user.name['name'],
                      "reviewerUid": user.uid['uid'],
                      "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                      "comment": response.comment,
                      "stars": response.rating
                    }
                  ])
                });
              } else {
                debugPrint("Array: " + oldReviewArray.toString());
                value.reference.update({"reviews": oldReviewArray});
              }
            } else {
              value.reference.update({
                "reviews": [
                  {
                    "reviewerName": user.name['name'],
                    "reviewerUid": user.uid['uid'],
                    "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                    "comment": response.comment,
                    "stars": response.rating
                  }
                ]
              });
            }
          });
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${user.uid['uid']}')
              .update({
            "reviewedUsers": FieldValue.arrayUnion([
              {"reviewedUserUID": petSitterUid}
            ])
          });
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/posts/${snapshot.data![index]['documentID']}')
              .update({"reviewed": true});
          await user.getUserData();
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
                        width: 85,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: (() {
                                    switch (snapshot.data![index]["status"]) {
                                      case "waiting":
                                        return Colors.orange.withOpacity(.5);
                                      case "in_progress":
                                        return Colors.blue.withOpacity(.5);
                                      case "scheduled":
                                        return Colors.green.withOpacity(.5);
                                      case "denied":
                                        return Colors.red.withOpacity(.5);
                                      case "complete":
                                        return Colors.grey.withOpacity(.5);
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
                                  case "scheduled":
                                    return Colors.green.withOpacity(.8);
                                  case "denied":
                                    return Colors.red.withOpacity(.8);
                                  case "complete":
                                    return Colors.grey.withOpacity(.8);
                                  default:
                                    return Colors.orange.withOpacity(.8);
                                }
                              })(),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: snapshot.data![index]['status'] !=
                                        "in_progress"
                                    ? Text(
                                        toBeginningOfSentenceCase(
                                                snapshot.data![index]['status'])
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    : Text(
                                        "In Progress",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                              ),
                            )),
                      ),
                      Spacer(),
                      // ...petList,
                      if (petSitterName != "")
                        Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    petSitterData.isNotEmpty
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewProfilePage(
                                                        petSitterData)))
                                        : null;
                                  },
                                  child: Card(
                                    shape: CircleBorder(),
                                    elevation: 2,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      backgroundImage: petSitterPictureUrl != ""
                                          ? NetworkImage(petSitterPictureUrl)
                                          : AssetImage(
                                                  'assets/images/petwatch_logo.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                                Text(petSitterName),
                              ],
                            ),
                            Row(
                              children: [...petList],
                            ),
                          ],
                        )
                      else
                        ...petList
                    ],
                  ),
                ),
                if (snapshot.data![index]["status"] == 'complete' &&
                    showReviewButton)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
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

    bool showReviewButton = true;
    String petSitterUid = "";
    String petSitterName = "";
    String petSitterPictureUrl = "";
    // snapshot.data![index]["postedBy"]["name"]

    if (snapshot.data![index].containsKey('requests')) {
      if (snapshot.data![index]['reviewed'] == true) showReviewButton = false;
      petSitterName = snapshot.data![index]["postedBy"]["name"];
      petSitterUid = snapshot.data![index]["postedBy"]["UID"];
      petSitterPictureUrl = snapshot.data![index]["postedBy"]["pictureUrl"];
    }

    void _showRatingAppDialog() {
      final _ratingDialog = CustomRatingDialog(
        starColor: Colors.amber,
        starSize: 30,
        title: [Center(child: Text('Reviewing ${petSitterName}'))],
        submitButtonText: 'Submit',
        submitButtonTextStyle: TextStyle(color: Colors.white),
        onCancelled: () => print('cancelled'),
        onSubmitted: (response) async {
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${petSitterUid}')
              .get()
              .then((value) {
            if (value.data()!['reviews'] != null) {
              List<dynamic> oldReviewArray = value.data()!['reviews'];
              bool found = false;
              for (var reviewedUser in user.reviewedUsers) {
                if (reviewedUser['reviewedUserUID'] == petSitterUid) {
                  found = true;
                  oldReviewArray.asMap().forEach((index, value) => {
                        if (value['reviewerUid'] == user.uid['uid'])
                          {
                            oldReviewArray[index] = {
                              "reviewerName": user.name['name'],
                              "reviewerPictureUrl":
                                  user.pictureUrl['pictureUrl'],
                              "reviewerUid": user.uid['uid'],
                              "comment": response.comment,
                              "stars": response.rating
                            }
                          }
                      });
                }
              }
              if (!found) {
                value.reference.update({
                  "reviews": FieldValue.arrayUnion([
                    {
                      "reviewerName": user.name['name'],
                      "reviewerUid": user.uid['uid'],
                      "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                      "comment": response.comment,
                      "stars": response.rating
                    }
                  ])
                });
              } else {
                debugPrint("Array: " + oldReviewArray.toString());
                value.reference.update({"reviews": oldReviewArray});
              }
            } else {
              value.reference.update({
                "reviews": [
                  {
                    "reviewerName": user.name['name'],
                    "reviewerUid": user.uid['uid'],
                    "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                    "comment": response.comment,
                    "stars": response.rating
                  }
                ]
              });
            }
          });
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${user.uid['uid']}')
              .update({
            "reviewedUsers": FieldValue.arrayUnion([
              {"reviewedUserUID": petSitterUid}
            ])
          });
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/posts/${snapshot.data![index]['documentID']}')
              .update({"reviewed": true});
          await user.getUserData();
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
                        width: 85,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: (() {
                                    switch (transactionStatus) {
                                      case "waiting":
                                        return Colors.orange.withOpacity(.5);
                                      case "in_progress":
                                        return Colors.blue.withOpacity(.5);
                                      case "scheduled":
                                        return Colors.green.withOpacity(.5);
                                      case "denied":
                                        return Colors.red.withOpacity(.5);
                                      case "complete":
                                        return Colors.grey.withOpacity(.5);
                                      default:
                                        return Colors.green.withOpacity(.5);
                                    }
                                  })(),
                                  width: 3),
                              borderRadius: BorderRadius.circular(5),
                              color: (() {
                                switch (transactionStatus) {
                                  case "waiting":
                                    return Colors.orange.withOpacity(.8);
                                  case "in_progress":
                                    return Colors.blue.withOpacity(.8);
                                  case "scheduled":
                                    return Colors.green.withOpacity(.8);
                                  case "denied":
                                    return Colors.red.withOpacity(.8);
                                  case "complete":
                                    return Colors.grey.withOpacity(.8);
                                  default:
                                    return Colors.green.withOpacity(.8);
                                }
                              })(),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: transactionStatus != "in_progress"
                                    ? Text(
                                        toBeginningOfSentenceCase(
                                                transactionStatus)
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    : Text(
                                        "In Progress",
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
                              GestureDetector(
                                onTap: () {
                                  snapshot.data![index]["postedBy"].isNotEmpty
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewProfilePage(
                                                      snapshot.data![index]
                                                          ["postedBy"])))
                                      : null;
                                },
                                child: Card(
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
                if (transactionStatus == 'complete' && showReviewButton)
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
