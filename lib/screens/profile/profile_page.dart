import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
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
                child: Column(children: [
                  TextButton(onPressed: (() {}), child: const Text("Edit")),
                  Stack(
                    children: [
                      Card(
                          shape: CircleBorder(),
                          elevation: 2,
                          child: CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                  child: Image.asset(
                                    'assets/images/petwatch_logo.png',
                                  )))),
                      Positioned(
                          left: 100,
                          top: 100,
                          child: TextButton(
                              onPressed: (() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PetProfilePage()));
                              }),
                              child: Card(
                                  shape: CircleBorder(),
                                  elevation: 2,
                                  child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Color.fromARGB(255, 189, 189, 189),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.zero,
                                          child: Image.asset(
                                            'assets/images/petwatch_logo.png',
                                          ))))))
                    ],
                  ),
                  Text(
                    "${user.name["name"]}",
                    style: TextStyle(fontSize: 40),
                  ),
                  Text(
                    "Subtitle Placeholder",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("More information placeholder"),
                  SignOutButton()
                  // ElevatedButton(
                  //     onPressed: () => {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => PetProfilePage()))
                  //         },
                  //     child: Text("Pet"))
                ]),
              )));
    }));
  }
}
