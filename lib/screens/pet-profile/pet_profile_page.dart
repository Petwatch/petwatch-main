import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/pet-profile/pet_edit_info.dart';
import 'package:petwatch/screens/pet-profile/pet_setup_info.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

enum Menu { edit, delete, itemThree, itemFour }

class PetProfilePage extends StatefulWidget {
  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

void DeletePet(index, value, context) async {
  await FirebaseFirestore.instance
      .doc(
          "/building-codes/${value.buildingCode['buildingCode']}/users/${value.uid['uid']}/pets/${value.petInfo[index]['petId']}")
      .delete()
      .then(((result) async {
    value.petInfo[index]['pictureUrl'] != null
        ? await FirebaseStorage.instance
            .ref()
            .child('${value.uid['uid']}/${value.petInfo[index]['petId']}.jpg')
            .delete()
            .then(value.getUserData().then(Navigator.pop(context, 'Delete')))
        : value.getUserData().then(Navigator.pop(context, 'Delete'));
  }));
}

class _PetProfilePageState extends State<PetProfilePage> {
  Widget _buildPetData(BuildContext context, UserModel value, int index) {
    // List<Widget> list = new List<Widget>();
    // // return list;
    // for(var pet in value.petInfo){

    // }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 10,
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PopupMenuButton(
                      padding: EdgeInsets.all(0),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      position: PopupMenuPosition.under,
                      icon: Icon(Icons.menu),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: Menu.edit,
                          child: Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PetEditInfo(value, index)));
                                },
                                child: Text('Edit\nPet Profile',
                                    textAlign: TextAlign.center)),
                          ),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: Menu.delete,
                          child: Center(
                            child: TextButton(
                                // onPressed: () {
                                //   debugPrint("Deleting pet at index ${index}");
                                //   debugPrint(
                                //       "Building Code: ${value.buildingCode['buildingCode']}");
                                //   debugPrint("UID: ${value.uid['uid']}");
                                //   debugPrint(
                                //       "petID: ${value.petInfo[index]['petId']}");
                                //   DeletePet(index, value);
                                // },
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Text("Delete Pet Profile"),
                                            content: Text(
                                                "Are you sure you wish to delete this pet's profile?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: Text("Cancel")),
                                              TextButton(
                                                  onPressed: (() {
                                                    DeletePet(
                                                        index, value, context);
                                                  }),
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ))
                                            ],
                                          ));
                                },
                                child: Text("Delete\nPet Profile",
                                    textAlign: TextAlign.center)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: value.hasPet
                            ? value.petInfo[index]['pictureUrl'] != null
                                ? NetworkImage(
                                    value.petInfo[index]['pictureUrl'])
                                : AssetImage(
                                        'assets/images/petwatch_logo_white.png')
                                    as ImageProvider
                            : AssetImage(
                                    'assets/images/petwatch_logo_white.png')
                                as ImageProvider),
                  ),
                  Text(
                    // value.petInfo['name'],
                    value.petInfo[index]['name'],
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      value.petInfo[index]['breed'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 300,
                    child: Text(value.petInfo[index]['other']),
                  ),
                  SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Row(
                              children: [
                                if (value.petInfo[index]['houseTrained'] ==
                                    "yes")
                                  Chip(
                                    elevation: 5,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    label: const SizedBox(
                                        width: 50,
                                        height: 25,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Trained",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))),
                                    labelPadding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                    ),
                                  ),
                                if (value.petInfo[index]['microChipped'] ==
                                    "yes")
                                  Chip(
                                    elevation: 5,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    label: const SizedBox(
                                        width: 50,
                                        height: 25,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Chip",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))),
                                    labelPadding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                    ),
                                  ),
                                if (value.petInfo[index]['friendlyWith']
                                    .containsValue(true))
                                  Chip(
                                    elevation: 5,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    label: const SizedBox(
                                        width: 50,
                                        height: 25,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Friendly",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))),
                                    labelPadding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                    ),
                                  ),
                              ],
                            ))),
                  ),
                  SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Row(
                              children: [
                                Chip(
                                  elevation: 5,
                                  label: SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              value.petInfo[index]['type']))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                                Chip(
                                  elevation: 5,
                                  label: SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              value.petInfo[index]["sex"]))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                                Chip(
                                  elevation: 5,
                                  label: SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              "${value.petInfo[index]['age']} years"))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                                Chip(
                                  elevation: 5,
                                  label: SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              "${value.petInfo[index]['weight']} lbs"))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                              ],
                            ))),
                  )
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
      List<Widget> petList = [];

      for (int i = 0; i < value.petInfo.length; i++) {
        petList.add(_buildPetData(context, value, i));
      }
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                color: Colors.white,
                iconSize: 35,
                icon: const Icon(Icons.keyboard_arrow_left),
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Routes(2)))
                },
              ),
              title: Container(
                width: 75,
                height: 75,
                child: Image.asset(
                  'assets/images/petwatch_logo_white.png',
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                ...petList,
                ElevatedButton(
                    onPressed: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PetSetupInfo()));
                    }),
                    child: Text(
                      "Add Pet",
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ))
              ]),
            ),
          ));
    });
  }
}
