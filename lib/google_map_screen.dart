import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/direction_model.dart';
import 'package:googlemap/directionrepo.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(21.1702, 72.8311), zoom: 11.5);

  GoogleMapController? _googleMapController;
  Marker? origin;
  // Marker? destination;
  Directions? info;

  /// current Location to
  Position? currentPosition;
  var geoLocator = Geolocator();
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 18);
    _googleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  /// to this
  @override
  dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white24,
        title: const Text(
          'Google Map',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          if (origin != null)
            TextButton(
              onPressed: () => _googleMapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: origin!.position, zoom: 14.5, tilt: 50.0),
                ),
              ),
              child: const Text(
                'Origin',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // if (destination != null)
          //   TextButton(
          //     onPressed: () => _googleMapController?.animateCamera(
          //       CameraUpdate.newCameraPosition(
          //         CameraPosition(
          //             target: destination!.position, zoom: 14.5, tilt: 50.0),
          //       ),
          //     ),
          //     child: const Text(
          //       'Destination',
          //       style: TextStyle(
          //         color: Colors.blue,
          //         fontSize: 18,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            trafficEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _googleMapController = controller;
              locatePosition();
            },
            onTap: _addMarker,
            polylines: {
              if (info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 7,
                  points: info!.polylinePoints!
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            markers: {
              if (origin != null) origin!,
              // if (destination != null) destination!
            },
          ),
          // if (info != null)
          //   Positioned(
          //     child: Container(
          //       padding:
          //           const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          //       decoration: BoxDecoration(
          //         color: Colors.yellowAccent,
          //         borderRadius: BorderRadius.circular(20),
          //         boxShadow: const [
          //           BoxShadow(
          //             color: Colors.black26,
          //             offset: Offset(0, 2),
          //             blurRadius: 6.0,
          //           )
          //         ],
          //       ),
          //       child: Text(
          //         '${info?.totalDistance},${info?.totalDuration}',
          //         style: const TextStyle(
          //           fontSize: 18.0,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          locatePosition();
        },
        // onPressed: () => _googleMapController?.animateCamera(
        //   info != null
        //       ? CameraUpdate.newLatLngBounds(info!.bounds!, 100.0)
        //       : CameraUpdate.newCameraPosition(_initialCameraPosition),
        // ),
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }

  /// add Marker
  Future<void> _addMarker(LatLng pos) async {
    //&& destination != null
    if (origin == null || (origin != null)) {
      /// set origin
      setState(
        () {
          origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos,
          );

          ///Reset destination
          // destination = null;
          info = null;
        },
      );
    } else {
      setState(
        () {
          // destination = Marker(
          //   markerId: const MarkerId('destination'),
          //   infoWindow: const InfoWindow(title: 'destination'),
          //   icon:
          //       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          //   position: pos,
          // );

          ///Reset destination
        },
      );
      final directions = await DirectionsRepository()
          .getDirections(origin: origin?.position, destination: pos);
      setState(() => info = directions);
    }
  }
}
