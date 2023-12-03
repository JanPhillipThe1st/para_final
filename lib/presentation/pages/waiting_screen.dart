import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:para_final/presentation/pages/chat.dart';
import 'package:para_final/presentation/pages/home_screen.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen(
      {Key? key,
      required this.tripDetails,
      required this.document,
      required this.userModel})
      : super(key: key);
  final Map<String, dynamic> tripDetails;
  final DocumentReference document;
  final Map<String, dynamic> userModel;
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
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
        .doc(widget.document.id)
        .snapshots()
        .asBroadcastStream();

    requestListener.listen((event) {
      if (event.data() != null) {
        if (event.data()!["status"] == "negotiating") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatUser(
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
                  "Waiting for driver...",
                  style: defaultTextStyle.copyWith(
                      color: Colors.black, fontSize: 24),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Text(
                  "Please review your trip\ndetails in the meantime.",
                  style: defaultTextStyle.copyWith(
                      color: Colors.black, fontSize: 12),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Text(
                  "You are going to: \n" +
                      widget.tripDetails["destination"]["place"],
                  textAlign: TextAlign.center,
                  style: defaultTextStyle.copyWith(color: Colors.black),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 30)),
                TextButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Cancel ride request'),
                            content: const Text(
                              'Press ok to cancel request',
                            ),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                                child: const Text('OK'),
                                onPressed: () async {
                                  requestListener.drain();
                                  await db
                                      .collection("requests")
                                      .doc(widget.document.id)
                                      .delete()
                                      .then((value) {
                                    Navigator.pop(context, "OK");
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ).then((value) {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text("Cancel"))
              ],
            ),
          ))
        ],
      ),
    );
  }
}
