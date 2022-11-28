import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class PetEditInfo extends StatefulWidget {
  final UserModel userModel;
  final int index;
  const PetEditInfo(this.userModel, this.index);
  @override
  _PetEditInfoState createState() => _PetEditInfoState();
}
// PetSetupInfo() or PetSetupInfo(value)

//PetSetupInfo(Object? valuue)
enum petTypeCharacter { Cat, Dog }

enum houseTrainedCharacter { yes, no }

enum petSpayedCharacter { yes, no }

enum microChipCharacter { yes, no }

class _PetEditInfoState extends State<PetEditInfo>
    with SingleTickerProviderStateMixin {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
  final _stepThreeFormKey = GlobalKey<FormState>();

  var _nameTextController = TextEditingController();
  var _weightTextController = TextEditingController();
  var _ageTextController = TextEditingController();
  var _sexTextController = TextEditingController();
  var _breedTextController = TextEditingController();
  var _otherTextController = TextEditingController();
  final _focusName = FocusNode();
  final _focusWeight = FocusNode();
  final _focusAge = FocusNode();
  final _focusSex = FocusNode();
  final _focusBreed = FocusNode();
  final _focusOther = FocusNode();

  bool _isProcessing = false;
  bool _uploadedPicture = false;

  File file = File("");
  var url;

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

    _nameTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['name']);
    _weightTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['weight']);
    _ageTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['age']);
    _sexTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['sex']);
    _breedTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['breed']);
    _otherTextController = new TextEditingController(
        text: widget.userModel.petInfo[widget.index]['other']);
    values = {
      'Children': widget.userModel.petInfo[widget.index]['friendlyWith']
          ['Children'],
      'Dogs': widget.userModel.petInfo[widget.index]['friendlyWith']['Dogs'],
      'Cats': widget.userModel.petInfo[widget.index]['friendlyWith']['Cats'],
    };
    widget.userModel.petInfo[widget.index]['type'] == "Cat"
        ? _character = petTypeCharacter.Cat
        : _character = petTypeCharacter.Dog;
    widget.userModel.petInfo[widget.index]['houseTrained'] == "yes"
        ? _trainedCharacter = houseTrainedCharacter.yes
        : _trainedCharacter = houseTrainedCharacter.no;
    widget.userModel.petInfo[widget.index]['spayedOrNeutered'] == "yes"
        ? _spayedCharacter = petSpayedCharacter.yes
        : _spayedCharacter = petSpayedCharacter.no;
    widget.userModel.petInfo[widget.index]['microChipped'] == "yes"
        ? _chipCharacter = microChipCharacter.yes
        : _chipCharacter = microChipCharacter.no;
  }

  void _handleTabSelection() {
    setState(() {});
  }

  Future<void> _uploadPetPicture() async {
    final storageRef = FirebaseStorage.instance.ref();
    final petPictureRef = storageRef
        .child("${FirebaseAuth.instance.currentUser?.uid}/petpicture.jpg");

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    debugPrint(result.toString());
    if (result != null) {
      file = File(result.files.single.path.toString());
      try {
        await petPictureRef.putFile(file);
        _uploadedPicture = true;
      } catch (error) {
        debugPrint(error.toString());
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
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
              title: const Text("Edit Pet Profile"),
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
                                    isDense: true,
                                    labelText: "Name",
                                    border: OutlineInputBorder()),
                              ),
                              RadioListTile(
                                dense: true,
                                title: const Text("Cat"),
                                value: petTypeCharacter.Cat,
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
                                dense: true,
                                title: const Text("Dog"),
                                value: petTypeCharacter.Dog,
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
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _weightTextController,
                                  focusNode: _focusWeight,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: "Weight (lbs)",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: ListTile(
                                      subtitle: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _ageTextController,
                                        focusNode: _focusAge,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: "Age",
                                          border: OutlineInputBorder(),
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
                                          isDense: true,
                                          labelText: "Sex",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _breedTextController,
                                  focusNode: _focusBreed,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: "Breed(s)",
                                    border: OutlineInputBorder(),
                                  ),
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
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 0),
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
                                          style:
                                              TextStyle(color: Colors.white)),
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
                                  isDense: true,
                                  labelText: "Other information",
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: value.petInfo.isNotEmpty
                                      ? value.petInfo[widget.index]
                                                  ['pictureUrl'] !=
                                              null
                                          ? _uploadedPicture == false
                                              ? Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 75,
                                                      backgroundImage:
                                                          NetworkImage(value
                                                                      .petInfo[
                                                                  widget.index]
                                                              ['pictureUrl']),
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          FilePickerResult?
                                                              result =
                                                              await FilePicker
                                                                  .platform
                                                                  .pickFiles(
                                                                      type: FileType
                                                                          .image);
                                                          debugPrint(result
                                                              .toString());
                                                          if (result != null) {
                                                            file = File(result
                                                                .files
                                                                .single
                                                                .path
                                                                .toString());
                                                            setState(() {
                                                              _uploadedPicture =
                                                                  true;
                                                            });
                                                          } else {
                                                            // User canceled the picker
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Change Pet Picture",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 75,
                                                      backgroundImage:
                                                          FileImage(file),
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          FilePickerResult?
                                                              result =
                                                              await FilePicker
                                                                  .platform
                                                                  .pickFiles(
                                                                      type: FileType
                                                                          .image);
                                                          debugPrint(result
                                                              .toString());
                                                          if (result != null) {
                                                            file = File(result
                                                                .files
                                                                .single
                                                                .path
                                                                .toString());
                                                            setState(() {
                                                              _uploadedPicture =
                                                                  true;
                                                            });
                                                          } else {
                                                            // User canceled the picker
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Change Pet Picture",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                  ],
                                                )
                                          : _uploadedPicture == false
                                              ? ElevatedButton(
                                                  onPressed: () async {
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                                type: FileType
                                                                    .image);
                                                    debugPrint(
                                                        result.toString());
                                                    if (result != null) {
                                                      file = File(result
                                                          .files.single.path
                                                          .toString());
                                                      setState(() {
                                                        _uploadedPicture = true;
                                                      });
                                                    } else {
                                                      // User canceled the picker
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Upload Pet Picture",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                              : Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 75,
                                                      backgroundImage:
                                                          FileImage(file),
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          FilePickerResult?
                                                              result =
                                                              await FilePicker
                                                                  .platform
                                                                  .pickFiles(
                                                                      type: FileType
                                                                          .image);
                                                          debugPrint(result
                                                              .toString());
                                                          if (result != null) {
                                                            file = File(result
                                                                .files
                                                                .single
                                                                .path
                                                                .toString());
                                                            setState(() {
                                                              _uploadedPicture =
                                                                  true;
                                                            });
                                                          } else {
                                                            // User canceled the picker
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Change Pet Picture",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                  ],
                                                )
                                      : null),
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
                                              final storageRef = FirebaseStorage
                                                  .instance
                                                  .ref();
                                              var docRef =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collectionGroup('users')
                                                      .where('uid',
                                                          isEqualTo:
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid
                                                                  .toString())
                                                      .get()
                                                      .then((snapshot) async {
                                                var data =
                                                    snapshot.docs[0].data()
                                                        as Map<String, dynamic>;
                                                var docRef =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            "building-codes")
                                                        .doc(data[
                                                            'buildingCode'])
                                                        .collection('users')
                                                        .doc(data['uid'])
                                                        .collection("pets")
                                                        .doc(value.petInfo[
                                                                widget.index]
                                                            ['petId']);
                                                docRef.update({
                                                  "name":
                                                      _nameTextController.text,
                                                  "type":
                                                      describeEnum(_character!),
                                                  "weight":
                                                      _weightTextController
                                                          .text,
                                                  "age":
                                                      _ageTextController.text,
                                                  "sex":
                                                      _sexTextController.text,
                                                  "breed":
                                                      _breedTextController.text,
                                                  "friendlyWith": {...values},
                                                  "houseTrained": describeEnum(
                                                      _trainedCharacter!),
                                                  "spayedOrNeutered":
                                                      describeEnum(
                                                          _spayedCharacter!),
                                                  "microChipped": describeEnum(
                                                      _chipCharacter!),
                                                  "other":
                                                      _otherTextController.text,
                                                  "uid": FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                });
                                                final petPictureRef =
                                                    storageRef.child(
                                                        "${FirebaseAuth.instance.currentUser?.uid}/${value.petInfo[widget.index]['petId']}.jpg");
                                                try {
                                                  if (_uploadedPicture ==
                                                      true) {
                                                    await petPictureRef
                                                        .putFile(file);
                                                    url = await petPictureRef
                                                        .getDownloadURL();
                                                    _uploadedPicture = true;
                                                  }
                                                } catch (error) {
                                                  debugPrint(error.toString());
                                                }
                                                if (_uploadedPicture == true) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          "building-codes")
                                                      .doc(data['buildingCode'])
                                                      .collection('users')
                                                      .doc(data['uid'])
                                                      .collection("pets")
                                                      .doc(value.petInfo[widget
                                                          .index]['petId'])
                                                      .update(
                                                          {"pictureUrl": url});
                                                }
                                                setState(() {
                                                  _isProcessing = false;
                                                });
                                                await value.getUserData();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PetProfilePage()));
                                              });
                                            },
                                            child: const Text(
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
      );
    });
  }
}
