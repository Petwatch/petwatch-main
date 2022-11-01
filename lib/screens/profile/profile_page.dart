import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
import 'package:petwatch/services/stripe-backend-service.dart';

class ProfilePage extends StatefulWidget {
  // final BuildContext context;
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

_launchStripeConnect() async {
  // const url = Uri.encodeFull("https://google.com");
  CreateAccountResponse response =
      await StripeBackendService.createSellerAccount();
  debugPrint("${response.url}");
  final Uri _url = Uri.parse(response.url);
  // final Uri _tetURL =
  //     Uri.https('petwatch-stripe-api.onrender.com', '/api/hello');
  // var response = await http.get(_tetURL);
  // debugPrint('${response.body}');
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
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
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                          shape: CircleBorder(),
                          elevation: 2,
                          child: CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 150,
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
                                  backgroundImage: user.hasPet
                                      ? NetworkImage(user.petInfo[0]
                                              ['pictureUrl']
                                          .toString())
                                      : null,
                                  child: !user.hasPet
                                      ? Image.asset(
                                          'assets/images/petwatch_logo_white.png')
                                      : null,
                                ),
                              )))
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
                  SignOutButton(),
                  ElevatedButton(
                      onPressed: () async {
                        await _launchStripeConnect();
                      },
                      child: Text("Become a pet sitter"))
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
