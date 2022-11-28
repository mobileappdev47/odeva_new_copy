import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:eshop/add_address.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Profile.dart';

class Map extends StatefulWidget {
  final double latitude, longitude;
  final String from;

  const Map({Key key, this.latitude, this.longitude, this.from})
      : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng latlong = null;
  CameraPosition _cameraPosition;
  GoogleMapController _controller;
  TextEditingController locationController = TextEditingController();
  Set<Marker> _markers = Set();
  String pincode = " " ;
  bool locationError = false;

  Future getCurrentLocation() async {

    List<Placemark> placemark = await placemarkFromCoordinates(widget.latitude, widget.longitude);

     if (mounted) setState(() {
      latlong = new LatLng(widget.latitude, widget.longitude);

      _cameraPosition = CameraPosition(target: latlong, zoom: 15.0, bearing: 0);
      if (_controller != null)
        _controller
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));

      var address;
      address = placemark[0].name;
      address = address + "," + placemark[0].subLocality;
      address = address + "," + placemark[0].locality;
      address = address + "," + placemark[0].administrativeArea;
      address = address + "," + placemark[0].country;
      address = address + "," + placemark[0].postalCode;
      pincode = placemark[0].postalCode;

      locationController.text = address;
      _markers.add(Marker(
        markerId: MarkerId("Marker"),
        position: LatLng(widget.latitude, widget.longitude),
      ));
    });
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();
    print("PIncode:::"+pincode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(getTranslated(context, 'CHOOSE_LOCATION'), context),
        body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: [
                    (latlong != null)
                        ? GoogleMap(
                        initialCameraPosition: _cameraPosition,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = (controller);
                          _controller.animateCamera(
                              CameraUpdate.newCameraPosition(_cameraPosition));
                        },
                        markers: this.myMarker(),
                        onTap: (latLng) {
                           if (mounted) setState(() {
                            latlong = latLng;
                          });
                        })
                        : Container(),

                  ]),
                ),
                TextField(
                  cursorColor: colors.black,
                  controller: locationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    icon: Container(
                      margin: EdgeInsetsDirectional.only(start: 20, top: 0),
                      width: 10,
                      height: 10,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                    ),
                    hintText: "pick up",
                    border: InputBorder.none,
                    contentPadding: EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
                  ),
                ),
                ElevatedButton(
                  child: Text("Update Location"),
                  onPressed: () {
                    checkLocation();
                  },
                ),
              ],
            )));
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  Future<void>checkLocation()async{
    getLocation();
    try {
      var parameter = {"pincode": pincode.toString()};
      print("PINCODE: " + parameter.toString());
      Response response =
          await post(checkLocationApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        print("Response of check location : " + getdata.toString());

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          debugPrint("---> $data");
          if(widget.from==getTranslated(context,'ADDADDRESS'))
          {
            latitude=latlong.latitude.toString();
            longitude=latlong.longitude.toString();
          }else if(widget.from==getTranslated(context, 'EDIT_PROFILE_LBL')){
            lat=latlong.latitude.toString();
            long=latlong.longitude.toString();
          }
          Navigator.pop(context);
        } else {
          //setSnackbar(msg);
          showAlertDialog(context, msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
        setState(() {

        });
    }
  }


  DateTime now = DateTime.now();//current time
  String formattedDate = "";//initial value empty

  Set<Marker> myMarker() {
    now = DateTime.now();
    print(formattedDate + " != " + DateFormat('kk:mm:ss EEE d MMM').format(now));
    if(formattedDate != DateFormat('kk:mm:ss EEE d MMM').format(now)){

      if (_markers != null) {
        _markers.clear();
      }

      _markers.add(Marker(
        markerId: MarkerId(Random().nextInt(10000).toString()),
        position: LatLng(latlong.latitude, latlong.longitude),
      ));

      getLocation();

      // return _markers;
    }
    if (mounted) setState(() {

      formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);
      print("value updated " + formattedDate);

    });
    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark =
    await placemarkFromCoordinates(latlong.latitude, latlong.longitude);

    var address;
    address = placemark[0].name;
    address = address + "," + placemark[0].subLocality;
    address = address + "," + placemark[0].locality;
    address = address + "," + placemark[0].administrativeArea;
    address = address + "," + placemark[0].country;
    address = address + "," + placemark[0].postalCode;
    pincode = placemark[0].postalCode;
    locationController.text = address;
     if (mounted) setState(() {});
  }

  showAlertDialog(BuildContext context, String msg) {

    // set up the button
    // ignore: deprecated_member_use
    Widget okButton = FlatButton(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent,width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text("OK"),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text("My title"),
      content: Text(msg),//Text("Error Msg"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
