import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Driver {
  final String id;
  final String name;
  final String busNumber;
  final String phoneNumber;
  final String profileImage;

  Driver({
    required this.id,
    required this.name,
    required this.busNumber,
    required this.phoneNumber,
    required this.profileImage,
  });
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final Driver personalDriver = Driver(
    id: '0',
    name: 'Driver',
    busNumber: 'Bus 100',
    phoneNumber: '321-654-0987',
    profileImage: 'https://via.placeholder.com/150',
  );

  List<Driver> drivers = [
    Driver(
      id: '1',
      name: 'John Doe',
      busNumber: 'Bus 101',
      phoneNumber: '123-456-7890',
      profileImage: 'https://via.placeholder.com/150',
    ),
    Driver(
      id: '2',
      name: 'Jane Smith',
      busNumber: 'Bus 102',
      phoneNumber: '098-765-4321',
      profileImage: 'https://via.placeholder.com/150',
    ),
    Driver(
      id: '3',
      name: 'Michael Johnson',
      busNumber: 'Bus 103',
      phoneNumber: '456-789-0123',
      profileImage: 'https://via.placeholder.com/150',
    ),
    Driver(
      id: '4',
      name: 'Emily Davis',
      busNumber: 'Bus 104',
      phoneNumber: '789-012-3456',
      profileImage: 'https://via.placeholder.com/150',
    ),
  ];

  List<Driver> filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    filteredDrivers = [];
  }

  void _filterDrivers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredDrivers = [];
      });
    } else {
      setState(() {
        filteredDrivers = drivers
            .where((driver) =>
        driver.name.toLowerCase().contains(query.toLowerCase()) ||
            driver.busNumber.toLowerCase().contains(query.toLowerCase()) ||
            driver.phoneNumber.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Widget _buildDriverCard(Driver driver, double screenWidth, double screenHeight) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.05,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF03B0C1).withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(driver.profileImage),
                  radius: screenWidth * 0.1,
                ),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF03B0C1),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Text(
                            'Bus Number: ',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Text(
                            driver.busNumber,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Row(
                        children: [
                          Text(
                            'Phone: ',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Text(
                            driver.phoneNumber,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          GestureDetector(
                            onTap: () {
                              launch("tel://${driver.phoneNumber}");
                            },
                            child: Icon(Icons.phone, color: Color(0xFF03B0C1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF03B0C1),
          selectionColor: Color(0xFF03B0C1),
          selectionHandleColor: Color(0xFF03B0C1),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03B0C1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Contact Details',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
                // Add action for the more icon button if needed
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search Drivers',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.02),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(
                      color: Color(0xFF03B0C1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(
                      color: Color(0xFF03B0C1),
                    ),
                  ),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF03B0C1)),
                ),
                onChanged: _filterDrivers,
              ),
            ),
            _buildDriverCard(personalDriver, screenWidth, screenHeight),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  return _buildDriverCard(filteredDrivers[index], screenWidth, screenHeight);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.02, right: screenWidth * 0.04),
          child: CallerButton(),
        ),
      ),
    );
  }
}

class CallerButton extends StatefulWidget {
  final String emergencyNumber = '911'; // Emergency number

  @override
  _CallerButtonState createState() => _CallerButtonState();
}

class _CallerButtonState extends State<CallerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return RotationTransition(
      turns: _controller,
      child: GestureDetector(
        onTap: () {
          launch("tel://${widget.emergencyNumber}");
        },
        child: Container(
          width: screenWidth * 0.2,
          height: screenWidth * 0.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF03B0C1).withOpacity(0.5), // Light and centered shadow
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 0), // Centered the shadow
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/emergency_button.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ContactPage(),
  ));
}
