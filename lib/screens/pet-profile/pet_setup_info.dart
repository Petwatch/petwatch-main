import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetSetupInfo extends StatefulWidget {
  @override
  _PetSetupInfoState createState() => _PetSetupInfoState();
}

enum petTypeCharacter { Cat, Dog }

enum houseTrainedCharacter { yes, no }

enum petSpayedCharacter { yes, no }

enum microChipCharacter { yes, no }

class _PetSetupInfoState extends State<PetSetupInfo>
    with SingleTickerProviderStateMixin {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
  final _stepThreeFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _weightTextController = TextEditingController();
  final _ageTextController = TextEditingController();
  final _sexTextController = TextEditingController();
  final _breedTextController = TextEditingController();
  final _otherTextController = TextEditingController();
  final _focusName = FocusNode();
  final _focusWeight = FocusNode();
  final _focusAge = FocusNode();
  final _focusSex = FocusNode();
  final _focusBreed = FocusNode();
  final _focusOther = FocusNode();

  bool _isProcessing = false;

  petTypeCharacter? _character = petTypeCharacter.Cat;
  houseTrainedCharacter? _trainedCharacter = houseTrainedCharacter.yes;
  petSpayedCharacter? _spayedCharacter = petSpayedCharacter.yes;
  microChipCharacter? _chipCharacter = microChipCharacter.yes;

  var currentTab = 0;

  Map<String, bool> values = {
    'Children': false,
    'Dogs': false,
    'Cats': false,
  };

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusWeight.unfocus();
        _focusAge.unfocus();
        _focusSex.unfocus();
        _focusBreed.unfocus();
        _focusOther.unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Pet Profile Setup"),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(25),
                child: IgnorePointer(
                    child: SizedBox(
                  height: 25,
                  child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                            icon: Icon(
                          Icons.circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 15,
                        )),
                        Tab(
                            icon: Icon(
                          Icons.circle,
                          color: _tabController!.index >= 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          size: 15,
                        )),
                        Tab(
                            icon: Icon(
                          Icons.circle,
                          color: _tabController!.index == 2
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          size: 15,
                        )),
                      ]),
                ))),
            leading: IconButton(
              color: Theme.of(context).colorScheme.primary,
              iconSize: 35,
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () => {
                if (_tabController!.index == 0)
                  {Navigator.pop(context)}
                else
                  {_tabController?.animateTo(_tabController!.index - 1)}
              },
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Form(
                        key: _stepOneFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _nameTextController,
                              focusNode: _focusName,
                              decoration: const InputDecoration(
                                hintText: "Name",
                              ),
                            ),
                            RadioListTile(
                              title: const Text("Cat"),
                              value: petTypeCharacter.Cat,
                              groupValue: _character,
                              onChanged: (petTypeCharacter? value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            RadioListTile(
                              title: const Text("Dog"),
                              value: petTypeCharacter.Dog,
                              groupValue: _character,
                              onChanged: (petTypeCharacter? value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _weightTextController,
                              focusNode: _focusWeight,
                              decoration: const InputDecoration(
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
                                    decoration: const InputDecoration(
                                      hintText: "Age",
                                    ),
                                  ),
                                )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    child: ListTile(
                                  subtitle: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _sexTextController,
                                    focusNode: _focusSex,
                                    decoration: const InputDecoration(
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
                              decoration: const InputDecoration(
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
                                            child: Text('Next',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            onPressed: () {
                                              _tabController!.animateTo(1);
                                            }),
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
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                        key: _stepTwoFormKey,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                  "Is your pet friendly with any of the following?"),
                              ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: values.keys.map((String key) {
                                  // ignore: unnecessary_new
                                  return new CheckboxListTile(
                                    checkColor: Colors.white,
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                    contentPadding: EdgeInsets.only(left: 0),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    dense: true,
                                    title: Text(key),
                                    value: values[key],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        values[key] = value!;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const Text("Is your pet house trained?"),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("Yes"),
                                value: houseTrainedCharacter.yes,
                                groupValue: _trainedCharacter,
                                onChanged: (houseTrainedCharacter? value) {
                                  setState(() {
                                    _trainedCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("No"),
                                value: houseTrainedCharacter.no,
                                groupValue: _trainedCharacter,
                                onChanged: (houseTrainedCharacter? value) {
                                  setState(() {
                                    _trainedCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              const Text("Is your pet spayed/neutered?"),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("Yes"),
                                value: petSpayedCharacter.yes,
                                groupValue: _spayedCharacter,
                                onChanged: (petSpayedCharacter? value) {
                                  setState(() {
                                    _spayedCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("No"),
                                value: petSpayedCharacter.no,
                                groupValue: _spayedCharacter,
                                onChanged: (petSpayedCharacter? value) {
                                  setState(() {
                                    _spayedCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              const Text("Does your pet have a microchip?"),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("Yes"),
                                value: microChipCharacter.yes,
                                groupValue: _chipCharacter,
                                onChanged: (microChipCharacter? value) {
                                  setState(() {
                                    _chipCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              RadioListTile(
                                contentPadding: EdgeInsets.only(left: 0),
                                dense: true,
                                title: const Text("No"),
                                value: microChipCharacter.no,
                                groupValue: _chipCharacter,
                                onChanged: (microChipCharacter? value) {
                                  setState(() {
                                    _chipCharacter = value;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 1.0),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    child: Text('Next',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      _tabController!.animateTo(2);
                                    }),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Form(
                        key: _stepThreeFormKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              controller: _otherTextController,
                              focusNode: _focusOther,
                              decoration: const InputDecoration(
                                hintText: "Other information...",
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(top: 50, bottom: 50),
                                child: Text("Upload picture placeholder")),
                            const SizedBox(height: 32.0),
                            _isProcessing
                                ? const CircularProgressIndicator()
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              _isProcessing = true;
                                            });
                                            var docRef = await FirebaseFirestore
                                                .instance
                                                .collectionGroup('users')
                                                .where('uid',
                                                    isEqualTo: FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid
                                                        .toString())
                                                .get()
                                                .then((snapshot) {
                                              var data = snapshot.docs[0].data()
                                                  as Map<String, dynamic>;
                                              FirebaseFirestore.instance
                                                  .collection("building-codes")
                                                  .doc(data['buildingCode'])
                                                  .collection('users')
                                                  .doc(data['uid'])
                                                  .collection("pets")
                                                  .doc(_nameTextController.text)
                                                  .set(<String, String>{
                                                "name":
                                                    _nameTextController.text,
                                                "type":
                                                    describeEnum(_character!),
                                                "weight":
                                                    _weightTextController.text,
                                                "age": _ageTextController.text,
                                                "sex": _sexTextController.text,
                                                "breed":
                                                    _breedTextController.text,
                                                "friendlyWith":
                                                    values.toString(),
                                                "houseTrained": describeEnum(
                                                    _trainedCharacter!),
                                                "spayedOrNeutered":
                                                    describeEnum(
                                                        _spayedCharacter!),
                                                "microChipped": describeEnum(
                                                    _chipCharacter!),
                                                "other":
                                                    _otherTextController.text,
                                                "uid": FirebaseAuth
                                                    .instance.currentUser!.uid
                                              });
                                              setState(() {
                                                _isProcessing = false;
                                              });
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PetProfilePage()));
                                            });
                                          },
                                          child: const Text(
                                            'Submit',
                                            style:
                                                TextStyle(color: Colors.white),
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
    );
  }
}
