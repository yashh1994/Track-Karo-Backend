import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRoutePage extends StatefulWidget {
  @override
  _AddRoutePageState createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final TextEditingController _routeNumberController = TextEditingController();
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _busController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickLocation(TextEditingController controller) async {
    // Get current position
    Position position = await _determinePosition();

    // Launch Google Maps
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }

    // Wait for user to select a location and update the text field
    await Future.delayed(Duration(seconds: 10)); // Adjust delay as needed
    Position newPosition = await _determinePosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        newPosition.latitude, newPosition.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String address =
          "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      setState(() {
        controller.text = address;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _addRoute() async {
    final url = Uri.parse(
        '${dotenv.env['BACKEND_API']}/add-route'); // Replace with actual IP and port
    final body = {
      "route_number": _routeNumberController.text,
      "route_name": _routeNameController.text,
      "source": _sourceController.text,
      "destination": _destinationController.text,
      "stops": _stopControllers
          .map((c) => c.text)
          .where((s) => s.isNotEmpty)
          .toList(),
      "organization_id": "1", // Update if this should be dynamic
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route added successfully!')),
        );
        Navigator.pop(context); // Go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add route: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _addStop() {
    setState(() {
      _stopControllers.add(TextEditingController());
    });
  }

  void _submitRoute() {
    // Validate if all required fields are filled
    List<String> emptyFields = [];

    if (_routeNumberController.text.isEmpty) {
      emptyFields.add('Route Number');
    }
    if (_routeNameController.text.isEmpty) {
      emptyFields.add('Route Name');
    }
    if (_busController.text.isEmpty) {
      // emptyFields.add('Bus Number');
    }
    if (_sourceController.text.isEmpty) {
      emptyFields.add('Source');
    }
    if (_destinationController.text.isEmpty) {
      emptyFields.add('Destination');
    }

    if (emptyFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Error'),
          content:
              Text('The following fields are empty: ${emptyFields.join(', ')}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Prepare the route data to send back to the previous screen
    Map<String, dynamic> newRoute = {
      'routeNumber': _routeNumberController.text,
      'routeName': _routeNameController.text,
      'busNumber': _busController.text,
      'source': _sourceController.text,
      'destination': _destinationController.text,
    };

    // Add stops if any
    List<String> stops = [];
    for (TextEditingController controller in _stopControllers) {
      if (controller.text.isNotEmpty) {
        stops.add(controller.text);
      }
    }
    if (stops.isNotEmpty) {
      newRoute['stops'] = stops;
    }

    // Navigate back to the previous screen with the route data
    Navigator.pop(context, newRoute);
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Color(0xFF03B0C1)),
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF03B0C1)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${labelText.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationField(
      TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: Icon(Icons.map, color: Color(0xFF03B0C1)),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF03B0C1)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${labelText.toLowerCase()}';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: Color(0xFF03B0C1)),
            onPressed: () => _pickLocation(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildStopField(TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(controller, 'Stop', Icons.location_on),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _stopControllers.remove(controller);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Route"),
        backgroundColor: Color(0xFF03B0C1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(children: [
                      _buildTextField(_routeNumberController, 'Route No.',
                          Icons.format_list_numbered),
                      _buildTextField(
                          _routeNameController, 'Route Name', Icons.drive_eta),
                    ]),
                    // TableRow(children: [
                    //   _buildTextField(_busController, 'Bus', Icons.directions_bus),
                    //   SizedBox(), // Empty cell for alignment
                    // ]),
                    TableRow(children: [
                      _buildLocationField(_sourceController, 'Source'),
                      _buildLocationField(
                          _destinationController, 'Destination'),
                    ]),
                    ..._stopControllers.map((controller) {
                      return TableRow(children: [
                        _buildStopField(controller),
                        SizedBox(), // Empty cell for alignment
                      ]);
                    }).toList(),
                    TableRow(children: [
                      SizedBox(), // Empty cell for alignment
                      SizedBox(), // Empty cell for alignment
                    ]),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addStop,
                  child: Text(
                    'Add Stop',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03B0C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitRoute();
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03B0C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03B0C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
