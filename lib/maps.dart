import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/coffee.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController _controller;
  Position currentLocation;
  final Set<Polyline> polyline = {};

  List<Marker> allMarkers = [];
  List<Coffee> coffeeShops = [];
  PageController _pageController;
  Marker tappedMarker;
  int prevPage;

  bool mapToggle = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Geolocator().getCurrentPosition().then((currloc) => setState(() {
          currentLocation = currloc;
        }));
    _loadCompany();
  }

  _loadCompany() async {
    final responseTask =
        await http.get('https://fb39827a1ae5.ngrok.io/api/companyinfoes');
    if (responseTask.statusCode == 200) {
      var coffeeMaps = jsonDecode(responseTask.body);
      double a;
      var coffeeTemp = List<Coffee>();
      for (var coffee in coffeeMaps) {
        a = coffee['latitude'];
        print(a.toString());
        coffeeTemp.add(Coffee.fromJson(coffee));
      }
      setState(() {
        coffeeShops = coffeeTemp;
        mapToggle = true;
      });
    }
    coffeeShops.forEach((element) {
      allMarkers.add(Marker(
          markerId: MarkerId(element.shopName),
          draggable: false,
          infoWindow:
              InfoWindow(title: element.shopName, snippet: element.address),
          position: LatLng(element.latitude, element.longtitude)));
    });
    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      moveCamera();
    }
  }

  _coffeeShopList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 125.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
          onTap: () {
            // moveCamera();
          },
          child: Stack(children: [
            Center(
                child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20.0,
                    ),
                    height: 125.0,
                    width: 280.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(0.0, 4.0),
                            blurRadius: 10.0,
                          ),
                        ]),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: Row(children: [
                          Container(
                              height: 90.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0)),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          coffeeShops[index].thumbNail),
                                      fit: BoxFit.cover))),
                          SizedBox(width: 5.0),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coffeeShops[index].shopName,
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  coffeeShops[index].address,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  width: 170.0,
                                  child: Text(
                                    coffeeShops[index].description,
                                    style: TextStyle(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w300),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ])
                        ]))))
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Maps'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            mapToggle
                ? Container(
                    height: MediaQuery.of(context).size.height - 50.0,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      polylines: polyline,
                      compassEnabled: true,
                      initialCameraPosition: CameraPosition(
                          target:
                              /*LatLng(
                            42.868223,
                            74.597607,
                          ),
                          zoom: 12.0),*/
                              LatLng(currentLocation.latitude,
                                  currentLocation.longitude),
                          zoom: 12.0),
                      markers: Set.from(allMarkers),
                      onMapCreated: mapCreated,
                      onTap: _handleTap,
                    ),
                  )
                : Center(
                    child: Text(
                      'Загрузка.. Пожалуйста подождите',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
            mapToggle
                ? Positioned(
                    bottom: 350.0,
                    child: Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: coffeeShops.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _coffeeShopList(index);
                        },
                      ),
                    ),
                  )
                : Spacer()
          ],
        ));
  }

  _handleTap(LatLng tappedPoint) {
    List<LatLng> latLng = [
      new LatLng(42.874927, 74.570241),
      new LatLng(42.877737, 74.587425)
    ];
    setState(() {
      polyline.add(new Polyline(
          polylineId: PolylineId("atai"),
          points: latLng,
          visible: true,
          color: Colors.green));
      allMarkers.remove(tappedMarker);
      tappedMarker = new Marker(
          markerId: MarkerId(tappedPoint.toString()), position: tappedPoint);
      allMarkers.add(tappedMarker);
    });
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(coffeeShops[_pageController.page.toInt()].latitude,
            coffeeShops[_pageController.page.toInt()].longtitude),
        zoom: 18.0,
        bearing: 45.0,
        tilt: 45.0)));
  }
}
