import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/pet-profile/pet_setup_info.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class PetProfilePage extends StatefulWidget {
  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  Widget _buildPetData(BuildContext context, UserModel value, int index) {
    // List<Widget> list = new List<Widget>();
    // // return list;
    // for(var pet in value.petInfo){

    // }
    return Card(
        elevation: 4,
        child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.asset(
                        'assets/images/petwatch_logo.png',
                      ),
                    ),
                  ),
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
                              if (value.petInfo[index]['trained'] == "yes")
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                              if (value.petInfo[index]['microChipped'] == "yes")
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))),
                                  labelPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                ),
                              if (value.petInfo[index]['friendlyWith']
                                  .contains("true"))
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                        child:
                                            Text(value.petInfo[index]["sex"]))),
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
            )));
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
                onPressed: () => {Navigator.pop(context)},
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
            body: Center(
                child: SingleChildScrollView(
              child: Column(children: [
                ...petList,
                ElevatedButton(
                    onPressed: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PetSetupInfo()));
                    }),
                    child: Text("Add Pet"))
              ]),
            )),
          ));
    });
  }
}
