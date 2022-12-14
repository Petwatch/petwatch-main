import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/screens/post_page.dart';
import 'package:petwatch/screens/profile/dashboard_page.dart';
import 'package:petwatch/screens/profile/edit_profile_page.dart';
import 'package:petwatch/screens/settings-page/settings_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
import 'package:petwatch/services/stripe-backend-service.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import '../../components/CustomRatingDialog.dart';

class ProfilePage extends StatefulWidget {
  // final BuildContext context;
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TabController _tabController;
  int _tabIndex = 0;

  _launchStripeConnect(value) async {
    CreateAccountResponse response =
        await StripeBackendService.createSellerAccount();
    debugPrint("${response.id}");
    debugPrint("${value.uid['uid']}");
    var res = await FirebaseFirestore.instance
        .doc(
            "/building-codes/${value.buildingCode['buildingCode']}/users/${value.uid['uid']}/")
        .update({"stripeExpressId": response.id});
    final Uri _url = Uri.parse(response.url);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(
                  url: _url,
                  title: "Stripe Setup",
                )));
    setState(() {
      isLoading = false;
    });
  }

  _launchStripeConnectDashboard(stripeId) async {
    var res = await GetConnectedDashboard.getDashboard(stripeId);
    debugPrint("$res");
    final Uri _url = Uri.parse(res["url"]);
    // if (!await launchUrl(_url, mode: LaunchMode.platformDefault)) {
    //   throw 'Could not launch $_url';
    // }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(
                  url: _url,
                  title: "Seller Dashboard",
                )));

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, user, child) {
      debugPrint("${user}");
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
              appBar: TopNavBar(),
              body: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                child: Card(
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
                                                                EditProfilePage(
                                                                    user)));
                                                  },
                                                  child: Text("Edit\nProfile",
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ),
                                          (PopupMenuItem(
                                            padding: EdgeInsets.zero,
                                            child: Center(
                                              child: TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    // setState(() {
                                                    //   isLoading = true;
                                                    // });
                                                    // await _launchStripeConnect(
                                                    //     user);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SettingsPage()));
                                                  },
                                                  child: const Text("Settings",
                                                      textAlign:
                                                          TextAlign.center)),
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
                                                      await _launchStripeConnect(
                                                          user);
                                                    },
                                                    child: const Text(
                                                        "Become\na pet sitter",
                                                        textAlign:
                                                            TextAlign.center)),
                                              ),
                                            ))
                                          else
                                            (PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                child: Center(
                                                  child: TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        // await _launchStripeConnect(
                                                        //     user);
                                                        await _launchStripeConnectDashboard(
                                                            user.stripeExpressId);
                                                      },
                                                      child: const Text(
                                                          "View Seller Dashboard",
                                                          textAlign: TextAlign
                                                              .center)),
                                                ))),
                                          PopupMenuItem(
                                            padding: EdgeInsets.zero,
                                            child: Center(
                                              child: TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await FirebaseAuth.instance
                                                      .signOut();
                                                },
                                                child: Text("Sign Out"),
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
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundImage: user.hasPicture
                                                  ? NetworkImage(user
                                                      .pictureUrl['pictureUrl'])
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
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      backgroundImage: user
                                                              .hasPet
                                                          ? user.petInfo[0][
                                                                      'pictureUrl'] !=
                                                                  null
                                                              ? NetworkImage(user
                                                                  .petInfo[0][
                                                                      'pictureUrl']
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
                                        user.subtitle != ""
                                            ? user.subtitle
                                            : "User",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
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
                                            : "Edit your profile to fill out your bio",
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: SegmentedTabControl(
                                  controller: _tabController,
                                  radius: const Radius.circular(40),
                                  backgroundColor: Colors.grey.shade300,
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary,
                                  tabTextColor: Colors.black45,
                                  selectedTabTextColor: Colors.white,
                                  squeezeIntensity: 2,
                                  height: 45,
                                  tabPadding:
                                      const EdgeInsets.symmetric(horizontal: 8),
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
                              Center(
                                child: [
                                  RatingWidget(
                                    user: user,
                                    context: context,
                                  ),
                                  PostWidget(user: user),
                                ][_tabIndex],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )));
    }));
  }
}

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    Key? key,
    required this.user,
    required this.context,
  }) : super(key: key);

  final UserModel user;
  final BuildContext context;

  Widget singleReview(context, review) {
    String pictureUrl = review['reviewerPictureUrl'].toString();
    String name = review['reviewerName'].toString();
    String stars = review['stars'].toString();
    String message = review['comment'].toString();

    return FractionallySizedBox(
      widthFactor: .95,
      child: CustomRatingDialog(
        starColor: Colors.amber,
        title: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: pictureUrl != ""
                  ? NetworkImage(pictureUrl)
                  : AssetImage('assets/images/petwatch_logo.png')
                      as ImageProvider,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          Text(name)
        ],
        starSize: 20,
        submitButtonText: 'Submit',
        onCancelled: () => print('cancelled'),
        onSubmitted: (response) {
          print('rating: ${response.rating}, '
              'comment: ${response.comment}');
        },
        message: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        enableComment: false,
        showCloseButton: false,
        showSubmitButton: false,
        disableEdit: true,
        initialRating: double.parse(stars),
        isAlert: false,
      ),
    );
  }

  List<Widget> getUserReviews(context) {
    List<Widget> reviewList = [];
    if (user.reviews != null) {
      for (var review in user.reviews) {
        reviewList.insert(0, singleReview(context, review));
      }
    }
    return reviewList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> reviewList = getUserReviews(context);
    return Column(
      children: [
        ...reviewList,
      ],
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserModel user;

  List<Widget> getUserPosts(context) {
    List<Widget> postList = [];
    for (var post in user.posts) {
      if (post['postedBy']['name'] == user.name['name'])
        postList.add(singlePost(context, post));
    }

    return postList;
  }

  Widget singlePost(BuildContext context, Map<String, dynamic> post) {
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);

    var description = post['desc'] as String;
    var pictureUrl = post['postedBy'].containsKey("pictureUrl")
        ? post['postedBy']['pictureUrl'] as String
        : "";

    return GestureDetector(
        onTap: (() {
          // debugPrint("clicked");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PostPage(post: post)));
        }),
        child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FractionallySizedBox(
              widthFactor: .95,
              child: Card(
                  elevation: 2,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, top: 8.0),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage: pictureUrl != ""
                                    ? NetworkImage(pictureUrl)
                                    : AssetImage(
                                            'assets/images/petwatch_logo.png')
                                        as ImageProvider,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(post['postedBy']['name'] + " | "),
                            ),
                            if (post['type'] == 'Request')
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(infoPostDateFormat.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              post['dateRange']['startTime'])) +
                                      " - " +
                                      infoPostDateFormat.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              post['dateRange']['endTime']))))
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(formattedDate),
                              ),
                            if (post['type'] != "Info" && post['price'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: (Text(" | \$${post["price"]}")),
                              )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                description,
                                softWrap: false,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 65,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: (() {
                                            switch (post["type"]) {
                                              case "Info":
                                                return Colors.blue
                                                    .withOpacity(0.5);
                                              case "Request":
                                                return Colors.green
                                                    .withOpacity(0.5);
                                              default:
                                                return Colors.yellow
                                                    .withOpacity(0.5);
                                            }
                                          })(),
                                          width: 3),
                                      borderRadius: BorderRadius.circular(5),
                                      color: (() {
                                        switch (post["type"]) {
                                          case "Info":
                                            return Colors.blue.withOpacity(0.8);
                                          case "Request":
                                            return Colors.green
                                                .withOpacity(0.8);
                                          default:
                                            return Colors.yellow
                                                .withOpacity(0.8);
                                        }
                                      })(),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          post['type'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    )),
                              ),
                              const Spacer(),
                              Text(post['comments'].length > 2 ||
                                      post['comments'].length == 0
                                  ? "${post['comments'].length} comments"
                                  : "${post['comments'].length} comment"),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              )

                              //Make text color white
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            )));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> postList = getUserPosts(context);
    return Column(
      children: [...postList],
    );
  }
}
