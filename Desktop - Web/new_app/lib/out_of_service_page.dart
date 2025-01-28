import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OutOfServicePage extends StatefulWidget {
  @override
  _OutOfServicePageState createState() => _OutOfServicePageState();
}

class _OutOfServicePageState extends State<OutOfServicePage> {
  List<Map<String, String>> busDetails = [
    {
      'Bus Number': 'OUT001',
      'Bus Seats': '40',
      'Bus Route': 'Route X',
      'Driver Name': 'Driver 1',
      'Driver Phone': '987-654-3210',
      'Registration Plate': 'XYZ-123',
      'Status': 'Inactive',
    },
    {
      'Bus Number': 'OUT002',
      'Bus Seats': '45',
      'Bus Route': 'Route Y',
      'Driver Name': 'Driver 2',
      'Driver Phone': '123-456-7890',
      'Registration Plate': 'XYZ-456',
      'Status': 'Inactive',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredBusDetails = busDetails.where((bus) {
      return bus.values.any((value) =>
          value.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Out of Service Details'),
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
                  'Out of Service Buses',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _showAddDialog,
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
                      DataCell(Text(busDetail['Bus Number']!)),
                      DataCell(Text(busDetail['Bus Seats']!)),
                      DataCell(Text(busDetail['Bus Route']!)),
                      DataCell(Text(busDetail['Driver Name']!)),
                      DataCell(Text(busDetail['Driver Phone']!)),
                      DataCell(Text(busDetail['Registration Plate']!)),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              busDetail['Status'] =
                              busDetail['Status'] == 'Inactive'
                                  ? 'Active'
                                  : 'Inactive';
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
                      DataCell(
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

  void _showAddDialog() {
    Map<String, String> newBusDetail = {
      'Bus Number': '',
      'Bus Seats': '',
      'Bus Route': '',
      'Driver Name': '',
      'Driver Phone': '',
      'Registration Plate': '',
      'Status': 'Inactive',
    };

    _showEditDialog(newBusDetail, isAdding: true);
  }

  void _showEditDialog(Map<String, String> busDetail, {bool isAdding = false}) {
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
          title: Text(isAdding ? 'Add Bus' : 'Edit Bus Details'),
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

                  if (isAdding) busDetails.add(busDetail);
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
    const googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=37.7749,-122.4194";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
