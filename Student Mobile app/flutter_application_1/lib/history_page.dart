import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(
      home: HistoryPage(),
    ),
  );
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  // Example data for history
  Map<DateTime, List<Map<String, String>>> _histories = {
    DateTime(2024, 6, 7): [
      {
        'from': 'Home',
        'to': 'School',
        'pickupTime': '8:00 AM',
        'dropoffTime': '8:30 AM'
      },
      {
        'from': 'School',
        'to': 'Home',
        'pickupTime': '3:00 PM',
        'dropoffTime': '3:30 PM'
      }
    ],
    DateTime(2024, 6, 8): [
      {
        'from': 'Home',
        'to': 'Gym',
        'pickupTime': '6:00 AM',
        'dropoffTime': '6:30 AM'
      },
      {
        'from': 'Gym',
        'to': 'Home',
        'pickupTime': '7:00 AM',
        'dropoffTime': '7:30 AM'
      }
    ],
    // Add more dates and histories as needed
  };

  List<Map<String, String>> _getHistoryForSelectedDay() {
    if (_selectedDay != null) {
      return _histories[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFF03B0C1), // Original app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'History',
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
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Add action for the more icon button if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                if (_selectedDay != null) {
                  return isSameDay(_selectedDay, day);
                } else {
                  return isSameDay(DateTime.now(), day);
                }
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              rowHeight: screenHeight * 0.06, // Adjust row height based on screen height
              daysOfWeekHeight: screenHeight * 0.04, // Adjust days of week height based on screen height
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.grey[500], // Color for today circle
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF03B0C1), // Color for selected circle
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.white),
                selectedTextStyle: TextStyle(color: Colors.white),
                defaultTextStyle: TextStyle(fontSize: screenHeight * 0.015), // Smaller font size
                weekendTextStyle: TextStyle(fontSize: screenHeight * 0.015), // Smaller font size
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0xFF03B0C1),
                    fontSize: screenHeight * 0.02, // Smaller font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  size: screenHeight * 0.03, // Smaller size
                  color: Color(0xFF03B0C1),
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  size: screenHeight * 0.03, // Smaller size
                  color: Color(0xFF03B0C1),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: screenHeight * 0.015), // Smaller font size
                weekendStyle: TextStyle(fontSize: screenHeight * 0.015), // Smaller font size
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getHistoryForSelectedDay().length,
              itemBuilder: (context, index) {
                var history = _getHistoryForSelectedDay()[index];
                return HistoryCard(
                  from: history['from']!,
                  to: history['to']!,
                  pickupTime: history['pickupTime']!,
                  dropoffTime: history['dropoffTime']!,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String from;
  final String to;
  final String pickupTime;
  final String dropoffTime;
  final double screenWidth;
  final double screenHeight;

  HistoryCard({
    required this.from,
    required this.to,
    required this.pickupTime,
    required this.dropoffTime,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: screenWidth * 0.03,
            blurRadius: screenWidth * 0.05,
            offset: Offset(0, screenWidth * 0.03), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$from to $to',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              Column(
                children: [
                  Dot(color: Colors.grey, size: screenWidth * 0.05), // Dot for pickup
                  CustomPaint(
                    size: Size(screenWidth * 0.05, screenHeight * 0.05), // Adjust the height
                    painter: DashedLinePainter(screenWidth * 0.005),
                  ),
                  Dot(color: Color(0xFF03B0C1), size: screenWidth * 0.05), // Dot for drop-off
                ],
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pickup',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        pickupTime,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    children: [
                      Text(
                        'Drop-off',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Color(0xFF03B0C1), // Color for drop-off text
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        dropoffTime,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  final double size;

  Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color, // Use the provided color
        shape: BoxShape.circle,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double strokeWidth;

  DashedLinePainter(this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey[500] ?? Colors.grey // Ensure non-nullable color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    double endY = size.height;

    // Define the dash pattern (10 pixels dash followed by 5 pixels space)
    final dashPattern = [10.0, 5.0]; // Change to double values

    // Draw the dashed line between the dots
    double currentY = startY;
    while (currentY < endY) {
      double dashLength = min(dashPattern[0], endY - currentY); // Length of each dash
      canvas.drawLine(
        Offset(size.width / 2, currentY),
        Offset(size.width / 2, currentY + dashLength),
        paint,
      );
      currentY += dashLength + dashPattern[1]; // Move to the start of the next dash
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
