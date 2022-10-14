import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:petwatch/screens/pet_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetSetupInfo extends StatefulWidget {
  @override
  _PetSetupInfoState createState() => _PetSetupInfoState();
}

var personalInfoArr = [
  "Cat",
  "Dog",
];

enum petTypeCharacter { cat, dog }

class _PetSetupInfoState extends State<PetSetupInfo> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _weightTextController = TextEditingController();
  final _ageTextController = TextEditingController();
  final _sexTextController = TextEditingController();
  final _breedTextController = TextEditingController();
  final _codeTextController = TextEditingController();
  final _focusName = FocusNode();
  final _focusWeight = FocusNode();
  final _focusAge = FocusNode();
  final _focusSex = FocusNode();
  final _focusBreed = FocusNode();

  bool _isProcessing = false;

  petTypeCharacter? _character = petTypeCharacter.cat;

  var currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: GestureDetector(
          onTap: () {
            _focusName.unfocus();
            _focusWeight.unfocus();
            _focusAge.unfocus();
            _focusSex.unfocus();
            _focusBreed.unfocus();
          },
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text("Pet Profile Setup"),
                bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: IgnorePointer(
                      child: TabBar(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: [
                            Tab(
                                icon: Icon(
                              Icons.circle,
                              color:
                                  DefaultTabController.of(context)?.index == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                            )),
                            Tab(
                                icon: Icon(
                              Icons.circle,
                              color:
                                  DefaultTabController.of(context)?.index == 1
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                            )),
                            Tab(
                                icon: Icon(
                              Icons.circle,
                              color:
                                  DefaultTabController.of(context)?.index == 2
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                            )),
                          ]),
                    )),
                leading: IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 35,
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () => {Navigator.pop(context)},
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
              body: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Form(
                            key: _registerFormKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _nameTextController,
                                  focusNode: _focusName,
                                  decoration: InputDecoration(
                                    hintText: "Name",
                                  ),
                                ),
                                RadioListTile(
                                  title: const Text("Cat"),
                                  value: petTypeCharacter.cat,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                RadioListTile(
                                  title: const Text("Dog"),
                                  value: petTypeCharacter.dog,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _weightTextController,
                                  focusNode: _focusWeight,
                                  decoration: InputDecoration(
                                    hintText: "Weight (lbs)",
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _ageTextController,
                                        focusNode: _focusAge,
                                        decoration: InputDecoration(
                                          hintText: "Age",
                                        ),
                                      ),
                                    )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: _sexTextController,
                                        focusNode: _focusSex,
                                        decoration: InputDecoration(
                                          hintText: "Sex",
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _breedTextController,
                                  focusNode: _focusBreed,
                                  decoration: InputDecoration(
                                    hintText: "Breed(s)",
                                  ),
                                ),
                                SizedBox(height: 32.0),
                                _isProcessing
                                    ? CircularProgressIndicator()
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: GoToSecondTabButton(),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Form(
                            key: _registerFormKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _nameTextController,
                                  focusNode: _focusName,
                                  decoration: InputDecoration(
                                    hintText: "Name",
                                  ),
                                ),
                                RadioListTile(
                                  title: const Text("Cat"),
                                  value: petTypeCharacter.cat,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                RadioListTile(
                                  title: const Text("Dog"),
                                  value: petTypeCharacter.dog,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _weightTextController,
                                  focusNode: _focusWeight,
                                  decoration: InputDecoration(
                                    hintText: "Weight (lbs)",
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _ageTextController,
                                        focusNode: _focusAge,
                                        decoration: InputDecoration(
                                          hintText: "Age",
                                        ),
                                      ),
                                    )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: _sexTextController,
                                        focusNode: _focusSex,
                                        decoration: InputDecoration(
                                          hintText: "Sex",
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _breedTextController,
                                  focusNode: _focusBreed,
                                  decoration: InputDecoration(
                                    hintText: "Breed(s)",
                                  ),
                                ),
                                SizedBox(height: 32.0),
                                _isProcessing
                                    ? CircularProgressIndicator()
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: GoToThirdTabButton(),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Form(
                            key: _registerFormKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _nameTextController,
                                  focusNode: _focusName,
                                  decoration: InputDecoration(
                                    hintText: "Name",
                                  ),
                                ),
                                RadioListTile(
                                  title: const Text("Cat"),
                                  value: petTypeCharacter.cat,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                RadioListTile(
                                  title: const Text("Dog"),
                                  value: petTypeCharacter.dog,
                                  groupValue: _character,
                                  onChanged: (petTypeCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _weightTextController,
                                  focusNode: _focusWeight,
                                  decoration: InputDecoration(
                                    hintText: "Weight (lbs)",
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _ageTextController,
                                        focusNode: _focusAge,
                                        decoration: InputDecoration(
                                          hintText: "Age",
                                        ),
                                      ),
                                    )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: _sexTextController,
                                        focusNode: _focusSex,
                                        decoration: InputDecoration(
                                          hintText: "Sex",
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _breedTextController,
                                  focusNode: _focusBreed,
                                  decoration: InputDecoration(
                                    hintText: "Breed(s)",
                                  ),
                                ),
                                SizedBox(height: 32.0),
                                _isProcessing
                                    ? CircularProgressIndicator()
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  _isProcessing = true;
                                                });
                                                var docRef =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collectionGroup(
                                                            'users')
                                                        .where('uid',
                                                            isEqualTo:
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid
                                                                    .toString())
                                                        .get()
                                                        .then((snapshot) {
                                                  var data = snapshot.docs[0]
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          "building-codes")
                                                      .doc(data['buildingCode'])
                                                      .collection('users')
                                                      .doc(data['uid'])
                                                      .collection("pets")
                                                      .doc(_nameTextController
                                                          .text)
                                                      .set(<String, String>{
                                                    "name": _nameTextController
                                                        .text,
                                                    "type": describeEnum(
                                                        _character!),
                                                    "weight":
                                                        _weightTextController
                                                            .text,
                                                    "age":
                                                        _ageTextController.text,
                                                    "sex":
                                                        _sexTextController.text,
                                                    "breed":
                                                        _breedTextController
                                                            .text
                                                  });
                                                  setState(() {
                                                    _isProcessing = false;
                                                  });
                                                });
                                              },
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}

class GoToSecondTabButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text('Next (Page 2)'),
        onPressed: () {
          print(DefaultTabController.of(context)?.index);
          DefaultTabController.of(context)?.animateTo(1);
          print(DefaultTabController.of(context)?.index);
        });
  }
}

class GoToThirdTabButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text('Next (Page 3)'),
        onPressed: () {
          print(DefaultTabController.of(context)!.index);
          DefaultTabController.of(context)?.animateTo(2);
          print(DefaultTabController.of(context)!.index);
        });
  }
}
