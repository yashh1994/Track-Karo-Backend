import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_route_page.dart'; // Import the AddRoutePage
import 'common_sidebar.dart'; // Import the common sidebar
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveTrackingPage extends StatefulWidget {
  @override
  _LiveTrackingPageState createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  List<Map<String, dynamic>> routes = [];
  bool isLoading = true;
  bool isError = false;
  String? _token;

  // final List<Map<String, dynamic>> routes = [
  //   {
  //     'routeNumber': 'Route A',
  //     'routeName': 'Downtown Loop',
  //     'source': 'Main St Station',
  //     'destination': 'Central Park',
  //     'busNumber': 'ABC123',
  //   },
  //   {
  //     'routeNumber': 'Route B',
  //     'routeName': 'Uptown Express',
  //     'source': 'Elm St Station',
  //     'destination': 'Museum Square',
  //     'busNumber': 'DEF456',
  //   },
  //   {
  //     'routeNumber': 'Route C',
  //     'routeName': 'Suburban Connector',
  //     'source': 'Oak St Station',
  //     'destination': 'Town Center',
  //     'busNumber': 'GHI789',
  //   },
  // ];

  List<Map<String, dynamic>> filteredRoutes = [];
  final TextEditingController _searchController = TextEditingController();
  bool isEditing = false; // Track edit mode

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

  Future<void> _fetchRoutes() async {
    await _getOrganizationToken();
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_API']}/get-all-routes'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'organization_id': _token,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> routeList = json.decode(response.body);
        setState(() {
          routes = routeList.map((bus) {
            return {
              'routeNumber': bus['route_number'],
              'routeName': bus['route_name'],
              'source': bus['source'],
              'destination': bus['destination'],
              'busNumber': bus['busNumber'] ?? 'N/A',
              'stops': bus['stops'],
              'id': bus['id'].toString(),
            };
          }).toList();
          isLoading = false;
          filteredRoutes = List.from(routes);
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
    _fetchRoutes();
  }

  void _filterRoutes(String query) {
    List<Map<String, dynamic>> filtered = routes.where((route) {
      return route['routeNumber'].toLowerCase().contains(query.toLowerCase()) ||
          route['routeName'].toLowerCase().contains(query.toLowerCase()) ||
          route['source'].toLowerCase().contains(query.toLowerCase()) ||
          route['destination'].toLowerCase().contains(query.toLowerCase()) ||
          route['busNumber'].toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredRoutes = filtered;
    });
  }

  // void _deleteRoute(int index) {
  //   setState(() {
  //     filteredRoutes.removeAt(index);
  //   });
  // }

  void deleteRoute(int index) async {
    final route = filteredRoutes[index];
    final String routeId = route['id'].toString();
    final String url = '${dotenv.env['BACKEND_API']}/delete-route';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": routeId,
          "organization_id": _token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          filteredRoutes.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Route deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to delete Route: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _addRoute() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRoutePage()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        routes.add(result);
        filteredRoutes = List.from(routes);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route successfully added!')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing; // Toggle edit mode
    });
  }

  void _saveChanges() {
    // You can add any save logic here if needed
    setState(() {
      isEditing = false; // Exit edit mode
    });
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
                  print('Navigating to page $index');
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
                                        'Failed to fetch bus details. Please try again.'),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _fetchRoutes,
                                      child: Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF03B0C1),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // : routes.isEmpty
                            //     ? Center(child: Text('No buses available.'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.map, size: 24),
                                          SizedBox(width: 10),
                                          Text(
                                            'Set Route',
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
                                              onPressed: _addRoute,
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              label: Text('Add Route',
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
                                          SizedBox(
                                              width:
                                                  10), // Space between buttons
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
                                                  : _toggleEdit,
                                              icon: Icon(
                                                  isEditing
                                                      ? Icons.edit
                                                      : Icons.edit,
                                                  color: Colors.white),
                                              label: Text(
                                                  isEditing ? 'Save' : 'Edit',
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
                                    onChanged: _filterRoutes,
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 20,
                                        columns: [
                                          DataColumn(
                                              label: Text('Route Number')),
                                          DataColumn(label: Text('Route Name')),
                                          DataColumn(label: Text('Source')),
                                          DataColumn(
                                              label: Text('Destination')),
                                          DataColumn(label: Text('Bus Number')),
                                          DataColumn(
                                              label: Text(
                                                  'Action')), // Action column
                                        ],
                                        rows: filteredRoutes.map((route) {
                                          int index =
                                              filteredRoutes.indexOf(route);
                                          return DataRow(cells: [
                                            DataCell(
                                              isEditing
                                                  ? TextFormField(
                                                      initialValue:
                                                          route['routeNumber'],
                                                      onChanged: (value) =>
                                                          route['routeNumber'] =
                                                              value,
                                                    )
                                                  : Text(route['routeNumber']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextFormField(
                                                      initialValue:
                                                          route['routeName'],
                                                      onChanged: (value) =>
                                                          route['routeName'] =
                                                              value,
                                                    )
                                                  : Text(route['routeName']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextFormField(
                                                      initialValue:
                                                          route['source'],
                                                      onChanged: (value) =>
                                                          route['source'] =
                                                              value,
                                                    )
                                                  : Text(route['source']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextFormField(
                                                      initialValue:
                                                          route['destination'],
                                                      onChanged: (value) =>
                                                          route['destination'] =
                                                              value,
                                                    )
                                                  : Text(route['destination']),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? TextFormField(
                                                      initialValue:
                                                          route['busNumber'],
                                                      onChanged: (value) =>
                                                          route['busNumber'] =
                                                              value,
                                                    )
                                                  : Text(route['busNumber']),
                                            ),
                                            DataCell(
                                              IconButton(
                                                onPressed: () {
                                                  deleteRoute(
                                                      index); // Delete row
                                                },
                                                icon: Icon(Icons.delete),
                                                style:
                                                    ElevatedButton.styleFrom(),
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

void main() {
  runApp(MaterialApp(
    home: LiveTrackingPage(),
  ));
}
