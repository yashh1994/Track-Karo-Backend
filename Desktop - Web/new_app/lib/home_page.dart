import 'package:flutter/material.dart';
import 'package:new_app/manage_driver_page.dart';
import 'package:new_app/on_route_page.dart';
import 'package:new_app/out_of_service_page.dart';
import 'package:new_app/standby_page.dart';
import 'package:new_app/live_tracking_page.dart'; // Import LiveTrackingPage
import 'package:new_app/update_details_page.dart'; // Import UpdateDetailsPage
import 'busdetail_page.dart';
import 'student_detail_page.dart';
import 'custom_clickable_pie_chart.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      'On Route': 30,
      'Standby': 20,
      'Out of Service': 10,
    };

    List<Color> colorList = [
      Colors.green,
      Colors.orange,
      Colors.blue,
    ];

    Color sideBarColor = Colors.black; // Set sidebar background color to black
    Color appBarColor = Color(0xFF03B0C1); // App bar color

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: UserDetailsDrawer(),
      body: Row(
        children: [
          Container(
            width: 300,
            color: sideBarColor, // Set sidebar background color
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/images/logo23.png',
                    height: 100,
                  ),
                ),

                SizedBox(height: 20),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BusDetailPage()),
                    );
                  },
                  icon: Icons.directions_bus,
                  label: 'Manage Buses',
                ),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageDriverPage()),
                    );
                  },
                  icon: Icons.person,
                  label: 'Manage Drivers',
                ),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LiveTrackingPage()),
                    );
                  },
                  icon: Icons.map,
                  label: 'Set Route',
                ),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentDetailPage()),
                    );
                  },
                  icon: Icons.school,
                  label: 'Student Details',
                ),
                _buildLink(
                  context: context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateDetailsPage()),
                    );
                  },
                  icon: Icons.location_on,
                  label: 'Live Tracking',
                ),

              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60, // Set the height for the app bar section
                  color: appBarColor, // Set app bar color
                  child: AppBar(
                    automaticallyImplyLeading: false, // Remove default back button
                    title: Text(
                      'Trackkaro',
                      style: TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: appBarColor,
                    elevation: 0,
                    centerTitle: false,
                    actions: [
                      Row(
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.person,
                              size: 40.0,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40), // Add space between navigation bar and buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildLargeButtonInRow(
                                context: context,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BusDetailPage()),
                                  );
                                },
                                icon: Icons.directions_bus,
                                label: 'Manage Buses',
                                color: Colors.white,
                                borderColor: Color(0xFF03B0C1),
                              ),
                            ),
                            Expanded(
                              child: _buildLargeButtonInRow(
                                context: context,
                                onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LiveTrackingPage()),
                                  );

                                },
                                icon: Icons.map,
                                label: 'Set Route',
                                color: Colors.white,
                                borderColor: Color(0xFF03B0C1),
                              ),
                            ),
                            Expanded(
                              child: _buildLargeButtonInRow(
                                context: context,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StudentDetailPage()),
                                  );
                                },
                                icon: Icons.school,
                                label: 'Manage Students',
                                color: Colors.white,
                                borderColor: Color(0xFF03B0C1),
                              ),
                            ),
                            Expanded(
                              child: _buildLargeButtonInRow(
                                context: context,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UpdateDetailsPage()),
                                  );
                                },
                                icon: Icons.location_on,
                                label: 'Live Tracking',
                                color: Colors.white,
                                borderColor: Color(0xFF03B0C1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80), // Increased space between the buttons and pie chart
                        Container(
                          margin: EdgeInsets.all(20),
                          child: SizedBox(
                            width: 1000, // Set the width of the pie chart container
                            height: 800, // Set the height of the pie chart container
                            child: CustomClickablePieChart(
                              dataMap: dataMap,
                              colorList: colorList,
                              onSegmentTap: (selectedSegment) {
                                if (selectedSegment == 'On Route') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OnRoutePage()),
                                  );
                                } else if (selectedSegment == 'Standby') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StandbyPage()),
                                  );
                                } else if (selectedSegment == 'Out of Service') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OutOfServicePage()),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: MouseRegion(
        onEnter: (event) => _onEnter(event),
        onExit: (event) => _onExit(event),
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Row(
              children: [
                Icon(icon, color: _isHovered ? Colors.black : Colors.white),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    color: _isHovered ? Colors.black : Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isHovered = false;

  void _onEnter(PointerEvent event) {
    _isHovered = true;
  }

  void _onExit(PointerEvent event) {
    _isHovered = false;
  }

  Widget _buildLargeButtonInRow({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Add horizontal margin for spacing
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50), // Adjusted border radius for thinner buttons
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: borderColor, width: 5),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 50, color: Color(0xFF03B0C1)), // Increased icon size for larger button
        label: Text(
          label,
          style: TextStyle(
              fontSize: 20, // Increased font size for larger button
              color: Color(0xFF03B0C1)

          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 60, horizontal: 60),  // Adjusted padding for larger button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}

// User details drawer widget
class UserDetailsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF03B0C1), // App bar color
            ),
            child: Text(
              'User Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Name: John Doe'),
            subtitle: Text('Username: johndoe'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email: johndoe@example.com'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone: +1234567890'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout tap
            },
          ),
        ],
      ),
    );
  }
}




