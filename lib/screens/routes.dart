import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/notifications/notificationCenter.dart';
import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/screens/home-page/home_page.dart';
import 'package:petwatch/screens/transactions/transactions_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';

class Routes extends StatefulWidget {
  final int initialIndex;
  const Routes(this.initialIndex);
  // final BuildContext context;
  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  int _selectedIndex = 0;

  static final List<String> _widgetOptions = <String>[
    'HomePage',
    "Receipts",
    'ProfilePage',
  ];
  Widget gotoPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return const TransactionsPage();
      case 2:
        return ProfilePage();
      default:
        return HomePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    requestPermission();
    CheckDeviceId();
    initInfo();
    _selectedIndex = widget.initialIndex;
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('provisional permission granted');
    } else {
      print('permission not accepted');
    }
  }

  void CheckDeviceId() async {
    messaging = FirebaseMessaging.instance;
    String deviceId = await messaging.getToken().then(((value) {
      return value ?? "";
    }));
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collectionGroup("users")
        .where("uid", isEqualTo: userId)
        .get()
        .then((value) => {
              value.docs.forEach((element) async {
                if (element.data().containsKey("deviceId") &&
                    element["deviceId"] == deviceId) {
                } else {
                  await FirebaseFirestore.instance
                      .doc(element.reference.path)
                      .update({"deviceId": deviceId});
                }
              })
            });
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        try {
          if (details.payload != null && details.payload!.isNotEmpty) {
            print("Payload Not Null: ${details.payload?.toString()}");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationsCenter()));
          } else {
            print("Payload Null: ${details.payload?.toString()}");
          }
        } catch (e) {
          print('Error: ${e.toString()}');
        }
        return;
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('........onMessage........');
      print(
          'onMessage: ${message.notification?.title}/${message.notification?.body}');
      print('DATA: ${message.data.toString()}');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'petwatch',
        'petwatch',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails());
      await FlutterLocalNotificationsPlugin().show(
          0,
          message.notification?.title,
          message.notification?.body,
          platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  @override
  Widget build(BuildContext context) {
    // context = widget.context;
    return ChangeNotifierProvider(
      create: ((context) => UserModel()),
      builder: (context, child) {
        return GestureDetector(
            onTap: () {},
            child: Scaffold(
              body: Center(
                child: gotoPage(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavBar(
                onItemTapped: _onItemTapped,
                selectedIndex: _selectedIndex,
              ),
            ));
      },
    );
  }
}
