import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_driver_page.dart'; // Import the AddDriverPage
import 'common_sidebar.dart'; // Import the common sidebar
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageDriverPage extends StatefulWidget {
  @override
  _ManageDriverPageState createState() => _ManageDriverPageState();
}

class _ManageDriverPageState extends State<ManageDriverPage> {
  // List<Map<String, dynamic>> drivers = [
  //   {
  //     'name': 'John Doe',
  //     'phone': '123-456-7890',
  //     'address': '123 Main St, City',
  //     'route': 'Route A',
  //     'busNumber': 'ABC123',
  //     'salary': '5000',
  //     'status': 'Active',
  //   },
  //   {
  //     'name': 'Jane Smith',
  //     'phone': '987-654-3210',
  //     'address': '456 Elm St, Town',
  //     'route': 'Route B',
  //     'busNumber': 'DEF456',
  //     'salary': '5500',
  //     'status': 'Inactive',
  //   },
  //   {
  //     'name': 'Michael Brown',
  //     'phone': '111-222-3333',
  //     'address': '789 Oak St, Village',
  //     'route': 'Route C',
  //     'busNumber': 'GHI789',
  //     'salary': '5200',
  //     'status': 'Active',
  //   },
  // ];

  List<Map<String, dynamic>> drivers = [];
  bool isLoading = true;
  bool isError = false;
  String? _token;

  List<Map<String, dynamic>> filteredDrivers = [];
  TextEditingController _searchController = TextEditingController();
  bool isEditing = false; // To toggle between edit and save state

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

  Future<void> _fetchDriverDetails() async {
    await _getOrganizationToken();
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_API']}/get-all-drivers'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'organization_id': _token,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> busList = json.decode(response.body);
        setState(() {
          drivers = busList.map((bus) {
            return {
              'name': bus['driver_name'] ?? 'N/A',
              'phone': bus['driver_phone'] ?? 'N/A',
              'address': bus['driver_address'] ?? 'N/A',
              'route': bus['driver_route'],
              'busNumber': bus['driver_busnumber'],
              'salary': bus['driver_salary'] ?? 'N/A',
              'status': bus['status'].toString(),
              'id': bus['id'].toString(),
              "driver_photo": "ohoto.jpg"
            };
          }).toList();
          isLoading = false;
          filteredDrivers = List.from(drivers);
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
    _fetchDriverDetails();
  }

  void _filterDrivers(String query) {
    List<Map<String, dynamic>> filtered = drivers.where((driver) {
      return driver.values.any((value) =>
          value.toString().toLowerCase().contains(query.toLowerCase()));
    }).toList();
    setState(() {
      filteredDrivers = filtered;
    });
  }

  // void _deleteDriver(int index) {
  //   setState(() {
  //     filteredDrivers.removeAt(index);
  //   });
  // }

  void _deleteDriver(int index) async {
    final driver = filteredDrivers[index];
    final String driverId = driver['id'].toString();
    final url = Uri.parse('${dotenv.env['BACKEND_API']}/delete-driver');

    print("------- DELTE DRIVER WITH ------ " + " ID " + driverId);
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': driverId,
          "organization_id": _token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          filteredDrivers.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Driver deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete driver')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting driver')),
      );
    }
  }

  void _toggleStatus(int index) {
    setState(() {
      if (filteredDrivers[index]['status'] == 'Active') {
        filteredDrivers[index]['status'] = 'Inactive';
      } else {
        filteredDrivers[index]['status'] = 'Active';
      }
    });
  }

  void _addDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDriverPage()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        drivers.add(result);
        filteredDrivers = List.from(drivers);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver successfully added!')),
      );
    }
  }

  void _editDrivers() {
    setState(() {
      isEditing = !isEditing; // Toggle edit/save mode
    });
  }

  void _saveChanges() {
    setState(() {
      // Logic to save changes if needed (e.g., updating the main list)
      isEditing = false; // Exit editing mode
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changes saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03B0C1),
        elevation: 0,
        title: Text('Trackkaro'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return Row(
            children: [
              // CommonSidebar Widget
              CommonSidebar(
                isMobile: isMobile,
                onNavigate: (index) {
                  // Implement navigation logic based on index
                },
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : isError
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        'Failed to fetch Drivers details. Please try again.'),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _fetchDriverDetails,
                                      child: Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF03B0C1),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // : drivers.isEmpty
                            //     ? Center(child: Text('No Drivers available.'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 24),
                                          SizedBox(width: 10),
                                          Text(
                                            'Manage Drivers',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF03B0C1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: _addDriver,
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              label: Text('Add Driver',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF03B0C1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: isEditing
                                                  ? _saveChanges
                                                  : _editDrivers,
                                              icon: Icon(
                                                  isEditing
                                                      ? Icons.edit
                                                      : Icons.edit,
                                                  color: Colors.white),
                                              label: Text(
                                                  isEditing ? 'Save ' : 'Edit ',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(height: 20, thickness: 1),
                                  TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                    ),
                                    onChanged: (value) {
                                      _filterDrivers(value);
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 20,
                                        columns: [
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Phone')),
                                          DataColumn(label: Text('Address')),
                                          DataColumn(label: Text('Route')),
                                          DataColumn(label: Text('Bus Number')),
                                          DataColumn(label: Text('Salary')),
                                          DataColumn(label: Text('Status')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: filteredDrivers.map((driver) {
                                          int driverIndex =
                                              filteredDrivers.indexOf(driver);
                                          return DataRow(cells: [
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'name']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                driverIndex]
                                                            ['name'] = value;
                                                      },
                                                    )
                                                  : Text(driver['name']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'phone']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                driverIndex]
                                                            ['phone'] = value;
                                                      },
                                                    )
                                                  : Text(driver['phone']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'address']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                driverIndex]
                                                            ['address'] = value;
                                                      },
                                                    )
                                                  : Text(driver['address']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'route']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                driverIndex]
                                                            ['route'] = value;
                                                      },
                                                    )
                                                  : Text(driver['route']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'busNumber']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                    driverIndex]
                                                                ['busNumber'] =
                                                            value;
                                                      },
                                                    )
                                                  : Text(driver['busNumber']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text: driver[
                                                                  'salary']),
                                                      onChanged: (value) {
                                                        filteredDrivers[
                                                                driverIndex]
                                                            ['salary'] = value;
                                                      },
                                                    )
                                                  : Text(driver['salary']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? DropdownButton<String>(
                                                      value: driver['status'],
                                                      items: <String>[
                                                        'Active',
                                                        'Inactive'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          filteredDrivers[
                                                                  driverIndex][
                                                              'status'] = value!;
                                                        });
                                                      },
                                                    )
                                                  : Text(driver['status']),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () =>
                                                        _deleteDriver(
                                                            driverIndex),
                                                  ),
                                                  // IconButton(
                                                  //   icon: Icon(Icons.refresh),
                                                  //   onPressed: () => _toggleStatus(driverIndex),
                                                  // ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
