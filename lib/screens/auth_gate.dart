import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/main.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:petwatch/utils/validate_user.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugPrint('in auth gate');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        var userId = snapshot.data?.uid ?? "";
        if (!snapshot.hasData) {
          return SignInScreen(providerConfigs: [
            EmailProviderConfiguration(),
            GoogleProviderConfiguration(
              clientId:
                  '92794491570-opp5bhqr4p5de4neekagh0tbcv6q8nh6.apps.googleusercontent.com',
            ),
            FacebookProviderConfiguration(
                clientId: "01e19fa0b974f239a23067952293b3be")
          ]);
        } else if (snapshot.hasData) {
          return StreamBuilder(
            stream: UserCheck.validateUserHasBuilding(uid: snapshot.data!.uid),
            builder: ((context, snapshot) {
              // debugPrint("${snapshot.data.toString()}");
              while (snapshot.data == null) {
                return CircularProgressIndicator(); // TODO: replace this with a screen that has a processing circle.
              }
              if (snapshot.data.toString() == "true") {
                return Routes();
              }
              return PersonalInfo(uid: userId);
            }),
          );
        }
        return PersonalInfo(uid: userId);
      },
    );
  }
}
