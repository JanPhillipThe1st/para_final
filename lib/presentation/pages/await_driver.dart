import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:para_final/presentation/pages/chat.dart';
import 'package:para_final/presentation/pages/home_screen.dart';
import 'package:para_final/presentation/pages/meet_driver.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AwaitDriver extends StatefulWidget {
  const AwaitDriver({Key? key, required this.tripID, required this.tripDetails})
      : super(key: key);
  final String tripID;
  final Map<String, dynamic> tripDetails;
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<AwaitDriver> {
  bool _isCancelled = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Stream<DocumentSnapshot<Map<String, dynamic>>> requestListener =
      Stream.empty();
  @override
  void initState() {
    getSuggestions();
    super.initState();
  }

  Future<void> getSuggestions() async {
    requestListener = db
        .collection("requests")
        .doc(widget.tripID)
        .snapshots()
        .asBroadcastStream();

    requestListener.listen((event) {
      if (event.data() != null) {
        if (event.data()!["status"] == "pick_up") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MeetDriver(
                    tripID: event.id,
                    tripDetails: widget.tripDetails,
                  )));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
              child: Container(
            height: 500,
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: LinearProgressIndicator(
                    color: Color.fromARGB(255, 69, 226, 253),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Text(
                  "Your driver is on the way!\nPlease stay where you are.",
                  style: defaultTextStyle.copyWith(
                      color: Colors.black, fontSize: 16),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
