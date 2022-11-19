import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/screens/profile/edit_profile_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
import 'package:petwatch/services/stripe-backend-service.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';

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
  // debugPrint("${response.url}");
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
              body: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
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
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfilePage(user)));
                                          },
                                          child: Text("Edit\nProfile",
                                              textAlign: TextAlign.center)),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () async {
                                            await _launchStripeConnect();
                                          },
                                          child: Text("Become\na pet sitter",
                                              textAlign: TextAlign.center)),
                                    ),
                                  ),
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
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "${user.name["name"]}",
                                style: TextStyle(fontSize: 40),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                user.subTitle != ""
                                    ? user.subTitle
                                    : "Subtitle Placeholder",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                  bottom: 15),
                              child: Text(
                                user.bio != ""
                                    ? user.bio
                                    : "More information placeholder",
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ]),
                        ),
                        DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: SegmentedTabControl(
                                    radius: const Radius.circular(40),
                                    backgroundColor: Colors.grey.shade300,
                                    indicatorColor:
                                        Theme.of(context).colorScheme.primary,
                                    tabTextColor: Colors.black45,
                                    selectedTabTextColor: Colors.white,
                                    squeezeIntensity: 2,
                                    height: 45,
                                    tabPadding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    textStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    tabs: const [
                                      SegmentTab(
                                        label: 'Reviews',
                                      ),
                                      SegmentTab(
                                        label: 'Posts',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 200,
                                  child: TabBarView(
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      SampleWidget(
                                        label: 'Reviews',
                                        color: Colors.white,
                                      ),
                                      SampleWidget(
                                        label: 'Posts',
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              )));
    }));
  }
}

class SampleWidget extends StatelessWidget {
  const SampleWidget({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        child: Text(
          label,
          textAlign: TextAlign.center,
        ));
  }
}
