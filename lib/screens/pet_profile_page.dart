import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/pet-profile/pet_setup_info.dart';

class PetObject {
  String name;
  String type;
  String breed;
  String sex;
  String age;

  PetObject(
      {required this.name,
      required this.type,
      required this.breed,
      required this.sex,
      required this.age});
}

class PetProfilePage extends StatefulWidget {
  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  List<PetObject> petDataArr = [];
  bool gotPets = false;

  Stream<bool> getData() async* {
    Map<String, dynamic> userDocRef;

    var getUserDoc = await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .get()
        .then((snapshot) async {
      userDocRef = snapshot.docs[0].data() as Map<String, dynamic>;
      var addPetData = await FirebaseFirestore.instance
          .collection("building-codes")
          .doc(userDocRef['buildingCode'])
          .collection('users')
          .doc(userDocRef['uid'])
          .collection("pets")
          .get()
          .then((snapshot) {
        for (int i = 0; i < snapshot.docs.length; i++) {
          var petDocRef = snapshot.docs[i].data();
          petDataArr.add(PetObject(
              name: petDocRef['name'],
              type: petDocRef['type'],
              breed: petDocRef['breed'],
              sex: petDocRef['sex'],
              age: petDocRef['age']));
        }
        if (petDataArr.isNotEmpty) {
          gotPets = true;
        }
      });
    });
    if (gotPets == true) {
      yield true;
    } else {
      yield false;
    }
  }

  Widget _buildPetData(BuildContext context) {
    return StreamBuilder(
        stream: getData(),
        builder: ((context, snapshot) {
          while (snapshot.data == null) {
            return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator());
          }
          if (snapshot.data.toString() == 'true') {
            return Positioned(
                right: 0,
                left: 0,
                bottom: 305,
                child: Column(
                  children: [
                    Text("Name: ${petDataArr[0].name}"),
                    Text("Type: ${petDataArr[0].type}"),
                    Text("Breed: ${petDataArr[0].breed}"),
                    Text("Sex: ${petDataArr[0].sex}"),
                    Text("Age: ${petDataArr[0].age}"),
                  ],
                ));
          } else {
            return Positioned(
                right: 0,
                left: 0,
                bottom: 305,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PetSetupInfo()))
                            },
                        child: const Text(
                          "Setup a pet profile!",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ));
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(children: [
              Container(
                height: MediaQuery.of(context).size.height - 120,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                        child: IgnorePointer(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 175,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ))),
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 155,
                        child: IgnorePointer(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Card(
                                    elevation: 15,
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      color: Colors.grey[200],
                                    ))))),
                    Positioned(
                        right: 0,
                        left: 0,
                        bottom: 450,
                        child: IgnorePointer(
                          child: Card(
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
                        )),
                    _buildPetData(context)
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
