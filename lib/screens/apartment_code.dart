import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:petwatch/screens/register_page.dart';
import 'package:petwatch/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class ApartmentCodePage extends StatefulWidget {
  @override
  _ApartmentCodePageState createState() => _ApartmentCodePageState();
}

class _ApartmentCodePageState extends State<ApartmentCodePage> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _registerFormKey = GlobalKey<FormState>();

  final _codeTextController = TextEditingController();
  final _focusCode = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusCode.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Register'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
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
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
                                                        _codeTextController
                                                            .text)
                                                .get()
                                                .then((value) => {
                                                      debugPrint(
                                                          'Data: ${value.size}'),
                                                      if (value.size == 1)
                                                        {
                                                          //proceed to register page                                                Navigator.of(context)
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RegisterPage(),
                                                            ),
                                                          )
                                                        }
                                                      else
                                                        {
                                                          //error out
                                                        },
                                                    });
                                          },
                                          child: Text(
                                            'Next',
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
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isProcessing = true;
                          });

                          //proceed to register page                                                Navigator.of(context)
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text('Already have an account?',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      )))
            ],
          )),
    );
  }
}
