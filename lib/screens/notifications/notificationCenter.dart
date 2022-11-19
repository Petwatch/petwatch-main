import 'package:flutter/material.dart';

class NotificationsCenter extends StatefulWidget {
  State<StatefulWidget> createState() {
    return NotificationsCenterState();
  }
}

class NotificationsCenterState extends State<NotificationsCenter> {
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {}, child: Scaffold(body: Text("Hello")));
  }
}
