import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loocator/constants.dart';

String mode = 'walking';

Future<Map<String, dynamic>?> getDistanceMatrix(
    String origin, String destinations) async {
  try {
    var responseJSON = await Dio().get(
        // The Distance Matrix API Request URL
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destinations&origins=$origin&mode=$mode&units=meters&key=$GOOGLE_MAPS_API_KEY');
    Map<String, dynamic>? response = responseJSON.data;
    debugPrint(response.toString());
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<int> findNearestDestination(String origin, String destinations) async {
  Map<String, dynamic>? response =
      await getDistanceMatrix(origin, destinations);
  List<dynamic> distances = response!["rows"][0]["elements"];

  double minDistance = distances[0]["distance"]["value"].toDouble();
  int nearestIndex = 0;

  for (int i = 0; i < distances.length; i++) {
    if (distances[i]["distance"]["value"].toDouble() < minDistance) {
      minDistance = distances[i]["distance"]["value"].toDouble();
      nearestIndex = i;
    }
  }

  debugPrint('$minDistance $nearestIndex');
  return nearestIndex;
}
