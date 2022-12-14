import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/screens/sign-up/sign_up_complete.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class PersonalInfo extends StatefulWidget {
  final String uid;
  const PersonalInfo({super.key, required String this.uid});

  @override
  State<StatefulWidget> createState() {
    return PersonalInfoState();
  }
}

var personalInfoArr = [
  "I'm a pet sitter",
  "I'm looking for a pet sitter",
  "Both"
];

enum userTypeCharacter { petSitter, lookingForPetSitter, both }

bool checkApartmentCode(String value) {
  bool valid = false;
  FirebaseFirestore.instance
      .collection('building-codes')
      .where('buildingID', isEqualTo: value)
      .get()
      .then((value) => {
            debugPrint('Data: ${value.size}'),
            if (value.size == 1) {valid = true} else {valid = false}
          });
  return valid;
}

class PersonalInfoState extends State<PersonalInfo> {
  @override
  PersonalInfo get widget => super.widget;
  // final _formKey = GlobalKey<FormState>();
  // var _character = "I'm a pet sitter";
  final apartmentCodeKey = GlobalKey();

  userTypeCharacter? _character = userTypeCharacter.petSitter;

  final _registerFormKey = GlobalKey<FormState>();

  final _codeTextController = TextEditingController();
  final _nameController = TextEditingController();

  final _focusCode = FocusNode();
  final _focusName = FocusNode();

  bool _isProcessing = false;
  bool apartmentCode = true;
  bool _uploadedPicture = false;

  File file = File("");
  var url;

  late FirebaseMessaging messaging;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100, bottom: 15),
                    child: Text(
                      "Welcome!",
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            'To connect with your neighbors, enter your resident access code below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.name,
                          controller: _nameController,
                          focusNode: _focusName,
                          decoration: InputDecoration(
                            hintText: "Name",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: _codeTextController,
                          focusNode: _focusCode,
                          decoration: InputDecoration(
                            helperText:
                                apartmentCode ? "" : "Apartment Code Invalid.",
                            helperStyle: TextStyle(color: Colors.red),
                            hintText: "Access Code",
                            focusedBorder: UnderlineInputBorder(
                              // borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                width: 2,
                                color: apartmentCode
                                    ? Theme.of(context).primaryColor
                                    : Colors.red,
                              ),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            'The access code is distributed by your landlord.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Column(children: <Widget>[
                          RadioListTile(
                            title: const Text("I'm a pet sitter"),
                            value: userTypeCharacter.petSitter,
                            groupValue: _character,
                            onChanged: (userTypeCharacter? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text("I'm looking for a pet sitter"),
                            value: userTypeCharacter.lookingForPetSitter,
                            groupValue: _character,
                            onChanged: (userTypeCharacter? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text("Both"),
                            value: userTypeCharacter.both,
                            groupValue: _character,
                            onChanged: (userTypeCharacter? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: _uploadedPicture == true
                                  ? Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: FileImage(file),
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                          type: FileType.image);
                                              debugPrint(result.toString());
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
                                              "Change Profile Picture",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))
                                      ],
                                    )
                                  : ElevatedButton(
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.image);
                                        debugPrint(result.toString());
                                        if (result != null) {
                                          file = File(result.files.single.path
                                              .toString());
                                          setState(() {
                                            _uploadedPicture = true;
                                          });
                                        } else {
                                          // User canceled the picker
                                        }
                                      },
                                      child: const Text(
                                        "Upload Profile Picture",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                        ]),
                        SizedBox(height: 16.0),
                        _isProcessing
                            ? CircularProgressIndicator()
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_registerFormKey.currentState!
                                            .validate()) {
                                          // _registerFormKey.currentState
                                          //     .setState(() {});
                                          setState(() {
                                            _isProcessing = true;
                                          });
                                          if (_uploadedPicture) {
                                            final storageRef =
                                                FirebaseStorage.instance.ref();
                                            final petPictureRef = storageRef.child(
                                                "${FirebaseAuth.instance.currentUser?.uid}/user.jpg");
                                            try {
                                              await petPictureRef.putFile(file);
                                              url = await petPictureRef
                                                  .getDownloadURL();
                                              _uploadedPicture = true;
                                            } catch (error) {
                                              debugPrint(error.toString());
                                            }
                                          }
                                          FirebaseFirestore.instance
                                              .collection('building-codes')
                                              .where(FieldPath.documentId,
                                                  isEqualTo:
                                                      _codeTextController.text)
                                              .get()
                                              .then((value) async {
                                            // debugPrint(
                                            //     'Data: ${value.size}'),
                                            messaging =
                                                FirebaseMessaging.instance;
                                            String deviceId = await messaging
                                                .getToken()
                                                .then(((value) {
                                              return value ?? "";
                                            }));

                                            if (value.size == 1) {
                                              var subtitle = "User";
                                              if (describeEnum(_character!) ==
                                                      "petSitter" ||
                                                  describeEnum(_character!) ==
                                                      "both")
                                                subtitle = "Pet Sitter";
                                              FirebaseFirestore.instance
                                                  .collection('building-codes')
                                                  .doc(_codeTextController.text)
                                                  .collection('users')
                                                  .doc(widget.uid)
                                                  .set(<String, String>{
                                                "name": _nameController.text,
                                                "lookingFor":
                                                    describeEnum(_character!),
                                                "uid": widget.uid,
                                                "buildingCode":
                                                    _codeTextController.text,
                                                "deviceId": deviceId,
                                                "subtitle": subtitle
                                              });
                                              if (_uploadedPicture) {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'building-codes')
                                                    .doc(_codeTextController
                                                        .text)
                                                    .collection('users')
                                                    .doc(widget.uid)
                                                    .update(<String, String>{
                                                  "pictureUrl": url
                                                });
                                              }
                                              ;

                                              //proceed to register page
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignUpCompletePage(),
                                                ),
                                              );
                                            } else {
                                              setState(() {
                                                apartmentCode = false;
                                                _isProcessing = false;
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
