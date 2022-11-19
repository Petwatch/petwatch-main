import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class PaymentSettings extends StatefulWidget {
  PaymentSettings();

  @override
  _PaymentSettingsState createState() => _PaymentSettingsState();
}

/*
  Needs to have: 
 */
class _PaymentSettingsState extends State<PaymentSettings> {
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
        onTap: () {},
        child: Text("Test"),
      );
    }));
  }
}
