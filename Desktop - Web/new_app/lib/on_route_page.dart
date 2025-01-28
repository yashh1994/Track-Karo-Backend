import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OnRoutePage extends StatefulWidget {
  @override
  _OnRoutePageState createState() => _OnRoutePageState();
}

class _OnRoutePageState extends State<OnRoutePage> {
  List<Map<String, dynamic>> Route = [];
  bool isLoading = true;
  bool isError = false;
  String? _token;

  List<Map<String, String>> busDetails = [
    {
      'Bus Number': 'ABC123',
      'Bus Seats': '50',
      'Bus Route': 'Route A',
      'Driver Name': 'John Doe',
      'Driver Phone': '123-456-7890',
      'Registration Plate': 'XYZ-456',
      'Status': 'Active',
    },
    {
      'Bus Number': 'DEF456',
      'Bus Seats': '40',
      'Bus Route': 'Route B',
      'Driver Name': 'Jane Smith',
      'Driver Phone': '098-765-4321',
      'Registration Plate': 'XYZ-789',
      'Status': 'Active',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    print("Building OnRoutePage");
    List<Map<String, String>> filteredBusDetails = busDetails.where((bus) {
      return bus.values.any(
          (value) => value.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('OnRoute Buses'),
        backgroundColor: Color(0xFF03B0C1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF03B0C1), size: 30),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OnRoute Buses',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddBusDialog();
                  },
                  child: Text(
                    'Add Bus',
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
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Bus Number')),
                    DataColumn(label: Text('Bus Seats')),
                    DataColumn(label: Text('Bus Route')),
                    DataColumn(label: Text('Driver Name')),
                    DataColumn(label: Text('Driver Phone')),
                    DataColumn(label: Text('Registration Plate')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: filteredBusDetails.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, String> busDetail = entry.value;
                    return DataRow(cells: [
                      _buildTextCell(busDetail['Bus Number']!),
                      _buildTextCell(busDetail['Bus Seats']!),
                      _buildTextCell(busDetail['Bus Route']!),
                      _buildTextCell(busDetail['Driver Name']!),
                      _buildTextCell(busDetail['Driver Phone']!),
                      _buildTextCell(busDetail['Registration Plate']!),
                      _buildWidgetCell(
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              busDetail['Status'] =
                                  busDetail['Status'] == 'Active'
                                      ? 'Deactivate'
                                      : 'Active';
                            });
                          },
                          child: Text(busDetail['Status']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF03B0C1),
                            side: BorderSide(color: Color(0xFF03B0C1)),
                          ),
                        ),
                      ),
                      _buildWidgetCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Color(0xFF03B0C1),
                              onPressed: () {
                                _showEditDialog(busDetail);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.location_on),
                              color: Color(0xFF03B0C1),
                              onPressed: () {
                                _launchMaps(busDetail['Bus Route']!);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Color(0xFF03B0C1),
                              onPressed: () {
                                setState(() {
                                  busDetails.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBusDialog() {
    TextEditingController busNumberController = TextEditingController();
    TextEditingController busSeatsController = TextEditingController();
    TextEditingController busRouteController = TextEditingController();
    TextEditingController driverNameController = TextEditingController();
    TextEditingController driverPhoneController = TextEditingController();
    TextEditingController registrationPlateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Bus'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: busNumberController,
                  decoration: InputDecoration(labelText: 'Bus Number'),
                ),
                TextField(
                  controller: busSeatsController,
                  decoration: InputDecoration(labelText: 'Bus Seats'),
                ),
                TextField(
                  controller: busRouteController,
                  decoration: InputDecoration(labelText: 'Bus Route'),
                ),
                TextField(
                  controller: driverNameController,
                  decoration: InputDecoration(labelText: 'Driver Name'),
                ),
                TextField(
                  controller: driverPhoneController,
                  decoration: InputDecoration(labelText: 'Driver Phone'),
                ),
                TextField(
                  controller: registrationPlateController,
                  decoration: InputDecoration(labelText: 'Registration Plate'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  busDetails.add({
                    'Bus Number': busNumberController.text,
                    'Bus Seats': busSeatsController.text,
                    'Bus Route': busRouteController.text,
                    'Driver Name': driverNameController.text,
                    'Driver Phone': driverPhoneController.text,
                    'Registration Plate': registrationPlateController.text,
                    'Status': 'Active',
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  DataCell _buildTextCell(String content) {
    return DataCell(Text(content));
  }

  DataCell _buildWidgetCell(Widget content) {
    return DataCell(content);
  }

  void _showEditDialog(Map<String, String> busDetail) {
    TextEditingController busNumberController =
        TextEditingController(text: busDetail['Bus Number']);
    TextEditingController busSeatsController =
        TextEditingController(text: busDetail['Bus Seats']);
    TextEditingController busRouteController =
        TextEditingController(text: busDetail['Bus Route']);
    TextEditingController driverNameController =
        TextEditingController(text: busDetail['Driver Name']);
    TextEditingController driverPhoneController =
        TextEditingController(text: busDetail['Driver Phone']);
    TextEditingController registrationPlateController =
        TextEditingController(text: busDetail['Registration Plate']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Bus Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: busNumberController,
                  decoration: InputDecoration(labelText: 'Bus Number'),
                ),
                TextField(
                  controller: busSeatsController,
                  decoration: InputDecoration(labelText: 'Bus Seats'),
                ),
                TextField(
                  controller: busRouteController,
                  decoration: InputDecoration(labelText: 'Bus Route'),
                ),
                TextField(
                  controller: driverNameController,
                  decoration: InputDecoration(labelText: 'Driver Name'),
                ),
                TextField(
                  controller: driverPhoneController,
                  decoration: InputDecoration(labelText: 'Driver Phone'),
                ),
                TextField(
                  controller: registrationPlateController,
                  decoration: InputDecoration(labelText: 'Registration Plate'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  busDetail['Bus Number'] = busNumberController.text;
                  busDetail['Bus Seats'] = busSeatsController.text;
                  busDetail['Bus Route'] = busRouteController.text;
                  busDetail['Driver Name'] = driverNameController.text;
                  busDetail['Driver Phone'] = driverPhoneController.text;
                  busDetail['Registration Plate'] =
                      registrationPlateController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _launchMaps(String busRoute) async {
    const String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=37.7749,-122.4194";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
