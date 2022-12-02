import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/CustomRatingDialog.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:petwatch/screens/pet-profile/view_pet_profile_page.dart';
import 'package:petwatch/screens/post_page.dart';
import 'package:petwatch/screens/profile/edit_profile_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';

class ViewProfilePage extends StatefulWidget {
  Map<String, dynamic> UserReference;
  // final BuildContext context;
  ViewProfilePage(this.UserReference);

  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController _tabController;
  int _tabIndex = 0;
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> petData = [];
  bool hasPicture = false;
  bool hasPet = false;

  Future getUserData() async {
    await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid', isEqualTo: widget.UserReference['UID'])
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data().toString().contains("pictureUrl")) {
          setState(() {
            hasPicture = true;
          });
        }
        userData.addAll(element.data());
      }
      // debugPrint(widget.UserReference.toString());
      // debugPrint(userData.toString());
    });
    await FirebaseFirestore.instance
        .collectionGroup('pets')
        .where('uid', isEqualTo: widget.UserReference['UID'])
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        setState(() {
          hasPet = true;
        });
      }
      for (var element in value.docs) {
        petData.add(element.data());
      }
    });
    // debugPrint(petData.toString());
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
    getUserData();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        debugPrint("Hello?");
        isLoading = false;
      });
    });
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
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  color: Colors.white,
                  iconSize: 35,
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () => {Navigator.pop(context)},
                ),
                title: Text(
                  "View Profile",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
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
                                              backgroundImage: hasPicture
                                                  ? NetworkImage(
                                                      userData['pictureUrl']
                                                          .toString())
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
                                                              ViewPetProfilePage(
                                                                  petData,
                                                                  hasPet)));
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
                                                      backgroundImage: hasPet
                                                          ? petData[0]['pictureUrl']
                                                                      .toString() !=
                                                                  null
                                                              ? NetworkImage(petData[
                                                                          0][
                                                                      'pictureUrl']
                                                                  .toString()
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
                                        "${userData["name"].toString()}",
                                        style: TextStyle(fontSize: 40),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        userData['subtitle'].toString() != ""
                                            ? userData['subtitle'].toString()
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
                                        userData['bio'].toString() != ""
                                            ? userData['bio'].toString()
                                            : "No bio",
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
                                    user: userData,
                                    context: context,
                                  ),
                                  PostWidget(user: user, userData: userData),
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

  final Map<String, dynamic> user;
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
    if (user['reviews'] != null) {
      for (var review in user['reviews']) {
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
    required this.userData,
  }) : super(key: key);

  final UserModel user;
  final Map<String, dynamic> userData;

  List<Widget> getUserPosts(context) {
    List<Widget> postList = [];
    for (var post in user.posts) {
      if (post['postedBy']['name'] == userData['name'].toString())
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
                              Text("${post['comments'].length} comments"),
                              const Icon(Icons.comment, color: Colors.black),
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
