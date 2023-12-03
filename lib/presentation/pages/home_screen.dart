import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:para_final/data/models/nearby_search_result_tomtom.dart';
import 'package:para_final/data/models/poi.dart';
import 'package:para_final/data/repository/nearby_search.dart';
import 'package:para_final/presentation/pages/waiting_screen.dart';
import 'package:para_final/presentation/widgets/rounded_information.dart';
import 'package:para_final/presentation/widgets/text_field_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:para_final/data/models/routing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';
import 'package:filter_list/filter_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.userModel}) : super(key: key);
  final Map<String, dynamic> userModel;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Marker? _passengerOrigin;
  Completer<GoogleMapController> _controller = Completer();
  TomTomRouting networkUtilTomTom = TomTomRouting();
  List<Map<String, dynamic>> addresses = [];
  bool requestSent = false;
  DocumentReference? documentReference;
  List<POIFilter> filters = [
    POIFilter(name: "mall"),
    POIFilter(name: "park"),
    POIFilter(name: "cafe"),
    POIFilter(name: "restaurant"),
    POIFilter(name: "store"),
    POIFilter(name: "school"),
    POIFilter(name: "church"),
    POIFilter(name: "market"),
  ];
  Map<String, dynamic>? address;
  final NearbySearch _nearbySearch = NearbySearch();
  Position? currentLocation;
  NearbySearchResult searchNearbyResponse = NearbySearchResult();
  Future<void> getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    await Geolocator.getCurrentPosition().then((value) async {
      currentLocation = value;

      _passengerOrigin = Marker(
          draggable: true,
          onDragEnd: (LatLng pos) {
            String uriString =
                "https://api.tomtom.com/search/2/nearbySearch/.json?key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=${pos.latitude}&lon=${pos.longitude}";
            Uri requestUri = Uri.parse(uriString);
            new HttpClient()
                .getUrl(requestUri)
                .then((HttpClientRequest request) {
              // Optionally set up headers...
              // Optionally write to the request object...
              // Then call close.
              return request.close();
            }).then((HttpClientResponse response) async {
              addresses.clear();
              Map<String, dynamic> poi =
                  jsonDecode(await response.transform(utf8.decoder).join());
              for (Map<String, dynamic> result in poi["results"]) {
                addresses.add({
                  "place": result["poi"]["name"],
                  "location": result["position"]
                });
              }
              setState(() {});
            });
          },
          markerId: MarkerId(widget.userModel["name"]),
          infoWindow: InfoWindow(
              title: widget.userModel["name"], snippet: "Dao, Pagadian City"),
          position: LatLng(value.latitude, value.longitude));
      String uriString =
          "https://api.tomtom.com/search/2/nearbySearch/.json?key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=${value.latitude}&lon=${value.longitude}";
      Uri requestUri = Uri.parse(uriString);
      new HttpClient().getUrl(requestUri).then((HttpClientRequest request) {
        // Optionally set up headers...
        // Optionally write to the request object...
        // Then call close.
        return request.close();
      }).then((HttpClientResponse response) async {
        Map<String, dynamic> poi =
            jsonDecode(await response.transform(utf8.decoder).join());
        for (Map<String, dynamic> result in poi["results"]) {
          addresses.add(
              {"place": result["poi"]["name"], "location": result["position"]});
        }
        setState(() {});
      });
      // Map<String, dynamic> poi = jsonDecode(response.body);
      // for (Map<String, dynamic> result in poi["results"]) {
      //   addresses.add(
      //       {"place": result["poi"]["name"], "location": result["position"]});
      // }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            child: Container(
              child: StreamBuilder<Position>(
                  stream: Geolocator.getPositionStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      currentLocation = snapshot.data;
                      return GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            zoom: 15,
                            target: LatLng(currentLocation!.latitude,
                                currentLocation!.longitude)),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: {
                          _passengerOrigin != null
                              ? Marker(
                                  draggable: true,
                                  onDragEnd: (LatLng pos) {
                                    String uriString =
                                        "https://api.tomtom.com/search/2/nearbySearch/.json?key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=${pos.latitude}&lon=${pos.longitude}";
                                    Uri requestUri = Uri.parse(uriString);
                                    new HttpClient().getUrl(requestUri).then(
                                        (HttpClientRequest request) {
                                      // Optionally set up headers...
                                      // Optionally write to the request object...
                                      // Then call close.
                                      return request.close();
                                    }).then(
                                        (HttpClientResponse response) async {
                                      addresses.clear();
                                      Map<String, dynamic> poi = jsonDecode(
                                          await response
                                              .transform(utf8.decoder)
                                              .join());
                                      for (Map<String, dynamic> result
                                          in poi["results"]) {
                                        addresses.add({
                                          "place": result["poi"]["name"],
                                          "location": result["position"]
                                        });
                                      }
                                      setState(() {});
                                    });
                                  },
                                  markerId: _passengerOrigin!.markerId,
                                  infoWindow: _passengerOrigin!.infoWindow,
                                  position: LatLng(snapshot.data!.latitude,
                                      snapshot.data!.longitude),
                                )
                              : Marker(
                                  draggable: true,
                                  onDragEnd: (LatLng pos) {
                                    String uriString =
                                        "https://api.tomtom.com/search/2/nearbySearch/.json?key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=${pos.latitude}&lon=${pos.longitude}";
                                    Uri requestUri = Uri.parse(uriString);
                                    new HttpClient().getUrl(requestUri).then(
                                        (HttpClientRequest request) {
                                      // Optionally set up headers...
                                      // Optionally write to the request object...
                                      // Then call close.
                                      return request.close();
                                    }).then(
                                        (HttpClientResponse response) async {
                                      addresses.clear();
                                      Map<String, dynamic> poi = jsonDecode(
                                          await response
                                              .transform(utf8.decoder)
                                              .join());
                                      for (Map<String, dynamic> result
                                          in poi["results"]) {
                                        addresses.add({
                                          "place": result["poi"]["name"],
                                          "location": result["position"]
                                        });
                                      }
                                      setState(() {});
                                    });
                                  },
                                  markerId: MarkerId(widget.userModel["name"]),
                                  infoWindow: InfoWindow(
                                      title: widget.userModel["name"],
                                      snippet: "Dao, Pagadian City"),
                                  position: LatLng(snapshot.data!.latitude,
                                      snapshot.data!.longitude),
                                )
                        },
                      );
                    }
                  }),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedInformation(
                    text: widget.userModel["name"],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  RoundedInformation(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        widget.userModel["profile_image"],
                        height: 60,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  RoundedInformation(
                    text: "Dao, Pagadian City".substring(0, 10) + "...",
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              maxChildSize: 0.6,
              minChildSize: .1,
              snap: true,
              snapSizes: [
                0.3,
              ],
              initialChildSize: 0.1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ListView(
                  controller: scrollController,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        shadows: [BoxShadow()],
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.all(10),
                          width: 50,
                          height: 2.5,
                          decoration: ShapeDecoration(
                            color: const Color.fromARGB(255, 105, 105, 105),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: TextFieldWidget(
                          hinttext: "Search for destination...",
                          color: Colors.white,
                          textColor: Colors.black,
                          hintTextColor: Colors.grey,
                          controller: TextEditingController(),
                          onchange: (value) {}),
                    ),
                    Container(
                      color: Colors.white,
                      child: Container(
                        decoration: ShapeDecoration(
                            color: Color.fromARGB(255, 74, 122, 255),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40))),
                        margin: EdgeInsets.only(left: 330, right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              icon: Icon(Icons.filter_list),
                              color: Colors.white,
                              onPressed: () async {
                                filters = [
                                  POIFilter(name: "mall"),
                                  POIFilter(name: "park"),
                                  POIFilter(name: "cafe"),
                                  POIFilter(name: "restaurant"),
                                  POIFilter(name: "store"),
                                  POIFilter(name: "school"),
                                  POIFilter(name: "church"),
                                  POIFilter(name: "market"),
                                ];
                                await FilterListDialog.display<POIFilter>(
                                  context,
                                  listData: filters,
                                  selectedListData: filters,
                                  choiceChipLabel: (user) => user!.name,
                                  validateSelectedItem: (list, val) =>
                                      list!.contains(val),
                                  onItemSearch: (user, query) {
                                    return user.name!
                                        .toLowerCase()
                                        .contains(query.toLowerCase());
                                  },
                                  onApplyButtonClick: (list) {
                                    setState(() {
                                      filters = List.from(list!);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      color: Colors.white,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Nearby Destinations",
                              style: defaultTextStyle.copyWith(
                                  color: Colors.black),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4)),
                            Icon(
                              Icons.location_pin,
                              size: 30,
                              color: Colors.red,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 500,
                      padding: EdgeInsets.only(bottom: 100),
                      color: Colors.white,
                      child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: ShapeDecoration(
                                        shadows: [
                                          BoxShadow(
                                              color: Color.fromARGB(
                                                  255, 22, 30, 37),
                                              offset: Offset(0, 0),
                                              blurRadius: 2)
                                        ],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        gradient: LinearGradient(
                                            colors: [
                                              Color.fromARGB(
                                                  222, 120, 255, 244),
                                              Color.fromARGB(222, 112, 87, 255),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)),
                                    padding: EdgeInsets.all(4),
                                    child: ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.asset(
                                        "assets/icons/d70.jpg",
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5)),
                                  Container(
                                    width: 200,
                                    child: Text(
                                      addresses[index]["place"].toString(),
                                      style: defaultTextStyle.copyWith(
                                          color: Colors.black87, fontSize: 10),
                                      softWrap: true,
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5)),
                                  Container(
                                    decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        color: Colors.blue),
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title:
                                                const Text('Send Ride Request'),
                                            content: Text("Going to: " +
                                                addresses[index]["place"]),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  FirebaseFirestore db =
                                                      FirebaseFirestore
                                                          .instance;
                                                  new HttpClient()
                                                      .getUrl(Uri.parse(
                                                          "https://api.tomtom.com/search/2/nearbySearch/.json?key=OvlYvFPqknOFMPZTSf0KjTqYTaVD4f9F&lat=${currentLocation!.latitude}&lon=${currentLocation!.longitude}&limit=1"))
                                                      .then((HttpClientRequest
                                                          request) {
                                                    return request.close();
                                                  }).then((HttpClientResponse
                                                          response) async {
                                                    Map<String, dynamic>
                                                        jsonResult = jsonDecode(
                                                            await response
                                                                .transform(utf8
                                                                    .decoder)
                                                                .join());
                                                    documentReference = await db
                                                        .collection("requests")
                                                        .add({
                                                      "date_requested":
                                                          DateTime.now(),
                                                      "destination":
                                                          addresses[index],
                                                      "status": "open",
                                                      "origin": {
                                                        "passenger_location": jsonResult[
                                                                    "results"][0]
                                                                [
                                                                "poi"]["name"] +
                                                            ", " +
                                                            jsonResult["results"]
                                                                        [0]
                                                                    ["address"]
                                                                ["streetName"] +
                                                            ", " +
                                                            jsonResult["results"]
                                                                        [0]
                                                                    ["address"][
                                                                "municipalitySubdivision"],
                                                        "location": {
                                                          "latitude":
                                                              currentLocation!
                                                                  .latitude,
                                                          "longitude":
                                                              currentLocation!
                                                                  .longitude
                                                        }
                                                      }
                                                    });
                                                    address = addresses[index];

                                                    Navigator.pop(
                                                        context, 'OK');
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                WaitingScreen(
                                                                  document:
                                                                      documentReference!,
                                                                  tripDetails: {
                                                                    "destination":
                                                                        address,
                                                                    "status":
                                                                        "open",
                                                                    "origin": {
                                                                      "location":
                                                                          {
                                                                        "latitude":
                                                                            currentLocation!.latitude,
                                                                        "longitude":
                                                                            currentLocation!.longitude
                                                                      }
                                                                    }
                                                                  },
                                                                  userModel: widget
                                                                      .userModel,
                                                                )));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Ride Request was successfully sent!")));
                                                  });
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "GO",
                                            style: defaultTextStyle.copyWith(
                                                fontSize: 10),
                                          ),
                                          Icon(
                                            Icons.arrow_right,
                                            color: textColor,
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
