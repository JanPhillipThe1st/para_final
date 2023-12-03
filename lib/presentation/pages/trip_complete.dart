import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:para_final/presentation/pages/chat.dart';
import 'package:para_final/presentation/pages/home_screen.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:checkmark/checkmark.dart';

class TripComplete extends StatefulWidget {
  const TripComplete(
      {Key? key, required this.tripID, required this.tripDetails})
      : super(key: key);
  final String tripID;
  final Map<String, dynamic> tripDetails;
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<TripComplete> {
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
    setState(() {
      tripDistance = Geolocator.distanceBetween(
          widget.tripDetails["origin"]["location"]["latitude"],
          widget.tripDetails["origin"]["location"]["longitude"],
          widget.tripDetails["destination"]["location"]["lat"],
          widget.tripDetails["destination"]["location"]["lon"]);
      if (tripDistance < 1500) {
        tripPrice = 15;
      } else {
        tripPrice = 15;
        tripPrice += ((tripDistance - 1500) / 500);
      }
    });
    requestListener = db
        .collection("requests")
        .doc(widget.tripID)
        .snapshots()
        .asBroadcastStream();

    requestListener.listen((event) {
      if (event.data() != null) {
        if (event.data()!["status"] == "comple") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatUser(
                    tripID: event.id,
                    tripDetails: widget.tripDetails,
                  )));
        }
      }
    });
  }

  double tripPrice = 0;
  double tripDistance = 0;
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
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CheckMark(
                      active: true,
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 500),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Text(
                  "Your driver has arrived. Please meet them.",
                  style: defaultTextStyle.copyWith(
                      color: Colors.black, fontSize: 16),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Text(
                  "Trip Price: PHP: ${tripPrice.toStringAsFixed(2)}",
                  style: defaultTextStyle.copyWith(
                      color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
