import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';

class CreatePost extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _CreatePostState();
  }
}

class _CreatePostState extends State<CreatePost> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Info", child: Text("Info")),
      const DropdownMenuItem(value: "Request", child: Text("Request")),
      const DropdownMenuItem(value: "Available", child: Text("Available")),
    ];
    return menuItems;
  }

//   Widget infoPostForm(BuildContext context){
// return
//   }

  String selectedPostValue = "Request";
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() {}),
        child: Scaffold(
          appBar: MessageNavBar(),
          body: Center(
              child: DropdownButton(
            value: selectedPostValue,
            items: dropdownItems,
            onChanged: (String? value) {
              debugPrint("Value has changed to $value");
              selectedPostValue = value!;
            },
          )),
        ));
  }
}
