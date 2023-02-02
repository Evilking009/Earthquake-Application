import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_application/flutter_map/quakes_map_app/network/network.dart';
import 'model/quake.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'util/stringextension.dart';


class QuakesApp extends StatefulWidget {
  const QuakesApp({super.key});

  @override
  State<QuakesApp> createState() => _QuakesAppState();
}

class _QuakesAppState extends State<QuakesApp> {

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _MapControllerBasic;
  _mapController(GoogleMapController Controller) {
    _controller.complete(Controller);
    _MapControllerBasic = Controller;
    }
  

  List<Marker> _markerList = [];

  List? _CountryList = [];
  List? _CountryPlace = [];
  List<double>? _LatList = [];
  List<double>? _LngList = [];

  MapType _mapType = MapType.normal;
  int counter = 0;


  void findQuakes(){
   _markerList.clear();
    setState(() {
      _quakesData.then((quakes) => {
        quakes.features!.forEach((quake) { 
            _markerList.add(
              Marker(
                markerId: MarkerId(quake.id!),
                infoWindow: InfoWindow(
                  title: quake.properties!.mag.toString(),
                  snippet: quake.properties!.title,
                  onTap: (){
                   launchUrlStart(url: quake.properties!.url.toString());
                  }
                  ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                position: LatLng(quake.geometry!.coordinates![1], quake.geometry!.coordinates![0]),
                ));
            _CountryList!.add(quake.properties!.place.toString());
            _CountryPlace!.add(quake.properties!.title.toString());
            _LatList!.add(quake.geometry!.coordinates![1].toDouble());
            _LngList!.add(quake.geometry!.coordinates![0].toDouble());

         })
      });
      
    }); 
  }
    // Url Launcher Method
    Future<void> launchUrlStart({required String url}) async {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    // Get User Current Location button
    Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }



  late Future<Quake> _quakesData; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quakesData = Network().getAllQuakes();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(

        appBar: AppBar(
          title: Text("EarthQuake Detector"),
          centerTitle: true,
        ),

        body: Stack(
          children: [

          GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(36.1083333, -117.8608333), zoom: 11),
          onMapCreated: _mapController,
          markers: Set.of(_markerList),
          mapType: _mapType,
          


        ),




          ],
          ),

          floatingActionButton: Wrap(
            spacing: 10,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.start,

            children: [
              Container(
                child: FloatingActionButton(
                  heroTag: "X1",
                  onPressed: ()async{
                      
                      getUserCurrentLocation().then((value) async{
                        print(value.latitude.toString() + " " + value.longitude.toString());

                        _markerList.add(
                        Marker(
                          markerId: MarkerId("X"),
                          position: LatLng(value.latitude, value.longitude),
                          infoWindow: InfoWindow(title: "Your Current Location"),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
                          )
                          
                      );

                      CameraPosition cameraPosition = CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14.5);

                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
                      setState(() {});

                      });

                      
                  },
                  child: Icon(Icons.pin_drop), 
                ),


              ),
                Container(
                child: FloatingActionButton(
                  heroTag: "X2",
                  onPressed: (){

                    counter++;

                    if(counter == 1) {
                      setState(() {
                         _mapType = MapType.terrain;
                       });
                    }

                    else if(counter == 2) {
                       setState(() {
                         _mapType = MapType.satellite;
                       });
                    }

                    else if(counter == 3){
                      setState(() {
                         _mapType = MapType.normal;
                         counter = 0;
                       });
                    }


                    },
                  child: Icon(Icons.map), 
                ),
              ),

              

              Builder(
                builder: (context) {
                  return FloatingActionButton.extended(
                    heroTag: "X3",
                    onPressed: (){  
                      findQuakes();

                      SnackBar ss = const SnackBar(content: Text("Markers Deplyoed successfully!"));
                      ScaffoldMessenger.of(context).showSnackBar(ss);
                      },
                    icon: Icon(Icons.water_sharp),
                    label: Text("Show Data"),
                  );
                }
              ),
            ],

          ),
          

          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

          


          drawer: myDrawer(_CountryList, _CountryPlace, _MapControllerBasic, _LatList, _LngList),

      ),
    );
  }
}

