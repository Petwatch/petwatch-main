import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  // final BuildContext context;
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget build(BuildContext context) {
    // context = widget.context;
    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
              appBar: TopNavBar(),
              body: Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${user.name["Name"]}"),
                    ElevatedButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PetProfilePage()))
                            },
                        child: Text("Pet"))
                  ],
                ),
              ))));
    }));
  }
}
