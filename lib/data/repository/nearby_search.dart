import 'dart:convert';
import 'dart:io';
import 'package:para_final/data/models/nearby_search_result_tomtom.dart';
import 'package:http/http.dart' as http;
import 'package:para_final/data/models/poi.dart';

class NearbySearch {
  Future<NearbySearchResult> tomTomNearbySearch(double lat, double lon) async {
    NearbySearchResult nearbySearchResult = NearbySearchResult();
    final response = await http
        .get(TomTomRequestData(lat: lat, lon: lon).buildNetworkRequest());

    if (response.statusCode == 200) {
      nearbySearchResult =
          NearbySearchResult.fromJSON(jsonDecode(response.body));
    }
    return nearbySearchResult;
  }

  Future<Map<String, dynamic>> tomTomNearbySearchAsJSON(
      double lat, double lon) async {
    http.Response response = await http.get(Uri.parse(
        "https://api.tomtom.com/search/2/nearbySearch/.json?key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=$lat&lon=$lon"));
    return jsonDecode(response.body);
  }
}

class TomTomRequestData {
  double? lat = 0.0;
  double? lon = 0.0;
  List<POIFilter>? filters = [];
  String? tomTomHost = "https://api.tomtom.com/search/2/nearbySearch/.json?";
  TomTomRequestData({this.lat, this.lon});

  Uri buildNetworkRequest() {
    return Uri.parse(
        tomTomHost! + "key=TNrPv6isrGooVIYCXns3WcJRtjhNAZpy&lat=$lat&lon=$lon");
  }
}
