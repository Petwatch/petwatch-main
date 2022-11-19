import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
import 'package:petwatch/services/stripe-backend-service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  // final BuildContext context;
  EditProfilePage(this.user);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isProcessing = false;
  bool _uploadedPicture = false;

  File file = File("");
  var url;

  var _nameTextController = TextEditingController();
  var _subTitleTextController = TextEditingController();
  var _bioTextController = TextEditingController();
  final _focusName = FocusNode();
  final _focusSubTitle = FocusNode();
  final _focusBio = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameTextController =
        new TextEditingController(text: widget.user.name["name"]);
    _subTitleTextController =
        new TextEditingController(text: widget.user.subTitle);
    _bioTextController = new TextEditingController(text: widget.user.bio);
  }

  Widget build(BuildContext context) {
    // context = widget.context;
    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
          onTap: () {
            _focusName.unfocus();
            _focusSubTitle.unfocus();
            _focusBio.unfocus();
          },
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  color: Colors.white,
                  iconSize: 35,
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () => {Navigator.pop(context)},
                ),
                title: Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: user.hasPicture
                                  ? _uploadedPicture == false
                                      ? Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 75,
                                              backgroundImage: NetworkImage(user
                                                  .pictureUrl['pictureUrl']),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              type: FileType
                                                                  .image);
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
                                      : Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 75,
                                              backgroundImage: FileImage(file),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              type: FileType
                                                                  .image);
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
                                  : _uploadedPicture == false
                                      ? Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 75,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundImage: AssetImage(
                                                      'assets/images/petwatch_logo_white.png')
                                                  as ImageProvider,
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              type: FileType
                                                                  .image);
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
                                                  "Upload Profile Picture",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 75,
                                              backgroundImage: FileImage(file),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              type: FileType
                                                                  .image);
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
                                        )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameTextController,
                          focusNode: _focusName,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: "Name",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _subTitleTextController,
                          focusNode: _focusSubTitle,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: "Subtitle",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          minLines: 4,
                          maxLines: 8,
                          keyboardType: TextInputType.multiline,
                          controller: _bioTextController,
                          focusNode: _focusBio,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: "Bio",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: (() async {
                            setState(() {
                              _isProcessing = true;
                            });
                            print("picture: ${_uploadedPicture}");
                            final storageRef = FirebaseStorage.instance.ref();
                            var docRef = await FirebaseFirestore.instance
                                .collectionGroup('users')
                                .where('uid',
                                    isEqualTo: FirebaseAuth
                                        .instance.currentUser!.uid
                                        .toString())
                                .get()
                                .then((snapshot) async {
                              var data = snapshot.docs[0].data()
                                  as Map<String, dynamic>;
                              var docRef = FirebaseFirestore.instance
                                  .collection("building-codes")
                                  .doc(data['buildingCode'])
                                  .collection('users')
                                  .doc(data['uid'])
                                  .update({
                                "name": _nameTextController.text,
                                "subTitle": _subTitleTextController.text,
                                "bio": _bioTextController.text,
                              });
                              final profilePictureRef = storageRef.child(
                                  "${FirebaseAuth.instance.currentUser?.uid}/user.jpg");
                              try {
                                if (_uploadedPicture == true) {
                                  await profilePictureRef.putFile(file);
                                  url =
                                      await profilePictureRef.getDownloadURL();
                                  _uploadedPicture = true;
                                }
                              } catch (error) {
                                debugPrint(error.toString());
                              }
                              if (_uploadedPicture == true) {
                                FirebaseFirestore.instance
                                    .collection("building-codes")
                                    .doc(data['buildingCode'])
                                    .collection('users')
                                    .doc(data['uid'])
                                    .update({"pictureUrl": url});
                              }
                              setState(() {
                                _isProcessing = false;
                              });
                              await user.getUserData();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Routes(2)));
                            });
                          }),
                          child: Text(
                            "Confirm Changes",
                            style: TextStyle(color: Colors.white),
                          ))
                    ]),
                  ),
                ),
              )));
    }));
  }
}
