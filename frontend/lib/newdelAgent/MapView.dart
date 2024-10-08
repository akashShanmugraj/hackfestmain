import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/newdelAgent/homePageDel.dart';
import 'package:frontend/utilities/apiFunctions.dart';
import 'package:frontend/utilities/integrationFunctions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class MapView extends StatefulWidget {
  final int pathIndex;

  const MapView({
    super.key,
    required this.pathIndex,
  });

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<List<RouteStep>> _pathStepsFuture;
  late List<bool> _completedStatus;
  bool _acceptPressed = false;

  @override
  void initState() {
    super.initState();
    // Load path steps when the widget is initialized
    _pathStepsFuture = viewSpecificPath(widget.pathIndex.toString());
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.025155757439432, 77.00250346910578),
    zoom: 10.4746,
  );

  PolylinePoints polylinePoints = PolylinePoints();
  final List<Polyline> polyline = [];
  List<LatLng> routeCoords = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Map View',
          style: TextStyle(
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<RouteStep>>(
        future: _pathStepsFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<RouteStep>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<RouteStep> pathSteps = snapshot.data!;
            _completedStatus = List<bool>.filled(pathSteps.length, false);

            return Column(
              children: [
                // Map Container
                FutureBuilder<Set<Marker>>(
                  future: setMarkers(widget.pathIndex),
                  builder: (context, markerSnapshot) {
                    return FutureBuilder<Set<Polyline>>(
                      future: setPolylines(widget.pathIndex),
                      builder: (context, polylineSnapshot) {
                        if (markerSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            polylineSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (markerSnapshot.hasError ||
                            polylineSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${markerSnapshot.error}'));
                        } else if (!markerSnapshot.hasData ||
                            !polylineSnapshot.hasData) {
                          return const Center(child: Text('No data available'));
                        }

                        return SizedBox(
                          height: 200,
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: _kGooglePlex,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: markerSnapshot.data ?? {},
                            polylines: polylineSnapshot.data ?? {},
                          ),
                        );
                      },
                    );
                  },
                ),
                // Routes List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: pathSteps.length,
                      itemBuilder: (context, index) {
                        RouteStep currentStep = pathSteps[index];
                        bool isCompleted = _completedStatus[index];

                        return Container(
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStep.Location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentStep.resources,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!_acceptPressed)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Show Snackbar for confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Do you want to confirm the path?'),
                            action: SnackBarAction(
                              label: 'Confirm',
                              onPressed: () async {
                                // Call the acceptPath function and proceed if confirmed
                                bool accepted =
                                    await acceptPath(widget.pathIndex);
                                if (accepted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => homePageDel(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Failed to accept path')),
                                  );
                                }
                              },
                            ),
                            duration:
                                const Duration(seconds: 5), // Snackbar timeout
                            behavior: SnackBarBehavior
                                .floating, // Floating style for Snackbar
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        shape: const ContinuousRectangleBorder(),
                        minimumSize: const Size(450, 25),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

Completer<AndroidMapRenderer?>? _initializedRendererCompleter;

Future<AndroidMapRenderer?> initializeMapRenderer() async {
  if (_initializedRendererCompleter != null) {
    return _initializedRendererCompleter!.future;
  }

  final Completer<AndroidMapRenderer?> completer =
      Completer<AndroidMapRenderer?>();
  _initializedRendererCompleter = completer;

  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform platform = GoogleMapsFlutterPlatform.instance;
  unawaited((platform as GoogleMapsFlutterAndroid)
      .initializeWithRenderer(AndroidMapRenderer.latest)
      .then((AndroidMapRenderer initializedRenderer) =>
          completer.complete(initializedRenderer)));

  return completer.future;
}
