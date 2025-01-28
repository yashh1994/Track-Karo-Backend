import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_page.dart';
import 'track_bus_page.dart';
import 'history_page.dart';
import 'contact_page.dart';
import 'bus_details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.montserratAlternates(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFF03B0C1),
            ),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    // Dummy data for bus details, replace this with actual data
    Map<String, String> busDetails = {
      'Bus No': '42A',
      'Estimated Arrival': '10:30 AM',
      'Pickup Time': '8:00 AM',
      'Drop-off Time': '4:00 PM',
      'Route': 'Home to XYZ Institute'
    };

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TrackKaro',
                  style: GoogleFonts.montserratAlternates(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.034,
                      color: Color(0xFF03B0C1),
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: screenHeight * 0.017,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.0097),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF03B0C1).withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/notification_bell.png',
                width: screenHeight * 0.055,
                height: screenHeight * 0.055,
              ),
            ),
          ),
        ],
      ),
      drawer: Container(
        width: screenWidth * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: screenHeight * 0.25,
                color: Color(0xFF03B0C1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: screenHeight * 0.025),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/p1.png',
                            width: screenHeight * 0.15,
                            height: screenHeight * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.0225,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Student',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.0175,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: screenHeight * 0.0225,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    _buildPersonalDetail('Institute Name', 'XYZ Institute', screenHeight),
                    SizedBox(height: screenHeight * 0.01),
                    _buildPersonalDetail('GR No', '123456789', screenHeight),
                    SizedBox(height: screenHeight * 0.01),
                    _buildPersonalDetail('Email', 'johndoe@example.com', screenHeight),
                    SizedBox(height: screenHeight * 0.01),
                    _buildPersonalDetail('Phone', '+1234567890', screenHeight),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildLogoutButton(context, screenHeight),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(left: screenHeight * 0.02),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF03B0C1).withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/p1.png',
                            width: screenHeight * 0.1,
                            height: screenHeight * 0.1,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: screenHeight * 0.0225,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        Text(
                          'Student',
                          style: TextStyle(
                            fontSize: screenHeight * 0.0175,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.0193),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.0193),
                child: _buildBusDetailsBox(busDetails, screenHeight), // Bus details box
              ),
              SizedBox(height: screenHeight * 0.0193),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: screenHeight * 0.029),
                  decoration: BoxDecoration(
                    color: Color(0xFF03B0C1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenHeight * 0.072),
                      topRight: Radius.circular(screenHeight * 0.072),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.0193),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.0193),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMenuItem(context, 'assets/images/track_bus_icon.png', 'Track Bus', TrackBusPage(), screenHeight),
                            _buildMenuItem(context, 'assets/images/history_icon.png', 'History', HistoryPage(), screenHeight),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.0193),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.0097),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMenuItem(context, 'assets/images/contact_icon.png', 'Contact', ContactPage(), screenHeight),
                            _buildMenuItem(context, 'assets/images/busdetails.png', 'Bus Details', BusDetailsPage(), screenHeight),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.0193),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusDetailsBox(Map<String, String?> busDetails, double screenHeight) {
    String busNo = busDetails['Bus No'] ?? 'N/A';
    String estimatedArrival = busDetails['Estimated Arrival'] ?? 'N/A';
    String pickupTime = busDetails['Pickup Time'] ?? 'N/A';
    String dropoffTime = busDetails['Drop-off Time'] ?? 'N/A';
    String route = busDetails['Route'] ?? 'N/A';

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.012),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.0193),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBusDetailRow('Bus No', busNo, screenHeight),
          Divider(color: Colors.grey[300]),
          _buildBusDetailRow('Estimated Arrival', estimatedArrival, screenHeight),
          Divider(color: Colors.grey[300]),
          _buildBusDetailRow('Pickup Time', pickupTime, screenHeight),
          Divider(color: Colors.grey[300]),
          _buildBusDetailRow('Drop-off Time', dropoffTime, screenHeight),
          Divider(color: Colors.grey[300]),
          _buildBusDetailRow('Route', route, screenHeight),
        ],
      ),
    );
  }

  Widget _buildBusDetailRow(String label, String value, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0012),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenHeight * 0.022,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenHeight * 0.022,
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetail(String label, String detail, double screenHeight) {
    Color lightBlue = Color(0xFF03B0C1).withOpacity(0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenHeight * 0.0193),
          width: double.infinity,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(screenHeight * 0.01),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.figtree(
              fontSize: screenHeight * 0.0225,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenHeight * 0.02),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(screenHeight * 0.0193),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            detail,
            style: GoogleFonts.figtree(
              fontSize: screenHeight * 0.0225,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String imagePath, String label, Widget page, double screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenHeight * 0.0193),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenHeight * 0.0193),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenHeight * 0.0193),
                child: Image.asset(
                  imagePath,
                  width: screenHeight * 0.1,
                  height: screenHeight * 0.1,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.0191,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, double screenHeight) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.0193),
          ),
          child: Container(
            padding: EdgeInsets.all(screenHeight * 0.0193),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenHeight * 0.0193),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF03B0C1),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.0193),
                Text(
                  'Are you sure you want to log out?',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                      fontSize: screenHeight * 0.0225,
                      color: Colors.black87,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.0193, vertical: screenHeight * 0.01),
                        textStyle: TextStyle(
                          fontSize: screenHeight * 0.0193,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenHeight * 0.01),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Perform logout actions here
                        Navigator.of(context).pop();
                        print("User logged out");
                        // Navigate to login screen or perform other actions
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF03B0C1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.0193, vertical: screenHeight * 0.01),
                        textStyle: TextStyle(
                          fontSize: screenHeight * 0.0193,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenHeight * 0.01),
                        ),
                      ),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, double screenHeight) {
    return ListTile(
      onTap: () {
        _showLogoutConfirmationDialog(context, screenHeight);
      },
      leading: Icon(Icons.exit_to_app, size: screenHeight * 0.03),
      title: Text(
        'Logout',
        style: TextStyle(
          fontSize: screenHeight * 0.0225,
        ),
      ),
    );
  }
}