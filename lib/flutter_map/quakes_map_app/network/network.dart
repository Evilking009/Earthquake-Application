import 'package:map_application/flutter_map/quakes_map_app/model/quake.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Network{

  Future<Quake> getAllQuakes() async {

    var apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_week.geojson";

    final rr = await get(Uri.parse(Uri.encodeFull(apiUrl)));

    if(rr.statusCode == 200){

      print("Quake data: ${rr.body}");
      return Quake.fromJson(json.decode(rr.body));

    }

    else{
      throw Exception("Error Getting Quakes!");
    }

  }
}