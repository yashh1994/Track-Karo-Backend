import 'package:flutter/material.dart';
import 'package:new_app/live_tracking_page.dart';
import 'package:new_app/update_details_page.dart';
import 'busdetail_page.dart';
import 'student_detail_page.dart';
import 'package:new_app/manage_driver_page.dart';
import 'home_page.dart';

class CommonSidebar extends StatelessWidget {
  final bool isMobile;
  final Function(int) onNavigate; // Callback function for navigation

  const CommonSidebar({Key? key, required this.isMobile, required this.onNavigate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.maxFinite : 250,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/logo23.png',
                height: 100,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildSidebarLink(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () => _navigateTo(context, HomePage()),
          ),
          _buildSidebarLink(
            icon: Icons.directions_bus,
            label: 'Manage Buses',
            onTap: () => _navigateTo(context, BusDetailPage()),
          ),
          _buildSidebarLink(
            icon: Icons.person,
            label: 'Manage Drivers',
            onTap: () => _navigateTo(context, ManageDriverPage()),
          ),
          _buildSidebarLink(
            icon: Icons.map,
            label: 'Set Route',
            onTap: () => _navigateTo(context, LiveTrackingPage()),
          ),
          _buildSidebarLink(
            icon: Icons.school,
            label: 'Manage Students',
            onTap: () => _navigateTo(context, StudentDetailPage()),
          ),
          _buildSidebarLink(
            icon: Icons.location_on,
            label: 'Live Tracking',
            onTap: () => _navigateTo(context, UpdateDetailsPage()),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  Widget _buildSidebarLink(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
