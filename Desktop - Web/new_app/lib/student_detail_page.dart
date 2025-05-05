import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:new_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_student_page.dart';
import 'common_sidebar.dart';
import 'home_page.dart';
import 'busdetail_page.dart';
import 'update_details_page.dart';
import 'manage_driver_page.dart';
import 'live_tracking_page.dart';

class StudentDetailPage extends StatefulWidget {
  @override
  _StudentDetailPageState createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  bool isError = false;
  String? _token;

  // List<Map<String, String>> students = [
  //   {
  //     'Enrollment No.': 'E123',
  //     'Name': 'John Doe',
  //     'Phone Number': '123-456-7890',
  //     'Bus Number': 'ABC123',
  //     'Address': '123 Main St',
  //     'Route': 'Route A',
  //     'Bus Fees Paid': 'Yes',
  //     'Class': '10',
  //     'Email Address': 'john.doe@example.com',
  //     'Status': 'Active'
  //   },
  //   {
  //     'Enrollment No.': 'E124',
  //     'Name': 'Jane Smith',
  //     'Phone Number': '987-654-3210',
  //     'Bus Number': 'DEF456',
  //     'Address': '456 Elm St',
  //     'Route': 'Route B',
  //     'Bus Fees Paid': 'No',
  //     'Class': '9',
  //     'Email Address': 'jane.smith@example.com',
  //     'Status': 'Inactive'
  //   },
  // ];

  List<Map<String, dynamic>> filteredStudents = [];
  bool isEditing = false;

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

