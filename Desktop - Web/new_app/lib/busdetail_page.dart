import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_bus_page.dart';
import 'common_sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusDetailPage extends StatefulWidget {
  @override
  _BusDetailPageState createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  List<Map<String, dynamic>> buses = [];
  bool isLoading = true;
  bool isError = false;
  String? _token;

  String selectedShift = 'Shift 1';
  String selectedTime = 'Morning';
  List<Map<String, dynamic>> filteredBuses = [];
  bool isEditMode = false;

  Future<void> _getOrganizationToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      if (_token == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  Future<void> _fetchBusDetails() async {
    print("---------- FETCH ALL BUSES USING " +
        '${dotenv.env['BACKEND_API']}/get-all-bus');
    await _getOrganizationToken();
    print("Token: $_token");
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_API']}/get-all-bus'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'organization_id': _token,
        }),
      );
      print("Response: ${response.body}");
      if (response != null) {
        final List<dynamic> busList = json.decode(response.body);
        setState(() {
          buses = busList.map((bus) {
            return {
              'busNumber': bus['bus_number'],
              'busSeats': bus['bus_seats'],
              'busRoute': bus['bus_route'],
              'registrationPlate': bus['register_numberplate'],
              'status': bus['status'].toString(),
              'shift': bus['shift'],
              'time': bus['time'],
              'driver_name': bus['driver_name'] ?? 'N/A',
              'driver_phone': bus['driver_phone'] ?? 'N/A',
              'id': bus['id'].toString()
            };
          }).toList();
          isLoading = false;
          filterBuses();
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("This is the error: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBusDetails();
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
    List<Map<String, dynamic>> filtered = buses
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

  // void deleteBus(int index) {
  //   setState(() {
  //     print("-------- DELETE BUS ID: " +
  //         filteredBuses[index]['id'].toString() +
  //         " using " +
  //         '${dotenv.env['BACKEND_API']}/delete-bus');
  //     filteredBuses.removeAt(index);
  //   });
  // }

  void deleteBus(int index) async {
    final bus = filteredBuses[index];
    final String busId = bus['id'].toString();
    final String url = '${dotenv.env['BACKEND_API']}/delete-bus';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": busId,
          "organization_id": _token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          filteredBuses.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Bus deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to delete bus: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
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
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : isError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    'Failed to fetch bus details. Please try again. ' +
                                        isError.toString()),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _fetchBusDetails,
                                  child: Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03B0C1),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        // : buses.isEmpty
                        //     ? Center(child: Text('No buses available.'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.directions_bus),
                                  SizedBox(width: 8),
                                  Text(
                                    'Manage Buses',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final newBus = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddBusPage()),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                        label:
                                            Text(isEditMode ? 'Save' : 'Edit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF03B0C1),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                    items: <String>[
                                      'Morning',
                                      'Afternoon',
                                      'Evening'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
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
                                    items: <String>[
                                      'Shift 1',
                                      'Shift 2',
                                      'Shift 3'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
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
                                    DataColumn(
                                        label: Text('Registration Plate')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Action')),
                                  ],
                                  rows: List<DataRow>.generate(
                                    filteredBuses.length,
                                    (index) => DataRow(cells: [
                                      DataCell(
                                        isEditMode
                                            ? TextField(
                                                controller:
                                                    TextEditingController(
                                                        text:
                                                            filteredBuses[index]
                                                                ['busNumber']),
                                                onChanged: (value) {
                                                  setState(() {
                                                    filteredBuses[index]
                                                        ['busNumber'] = value;
                                                  });
                                                },
                                              )
                                            : Text(filteredBuses[index]
                                                ['busNumber']!),
                                      ),
                                      DataCell(
                                        isEditMode
                                            ? TextField(
                                                controller:
                                                    TextEditingController(
                                                        text:
                                                            filteredBuses[index]
                                                                ['busSeats']),
                                                onChanged: (value) {
                                                  setState(() {
                                                    filteredBuses[index]
                                                        ['busSeats'] = value;
                                                  });
                                                },
                                              )
                                            : Text(filteredBuses[index]
                                                ['busSeats']!),
                                      ),
                                      DataCell(
                                        isEditMode
                                            ? TextField(
                                                controller:
                                                    TextEditingController(
                                                        text:
                                                            filteredBuses[index]
                                                                ['busRoute']),
                                                onChanged: (value) {
                                                  setState(() {
                                                    filteredBuses[index]
                                                        ['busRoute'] = value;
                                                  });
                                                },
                                              )
                                            : Text(filteredBuses[index]
                                                ['busRoute']!),
                                      ),
                                      DataCell(
                                        isEditMode
                                            ? TextField(
                                                controller: TextEditingController(
                                                    text: filteredBuses[index]
                                                        ['registrationPlate']),
                                                onChanged: (value) {
                                                  setState(() {
                                                    filteredBuses[index][
                                                            'registrationPlate'] =
                                                        value;
                                                  });
                                                },
                                              )
                                            : Text(filteredBuses[index]
                                                ['registrationPlate']!),
                                      ),
                                      DataCell(
                                        isEditMode
                                            ? DropdownButton<String>(
                                                value: filteredBuses[index]
                                                    ['status'],
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    filteredBuses[index]
                                                        ['status'] = newValue!;
                                                  });
                                                },
                                                items: <String>[
                                                  'Activate',
                                                  'Deactivate'
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              )
                                            : Text(filteredBuses[index]
                                                ['status']!),
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
