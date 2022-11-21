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

class ViewPetProfilePage extends StatefulWidget {
  List<Map<String, dynamic>> petData;
  bool hasPet;

  ViewPetProfilePage(this.petData, this.hasPet);
  @override
  _ViewPetProfilePageState createState() => _ViewPetProfilePageState();
}

class _ViewPetProfilePageState extends State<ViewPetProfilePage> {
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
                  Card(
                    elevation: 5,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: value.hasPet
                            ? widget.petData[index]['pictureUrl'] != null
                                ? NetworkImage(
                                    widget.petData[index]['pictureUrl'])
                                : AssetImage(
                                        'assets/images/petwatch_logo_white.png')
                                    as ImageProvider
                            : AssetImage(
                                    'assets/images/petwatch_logo_white.png')
                                as ImageProvider),
                  ),
                  Text(
                    // value.petInfo['name'],
                    widget.petData[index]['name'],
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      widget.petData[index]['breed'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 300,
                    child: Text(widget.petData[index]['other']),
                  ),
                  SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Row(
                              children: [
                                if (widget.petData[index]['houseTrained'] ==
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
                                if (widget.petData[index]['microChipped'] ==
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
                                if (widget.petData[index]['friendlyWith']
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
                                              widget.petData[index]['type']))),
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
                                              widget.petData[index]["sex"]))),
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
                                              "${widget.petData[index]['age']} years"))),
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
                                              "${widget.petData[index]['weight']} lbs"))),
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

      for (int i = 0; i < widget.petData.length; i++) {
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
                onPressed: () => {Navigator.pop(context)},
              ),
              title: Text(
                "View Pets",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                ...petList,
              ]),
            ),
          ));
    });
  }
}
