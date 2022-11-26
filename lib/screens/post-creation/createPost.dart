import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/home-page/home_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _CreatePostState();
  }
}

class _CreatePostState extends State<CreatePost> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Info", child: Text("info")),
      const DropdownMenuItem(value: "Request", child: Text("request")),
      const DropdownMenuItem(value: "Available", child: Text("available")),
    ];
    return menuItems;
  }

  final _formKey = GlobalKey<FormState>();

  final _PostTitle = TextEditingController();
  final _PostContents = TextEditingController();
  final _PriceForRequest = TextEditingController();

  final _PostTitleNode = FocusNode();
  final _PostContentsNode = FocusNode();
  final _PriceForRequestNode = FocusNode();

  bool postCreating = false;
  final _multiSelectKey = GlobalKey<FormFieldState>();
  TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> _selectedPets = [];

  late DateTimeRange selectedDates;

  int numberOfDays = 0;

  void initState() {
    dateController.text = "";
    super.initState();
  }

  Widget infoPostForm(BuildContext context, UserModel value) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                labelText: "Title", border: OutlineInputBorder()),
            controller: _PostTitle,
            focusNode: _PostTitleNode,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Post",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()),
              controller: _PostContents,
              keyboardType: TextInputType.multiline,
              focusNode: _PostContentsNode,
              // minLines: 10,
              maxLines: 20,
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () {
                    List<Map<String, dynamic>> emptyCommentsArr = [];
                    Map post = <String, dynamic>{
                      "postedBy": <String, dynamic>{
                        "name": value.name['name'],
                        "UID": value.uid['uid'],
                        "pictureUrl": value.hasPicture
                            ? value.pictureUrl["pictureUrl"]
                            : "",
                      },
                      "title": _PostTitle.text,
                      "desc": _PostContents.text,
                      "price": _PriceForRequest.text,
                      "postedTime": Timestamp.now(),
                      "type": selectedPostValue,
                      "comments": emptyCommentsArr
                    };

                    FirebaseFirestore.instance
                        .collection(
                            "/building-codes/${value.buildingCode["buildingCode"]}/posts/")
                        .add({...post})
                        .then((value) => {
                              FirebaseFirestore.instance
                                  .doc(value.path)
                                  .update({"documentID": value.id}),
                            })
                        .then((_) => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Routes(0))),
                              value.getPosts(),
                            });
                    // debugPrint("$post");
                  },
                  child: Text("Post")))
        ],
      ),
    );
  }

  Widget requestPostForm(BuildContext context, UserModel value) {
    // static List pets = value.petInfo;
    final _pets =
        value.petInfo.map((pet) => MultiSelectItem(pet, pet["name"])).toList();
    // debugPrint("Pets: ${pets[0]["name"]}");
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            MultiSelectDialogField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a pet.";
                  }
                  return null;
                },
                buttonText: Text("Select Your Pet"),
                items: _pets,
                title: Text("Select Your Pet"),
                onConfirm: (results) {
                  debugPrint("$results");
                }),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                    labelText: "Select Dates",
                    alignLabelWithHint: true,
                    helperText:
                        "Select which days you want your pet to be watched",
                    border: OutlineInputBorder()),
                onTap: () async {
                  DateTimeRange? dateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101));
                  if (dateRange != null) {
                    String firstDate =
                        DateFormat("MMMd").format(dateRange.start);
                    String lastDate = DateFormat("MMMd").format(dateRange.end);
                    setState(() {
                      dateController.text = "$firstDate - $lastDate";
                      selectedDates = dateRange;
                      numberOfDays = dateRange.end.day - dateRange.start.day;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a date";
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Price",
                  hintText: numberOfDays > 0
                      ? "Recommended: \$${numberOfDays * 20}"
                      : "",
                  helperText:
                      "You won't be charged until you approve someones request",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixText: "\$",
                ),
                controller: _PriceForRequest,
                focusNode: _PriceForRequestNode,
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: "More Info",
                    hintText: "Specify the time, and anything else",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder()),
                controller: _PostContents,
                keyboardType: TextInputType.multiline,
                focusNode: _PostContentsNode,
                maxLines: 10,
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print("Success");
                      }
                      List<Map<String, dynamic>> emptyCommentsArr = [];
                      debugPrint("${selectedDates.start}");
                      Map post = <String, dynamic>{
                        "postedBy": <String, dynamic>{
                          "name": value.name['name'],
                          "UID": value.uid['uid'],
                          "pictureUrl": value.hasPicture
                              ? value.pictureUrl["pictureUrl"]
                              : "",
                        },
                        "title": _PostTitle.text,
                        "desc": _PostContents.text,
                        "price": _PriceForRequest.text,
                        "postedTime": Timestamp.now(),
                        "dateRange": <String, dynamic>{
                          "startTime":
                              selectedDates.start.millisecondsSinceEpoch,
                          "endTime": selectedDates.end.millisecondsSinceEpoch
                        },
                        "type": selectedPostValue,
                        "comments": emptyCommentsArr,
                        "status": "waiting"
                      };

                      /* 
                        Different Status: 
                          Waiting (No Requests Yet)
                          Review (Someone accepted your request, review it)
                          Scheduled (You accepted someones request)
                          In Progress (Happening now)
                          Complete

                        */
                      await FirebaseFirestore.instance
                          .collection(
                              "/building-codes/${value.buildingCode["buildingCode"]}/posts/")
                          .add({...post})
                          .then((doc) => {
                                FirebaseFirestore.instance
                                    .doc(doc.path)
                                    .update({"documentID": doc.id}),
                                // FirebaseFirestore.instance.doc()
                                FirebaseFirestore.instance
                                    .collectionGroup('users')
                                    .where('uid', isEqualTo: value.uid['uid'])
                                    .get()
                                    .then((value) {
                                  value.docs.forEach((element) {
                                    var currentTransactions = [];
                                    if (element
                                        .data()
                                        .containsKey("transactions")) {
                                      currentTransactions =
                                          element["transactions"];
                                    }
                                    element.reference.update({
                                      "transactions": [
                                        ...currentTransactions,
                                        {"path": doc.path}
                                      ]
                                    });
                                  });
                                })
                              })
                          .then((_) => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Routes(0))),
                                value.getPosts(),
                              });
                      debugPrint("$post");
                    },
                    child: Text("Post"))),
          ],
        ),
      ),
    );
  }

  String selectedPostValue = "Request";

  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, value, child) {
        return GestureDetector(
            onTap: (() {
              _PostTitleNode.unfocus();
              _PostContentsNode.unfocus();
              _PriceForRequestNode.unfocus();
            }),
            child: Scaffold(
              appBar: MessageNavBar(),
              body: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton(
                        value: selectedPostValue,
                        items: dropdownItems,
                        onChanged: (String? value) {
                          setState(() {
                            selectedPostValue = value!;
                          });
                        },
                      ),
                      if (selectedPostValue == "Info")
                        (infoPostForm(context, value)),
                      if (selectedPostValue == "Request")
                        (requestPostForm(context, value))
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
