import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

/*
  Needs to have: 
 */
class _SettingsPageState extends State<SettingsPage> {
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
        onTap: () {},
        child: Text("Test"),
      );
    }));
  }
}