import 'package:flutter/material.dart';

class NotificationsCenter extends StatefulWidget {
  State<StatefulWidget> createState() {
    return NotificationsCenterState();
  }
}

class NotificationsCenterState extends State<NotificationsCenter> {
  Widget build(BuildContext context) {
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
              title: const Text(
                "Notifications",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text("Notifications Placeholder")),
                ),
              ],
            )));
  }
}