Widget myDrawer([List? countryList, List? countryPlace, GoogleMapController? controller, List? Latitudes, List? Longitudes]){
  return Builder(
            builder: (context) {
              return Drawer(
                child: ListView(
                  children: [

                    _drawerHeader(),

                    ListTile(
                      title: Text("Home"),
                      leading: Icon(Icons.house_outlined),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => QuakesApp())));
                      },
                    ),

                    if(countryList!.isNotEmpty)
                    ListTile(
                      title: Text("Search"),
                      leading: Icon(Icons.search_outlined),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => searchList(
                          countryList: countryList, 
                          countryPlace: countryPlace,
                          mapController: controller,
                          Lats: Latitudes,
                          Longs: Longitudes,
                          ))));
                      },
                    ),

                    ListTile(
                      title: Text("About"),
                      leading: Icon(Icons.info_outline),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => _AboutScreen())));
                      },
                    ),
                    
                  ],
                ),

              );
            }
          );
}


Widget _drawerHeader(){
  return DrawerHeader(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage("images/Header.jpg"),fit: BoxFit.fill)
                    ),
                    child: Stack(
                      children: const [
                      Positioned(
                        bottom: 12.0,
                        left: 16.0,
                        child: Text("Main Menu", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)))
                      
                    ]),
                  )
                  );
}


class _AboutScreen extends StatelessWidget {
  const _AboutScreen({super.key});

  final String url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTL26uY9-RLO9gMsg9uai-7UkF3Mr5uM7yPE_YOPHAtBY3xM1ypO3oekaWwtO1ZIO_Zk9I&usqp=CAU";

  final double _fontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("About"),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(url),
                radius: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                "Created with ",
                style: TextStyle(fontSize: _fontSize),
                ),
                Image.network("https://cdn-icons-png.flaticon.com/512/2883/2883911.png", width: 40, height: 40),
                Text(
                " By Muzaffar Hassan",
                style: TextStyle(fontSize: _fontSize),
                ),
              ],),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("If you like my App then do contact me at +92345443435 or email me at DummyDesign24@Gmail.com", style: TextStyle(fontSize: 17)),
              ),           
            ],
          ),
        ),
      );
  }
}



class searchList extends StatefulWidget {

  List? countryList, countryPlace = [];
  List? foundItemList = [];    
  List? foundItemList2 = [];   
  List? Lats, Longs = [];

  int indexNo = 0;

  GoogleMapController? mapController;

  searchList({super.key, this.countryList, this.countryPlace, required this.mapController, this.Lats, this.Longs});

  @override
  State<searchList> createState() => _searchListState();
}

class _searchListState extends State<searchList> {
  @override

  // Method to move to custom pinpoint location on FAB Tap!
  Future _gotoIntel(double lat, double lng) async{
    final controller = await widget.mapController;
    CameraPosition intelPosition = CameraPosition(target: LatLng(lat, lng), zoom: 14.5);
    controller!.animateCamera(CameraUpdate.newCameraPosition(intelPosition));
  }

// Methods
  void filterItems(String itemName){
  List result = [];
  // if dont search anything? Show default list
  if(itemName.trim().isEmpty){
    result = widget.countryPlace!;
  }
  else{
    result = widget.countryPlace!.where((element) => element.toString().capitalize().contains(itemName)).toList();
  }
  setState((){
    widget.foundItemList = result;
    widget.indexNo = result.length;
  });
}

void filterItems2(String itemName){
  List result = [];
  // if dont search anything? Show default list
  if(itemName.trim().isEmpty){
    result = widget.countryList!;
  }
  else{
    result = widget.countryList!.where((element) => element.toString().capitalize().contains(itemName)).toList();
  }
  setState((){
    widget.foundItemList2 = result;
  });
}
// End of Methods



  void initState() {
    widget.foundItemList = widget.countryPlace;
    widget.foundItemList2 = widget.countryList;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

    appBar: AppBar(
      title: TextField(
        onChanged: (value) {
          filterItems(value);
          filterItems2(value);
          },
        decoration: const InputDecoration(
          hintText: "Tap Here to Search Places",
          hintStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(Icons.search, color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      )
    ),

    body: ListView.builder(
      itemCount: widget.indexNo == 0? widget.foundItemList?.length:widget.indexNo,
      itemBuilder: ((context, index) {

        return Card(
          margin: EdgeInsets.all(5),
          elevation: 8,
          child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          leading: CircleAvatar(child: Text((index+1).toString()),),

          subtitle: Text(widget.foundItemList2![index].toString()),
          title: Text(widget.foundItemList![index].toString()),

          onTap: (() {
            
          }),
        ),
        );
        
      })
      )

  );
    
  }
}