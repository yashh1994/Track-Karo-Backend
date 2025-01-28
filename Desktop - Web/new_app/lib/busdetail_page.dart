import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_bus_page.dart';
import 'common_sidebar.dart';

class BusDetailPage extends StatefulWidget {
  @override
  _BusDetailPageState createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  final List<Map<String, String>> buses = [
    {
      'busNumber': 'ABC123',
      'busSeats': '50',
      'busRoute': 'Route A',
      'registrationPlate': 'XYZ-456',
      'status': 'Deactivate',
      'shift': 'Shift 1',
      'time': 'Morning'
    },
    {
      'busNumber': 'DEF456',
      'busSeats': '40',
      'busRoute': 'Route B',
      'registrationPlate': 'MNO-789',
      'status': 'Activate',
      'shift': 'Shift 2',
      'time': 'Afternoon'
    },
    {
      'busNumber': 'GHI789',
      'busSeats': '60',
      'busRoute': 'Route C',
      'registrationPlate': 'PQR-123',
      'status': 'Deactivate',
      'shift': 'Shift 3',
      'time': 'Evening'
    },
  ];

  String selectedShift = 'Shift 1';
  String selectedTime = 'Morning';
  List<Map<String, String>> filteredBuses = [];
  bool isEditMode = false;

  void _fetchBusDetails() {}

  @override
  void initState() {
    super.initState();
    filterBuses();
  }

  void filterBuses() {
    setState(() {
      filteredBuses = buses
          .where((bus) =>
              bus['shift'] == selectedShift && bus['time'] == selectedTime)
          .toList();
    });
  }

  void filterSearchResults(String query) {
    List<Map<String, String>> filtered = buses
        .where((bus) =>
            bus['shift'] == selectedShift && bus['time'] == selectedTime)
        .toList();
    if (query.isNotEmpty) {
      filtered = filtered.where((bus) {
        return bus.values
            .any((value) => value.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    setState(() {
      filteredBuses = filtered;
    });
  }

  void deleteBus(int index) {
    setState(() {
      filteredBuses.removeAt(index);
    });
  }

  // Save edited data
  void saveChanges() {
    setState(() {
      isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Trackkaro'),
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
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            CommonSidebar(
              isMobile: false,
              onNavigate: (index) {
                // Handle navigation based on the index
              },
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_bus),
                        SizedBox(width: 8),
                        Text(
                          'Manage Buses',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final newBus = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddBusPage()),
                                );
                                if (newBus != null) {
                                  setState(() {
                                    buses.add(newBus);
                                    filterBuses();
                                  });
                                }
                              },
                              icon: Icon(Icons.add),
                              label: Text('Add Bus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03B0C1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isEditMode = !isEditMode;
                                });
                              },
                              icon: Icon(Icons.edit),
                              label: Text(isEditMode ? 'Save' : 'Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03B0C1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: filterSearchResults,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedTime,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTime = newValue!;
                              filterBuses();
                            });
                          },
                          items: <String>['Morning', 'Afternoon', 'Evening']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedShift,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedShift = newValue!;
                              filterBuses();
                            });
                          },
                          items: <String>['Shift 1', 'Shift 2', 'Shift 3']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: DataTable(
                        columnSpacing: 20,
                        columns: [
                          DataColumn(label: Text('Bus Number')),
                          DataColumn(label: Text('Bus Seats')),
                          DataColumn(label: Text('Bus Route')),
                          DataColumn(label: Text('Registration Plate')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: List<DataRow>.generate(
                          filteredBuses.length,
                          (index) => DataRow(cells: [
                            DataCell(
                              isEditMode
                                  ? TextField(
                                      controller: TextEditingController(
                                          text: filteredBuses[index]
                                              ['busNumber']),
                                      onChanged: (value) {
                                        setState(() {
                                          filteredBuses[index]['busNumber'] =
                                              value;
                                        });
                                      },
                                    )
                                  : Text(filteredBuses[index]['busNumber']!),
                            ),
                            DataCell(
                              isEditMode
                                  ? TextField(
                                      controller: TextEditingController(
                                          text: filteredBuses[index]
                                              ['busSeats']),
                                      onChanged: (value) {
                                        setState(() {
                                          filteredBuses[index]['busSeats'] =
                                              value;
                                        });
                                      },
                                    )
                                  : Text(filteredBuses[index]['busSeats']!),
                            ),
                            DataCell(
                              isEditMode
                                  ? TextField(
                                      controller: TextEditingController(
                                          text: filteredBuses[index]
                                              ['busRoute']),
                                      onChanged: (value) {
                                        setState(() {
                                          filteredBuses[index]['busRoute'] =
                                              value;
                                        });
                                      },
                                    )
                                  : Text(filteredBuses[index]['busRoute']!),
                            ),
                            DataCell(
                              isEditMode
                                  ? TextField(
                                      controller: TextEditingController(
                                          text: filteredBuses[index]
                                              ['registrationPlate']),
                                      onChanged: (value) {
                                        setState(() {
                                          filteredBuses[index]
                                              ['registrationPlate'] = value;
                                        });
                                      },
                                    )
                                  : Text(filteredBuses[index]
                                      ['registrationPlate']!),
                            ),
                            DataCell(
                              isEditMode
                                  ? DropdownButton<String>(
                                      value: filteredBuses[index]['status'],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          filteredBuses[index]['status'] =
                                              newValue!;
                                        });
                                      },
                                      items: <String>['Activate', 'Deactivate']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    )
                                  : Text(filteredBuses[index]['status']!),
                            ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteBus(index),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
