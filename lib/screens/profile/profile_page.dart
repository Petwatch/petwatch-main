import 'package:cloud_firestore/cloud_firestore.dart';
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

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  _launchStripeConnect(value) async {
    // const url = Uri.encodeFull("https://google.com");
    CreateAccountResponse response =
        await StripeBackendService.createSellerAccount();
    debugPrint("${response.id}");
    debugPrint("${value.uid['uid']}");
    var res = await FirebaseFirestore.instance
        .doc(
            "/building-codes/${value.buildingCode['buildingCode']}/users/${value.uid['uid']}/")
        .update({"stripeExpressId": response.id});
    // debugPrint("${res}");
    final Uri _url = Uri.parse(response.url);
    // final Uri _tetURL =
    //     Uri.https('petwatch-stripe-api.onrender.com', '/api/hello');
    // var response = await http.get(_tetURL);
    // debugPrint('${response.body}');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    // context = widget.context;
    return Consumer<UserModel>(builder: ((context, user, child) {
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
              appBar: TopNavBar(),
              body: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          elevation: 10,
                          child: Column(children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: PopupMenuButton(
                                offset: Offset.fromDirection(270, 12),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                position: PopupMenuPosition.under,
                                icon: Icon(Icons.menu),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  PopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () {},
                                          child: Text("Edit\nProfile",
                                              textAlign: TextAlign.center)),
                                    ),
                                  ),
                                  (PopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            // await _launchStripeConnect(user);
                                          },
                                          child: const Text("Payment Settings",
                                              textAlign: TextAlign.center)),
                                    ),
                                  )),
                                  if (user.stripeExpressId == "")
                                    (PopupMenuItem(
                                      padding: EdgeInsets.zero,
                                      child: Center(
                                        child: TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await _launchStripeConnect(user);
                                            },
                                            child: const Text(
                                                "Become\na pet sitter",
                                                textAlign: TextAlign.center)),
                                      ),
                                    )),
                                  PopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: SignOutButton(
                                        variant: ButtonVariant.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Card(
                                    shape: CircleBorder(),
                                    elevation: 2,
                                    child: CircleAvatar(
                                      radius: 75,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      backgroundImage: user.hasPicture
                                          ? NetworkImage(
                                              user.pictureUrl['pictureUrl'])
                                          : AssetImage(
                                                  'assets/images/petwatch_logo_white.png')
                                              as ImageProvider,
                                    )),
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
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundImage: user.hasPet
                                                  ? user.petInfo[0]
                                                              ['pictureUrl'] !=
                                                          null
                                                      ? NetworkImage(user
                                                          .petInfo[0]
                                                              ['pictureUrl']
                                                          .toString())
                                                      : AssetImage(
                                                              'assets/images/petwatch_logo_white.png')
                                                          as ImageProvider
                                                  : AssetImage(
                                                          'assets/images/petwatch_logo_white.png')
                                                      as ImageProvider),
                                        )))
                              ],
                            ),
                            Text(
                              "${user.name["name"]}",
                              style: TextStyle(fontSize: 40),
                            ),
                            Text(
                              "Subtitle Placeholder",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text("More information placeholder"),
                            // SignOutButton(),
                            // TextButton(
                            //     onPressed: () async {
                            //       await _launchStripeConnect();
                            //     },
                            //     child: Text("Become a pet sitter"))
                            // ElevatedButton(
                            //     onPressed: () => {
                            //           Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                   builder: (context) => PetProfilePage()))
                            //         },
                            //     child: Text("Pet"))
                          ]),
                        ),
                      ),
              )));
    }));
  }
}