  Future<void> _fetchStudentDetails() async {
    await _getOrganizationToken();
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_API']}/get-all-students'),
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
          students = routeList.map((bus) {
            return {
              'Enrollment No.': bus['enrollment_number'] ?? 'N/A',
              'Name': bus['student_name'] ?? 'N/A',
              'Phone Number': bus['student_phone'] ?? 'N/A',
              'Bus Number': bus['bus_number'] ?? 'N/A',
              'Address': bus['student_address'] ?? 'N/A',
              'Route': bus['route'] ?? 'N/A',
              'Bus Fees Paid': bus['busfee'] ?? 'N/A',
              'Class': bus['student_class'] ?? 'N/A',
              'Email Address': bus['email'] ?? 'N/A',
              'Status': bus['status'].toString() ?? 'N/A',
              'id': bus['id'].toString()
            };
          }).toList();
          isLoading = false;
          filteredStudents = List.from(students);
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
    _fetchStudentDetails();
  }

  void _filterStudents(String query) {
    List<Map<String, dynamic>> filtered = students.where((student) {
      return student.values
          .any((value) => value.toLowerCase().contains(query.toLowerCase()));
    }).toList();
    setState(() {
      filteredStudents = filtered;
    });
  }

  Future<void> _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddStudentPage()),
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        students.add(result);
        filteredStudents = List.from(students);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student successfully added!')),
      );
    }
  }

  // void _deleteStudent(int index) {
  //   setState(() {
  //     filteredStudents.removeAt(index);
  //   });
  // }

  void _deleteStudent(int index) async {
    final student = filteredStudents[index];
    final String studentId = student['id'].toString();
    final String url = '${dotenv.env['BACKEND_API']}/delete-student';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": studentId,
          "organization_id": _token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          filteredStudents.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Student deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Failed to delete Student: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  void _toggleStatus(int index) {
    setState(() {
      filteredStudents[index]['Status'] =
          filteredStudents[index]['Status'] == 'Active' ? 'Inactive' : 'Active';
    });
  }

  void _openLocation(String address) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Widget _buildEditableField(String initialValue, Function(String) onChanged) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03B0C1),
        elevation: 0,
        title: Text('TrackKaro'),
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
              CommonSidebar(
                isMobile: isMobile,
                onNavigate: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                      break;
                    case 1:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusDetailPage()),
                      );
                      break;
                    case 2:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManageDriverPage()),
                      );
                      break;
                    case 3:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LiveTrackingPage()),
                      );
                      break;
                    case 4:
                      break;
                    case 5:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateDetailsPage()),
                      );
                      break;
                    default:
                      break;
                  }
                },
              ),
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
                                        'Failed to fetch Student details. Please try again.'),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _fetchStudentDetails,
                                      child: Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF03B0C1),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.school, size: 24),
                                          SizedBox(width: 10),
                                          Text(
                                            'Manage Student',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _addStudent,
                                            icon: Icon(Icons.add,
                                                color: Colors.white),
                                            label: Text(
                                              'Add Students',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF03B0C1),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 15),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton.icon(
                                            onPressed: _toggleEdit,
                                            icon: Icon(Icons.edit,
                                                color: Colors
                                                    .white), // Edit icon added
                                            label: Text(
                                              isEditing
                                                  ? "Save Changes"
                                                  : "Edit Students",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF03B0C1),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 15),
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
                                    onChanged: _filterStudents,
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 20,
                                        columns: [
                                          DataColumn(
                                              label: Text('Enrollment No.')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(
                                              label: Text('Phone Number')),
                                          DataColumn(label: Text('Bus Number')),
                                          DataColumn(label: Text('Address')),
                                          DataColumn(label: Text('Route')),
                                          DataColumn(
                                              label: Text('Bus Fees Paid')),
                                          DataColumn(label: Text('Class')),
                                          DataColumn(
                                              label: Text('Email Address')),
                                          DataColumn(label: Text('Status')),
                                          DataColumn(label: Text('Action')),
                                        ],
                                        rows: filteredStudents.map((student) {
                                          int index =
                                              filteredStudents.indexOf(student);
                                          return DataRow(cells: [
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Enrollment No.']!,
                                                    (value) => student[
                                                            'Enrollment No.'] =
                                                        value)
                                                : Text(student[
                                                    'Enrollment No.']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Name']!,
                                                    (value) =>
                                                        student['Name'] = value)
                                                : Text(student['Name']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Phone Number']!,
                                                    (value) => student[
                                                        'Phone Number'] = value)
                                                : Text(
                                                    student['Phone Number']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Bus Number']!,
                                                    (value) =>
                                                        student['Bus Number'] =
                                                            value)
                                                : Text(student['Bus Number']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Address']!,
                                                    (value) =>
                                                        student['Address'] =
                                                            value)
                                                : Text(student['Address']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Route']!,
                                                    (value) =>
                                                        student['Route'] =
                                                            value)
                                                : Text(student['Route']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Bus Fees Paid']!,
                                                    (value) => student[
                                                            'Bus Fees Paid'] =
                                                        value)
                                                : Text(
                                                    student['Bus Fees Paid']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Class']!,
                                                    (value) =>
                                                        student['Class'] =
                                                            value)
                                                : Text(student['Class']!)),
                                            DataCell(isEditing
                                                ? _buildEditableField(
                                                    student['Email Address']!,
                                                    (value) => student[
                                                            'Email Address'] =
                                                        value)
                                                : Text(
                                                    student['Email Address']!)),
                                            DataCell(
                                              isEditing
                                                  ? DropdownButton<String>(
                                                      value: student['Status'],
                                                      items: [
                                                        'Active',
                                                        'Inactive'
                                                      ]
                                                          .map((status) =>
                                                              DropdownMenuItem(
                                                                value: status,
                                                                child: Text(
                                                                    status),
                                                              ))
                                                          .toList(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          student['Status'] =
                                                              newValue!;
                                                        });
                                                      },
                                                    )
                                                  : Text(student['Status']!),
                                            ),
                                            DataCell(
                                              isEditing
                                                  ? IconButton(
                                                      icon: Icon(Icons.save),
                                                      onPressed: () {
                                                        setState(() {
                                                          isEditing = false;
                                                        });
                                                      },
                                                    )
                                                  : IconButton(
                                                      icon: Icon(Icons.delete),
                                                      onPressed: () =>
                                                          _deleteStudent(index),
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
