import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';  // for Map Controller, LatLng & GoogleMap() widget


// 8. Create GoogleMapController? mapController;
// 9. Create LatLng Object as final LatLng _center = const LatLng(45.521563, -122.677433);
// 10. Create Function 'void mapcreated(GoogleMapController controller){} and declare mapController = controller';
// 11. create GoogleMap() widget and define its properties

// To Add Custom Marker on Map
// 12. Create Class Marker _Mymark = Marker(
//                                  markerId: MarkerId("Hyd"),
//                                  position: [LatLng Position],
//                                  infoWindow: InfoWindow(title: "Hyd")),
//                                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.HueBlue);
// 13. To Solve Error of _centre in Position: property, Use Static keyword in LatLng class
// [InfoWindow] - Shows the information on tap of custom marker. (title) is name, (snippet) is the description
// [BitmapDescriptor] - to use icon in Marker, we use BitmapDescriptor()

// 14. To Add button that leads to location with smooth Camera flow with angles? follow FloatingActionButton below!


class ShowSimpleMap extends StatefulWidget {
  const ShowSimpleMap({super.key});

  @override
  State<ShowSimpleMap> createState() => _ShowSimpleMapState();
}

class _ShowSimpleMapState extends State<ShowSimpleMap> {


  GoogleMapController? mapController;

  // Longitude and Lantitude single object to know the position of map
  static LatLng _location = LatLng(45.521563, -122.677433);

  // Hyderabad Cordinates
  static LatLng _location2 = LatLng(25.370018, 68.357006);

  // used inside property onMapCreated: of GoogleMap()
  // Map Controller is your Phone Controller like touching zooming scrolling map screen.
  void _onMapCreated(GoogleMapController controller) { 
    mapController = controller;
  }

  
  // Method to move to custom pinpoint location on FAB Tap!
  Future _gotoIntel() async{
    final GoogleMapController? controller = await mapController;
    final CameraPosition intelPosition = CameraPosition(target: LatLng(45.5418295, -122.9170456), zoom: 14.5, bearing: 191, tilt: 35);
    controller!.animateCamera(CameraUpdate.newCameraPosition(intelPosition));
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Google Maps"),
          centerTitle: true,
          ),
    
          
          body: GoogleMap(
            initialCameraPosition: CameraPosition(target: _location2, zoom: 11.0),
    
            // the moment map is created and want to pass a controller that will start controlling our Map Object
            onMapCreated: _onMapCreated,

            // To Add custom Markers on Map
            // uses {, ,} to place multiple Markers
            markers: {MyMarker, Hyd_Marker},
            
            ),

          // Same as basic FAB but Wider and Text Support
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _gotoIntel, 
            label: Text("Intel Corp"), 
            icon: Icon(Icons.arrow_drop_up),
            ),

          // OPTIONAL
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

          
      ),
    );

  }


  // Custom Marker Widget - Used inside markers: {}
  Marker MyMarker = Marker(
    markerId: MarkerId("Portland"), 
    position: _location, 
    infoWindow: InfoWindow(title: "Portland", snippet: "this is Portland"),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker Hyd_Marker = Marker(
    markerId: MarkerId("My Home"), 
    position: _location2, 
    infoWindow: InfoWindow(title: "Civic Centre", snippet: "this is Home!"),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );




}