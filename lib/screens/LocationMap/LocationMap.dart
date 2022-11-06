import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:location_tracker/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late IO.Socket socket;
  late Map<MarkerId, Marker> _markers;
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  CameraPosition? _cameraPosition;

  @override
  void initState() {
    getCurrentLocation();

    listen();

    _markers = <MarkerId, Marker>{};
    _markers.clear();

    super.initState();
  }

  getCurrentLocation() {
    Location location = Location();

    location.getLocation().then(((coords) {
      currentLocation = coords;
      _cameraPosition = CameraPosition(
          target: LatLng(coords.latitude!, coords.longitude!), zoom: 19);

      setState(() {});
    }));
  }

  listen() async {
    await initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket = IO.io(socketUri, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      print('trying connnection');
      socket.connect();

      socket.onConnect((data) => print('Connect: ${socket.id}'));

      socket.on('position-change', (data) async {
        var latLng = jsonDecode(data);
        print('position just changed');
        LatLng newLocation = LatLng(latLng['lat'], latLng['long']);

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 19,
            ),
          ),
        );

        var markerImg = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/marker.png');

        Marker marker = Marker(
            markerId: const MarkerId('ID'),
            icon: markerImg,
            position: newLocation);

        setState(() {
          _markers[const MarkerId('ID')] = marker;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('new location!')));
      });
    } catch (e) {
      print('error');
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF1A1A3F),
                rightDotColor: const Color(0xFFEA3799),
                // color: Colors.red,
                size: 70,
              ),
            )
          : GoogleMap(
              initialCameraPosition: _cameraPosition!,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of(_markers.values),
            ),
    );
  }

  @override
  void dispose() {
    initState();
    super.dispose();
  }
}
