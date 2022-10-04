import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<StatefulWidget> createState() {
    return PersonalInfoState();
  }
}

class PersonalInfoState extends State<PersonalInfo> {
  // final _formKey = GlobalKey<FormState>();

  final _registerFormKey = GlobalKey<FormState>();

  final _codeTextController = TextEditingController();
  final _focusCode = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          keyboardType: TextInputType.number,
                          controller: _codeTextController,
                          focusNode: _focusCode,
                          decoration: InputDecoration(
                            hintText: "Access Code",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'The access code is distributed by your landlord.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
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
                                        FirebaseFirestore.instance
                                            .collection('building-codes')
                                            .where('buildingID',
                                                isEqualTo:
                                                    _codeTextController.text)
                                            .get()
                                            .then((value) => {
                                                  debugPrint(
                                                      'Data: ${value.size}'),
                                                  if (value.size == 1)
                                                    {
                                                      //proceed to register page                                                Navigator.of(context)
                                                      // Navigator.of(context)
                                                      //     .pushReplacement(
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         RegisterPage(),
                                                      //   ),
                                                      // )
                                                    }
                                                  else
                                                    {
                                                      //error out
                                                    },
                                                });
                                      },
                                      child: Text(
                                        'Next',
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
