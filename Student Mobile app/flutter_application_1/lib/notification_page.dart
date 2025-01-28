import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(MaterialApp(
    home: NotificationPage(),
  ));
}
class Message {
  final String id;
  final String message;
  bool read;

  Message(this.id, this.message, this.read);
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'date': '2023-05-28',
      'messages': [
        Message('1', 'Student boarded the bus.', false),
        Message('2', 'Student arrived at school.', true),
      ],
    },
    {
      'date': '2023-05-29',
      'messages': [
        Message('3', 'Student left school.', false),
      ],
    },
    {
      'date': '2023-05-30',
      'messages': [
        Message('4', 'Bus is delayed by 10 minutes.', false),
        Message('5', 'Student left the bus.', true),
      ],
    },
    {
      'date': '2023-05-31',
      'messages': [
        Message('6', 'Student boarded the bus.', false),
        Message('7', 'Student arrived at school.', true),
        Message('8', 'Bus is on time.', false),
      ],
    },
    {
      'date': '2023-06-01',
      'messages': [
        Message('9', 'Student left school.', false),
        Message('10', 'Bus will arrive in 5 minutes.', false),
        Message('11', 'Student boarded the bus.', true),
      ],
    },
    {
      'date': '2023-06-02',
      'messages': [
        Message('12', 'Student arrived at school.', false),
        Message('13', 'Bus is delayed by 5 minutes.', true),
      ],
    },
    {
      'date': '2023-06-03',
      'messages': [
        Message('14', 'Student left school.', false),
        Message('15', 'Bus will arrive in 2 minutes.', true),
        Message('16', 'Bus is delayed by 10 minutes.', false),
        Message('17', 'Student left the bus.', true),
        Message('18', 'Bus is delayed by 10 minutes.', false),
        Message('19', 'Student left the bus.', true),
        Message('20', 'Bus is delayed by 10 minutes.', false),
        Message('21', 'Student left the bus.', true),
        Message('22', 'Bus is delayed by 10 minutes.', false),
        Message('23', 'Student left the bus.', true),
        Message('24', 'Bus is delayed by 10 minutes.', false),
        Message('25', 'Student left the bus.', true),
        Message('26', 'Bus is delayed by 10 minutes.', false),
        Message('27', 'Student left the bus.', true),
        Message('28', 'Bus is delayed by 10 minutes.', false),
        Message('29', 'Student left the bus.', true),
      ],
    },
    {
      'date': '2023-06-04',
      'messages': [
        Message('30', 'Student boarded the bus.', false),
        Message('31', 'Student arrived at school.', true),
      ],
    },
    {
      'date': '2023-06-05',
      'messages': [
        Message('32', 'Student left school.', false),
      ],
    },
    {
      'date': '2023-06-06',
      'messages': [
        Message('33', 'Bus is delayed by 10 minutes.', false),
        Message('34', 'Student left the bus.', true),
      ],
    },
    {
      'date': '2023-06-07',
      'messages': [
        Message('35', 'Student boarded the bus.', false),
        Message('36', 'Student arrived at school.', true),
        Message('37', 'Bus is on time.', false),
      ],
    },
    {
      'date': '2023-06-08',
      'messages': [
        Message('38', 'Student left school.', false),
        Message('39', 'Bus will arrive in 5 minutes.', false),
        Message('40', 'Student boarded the bus.', true),
      ],
    },
    {
      'date': '2023-06-09',
      'messages': [
        Message('41', 'Student arrived at school.', false),
        Message('42', 'Bus is delayed by 5 minutes.', true),
      ],
    },
    {
      'date': '2023-06-10',
      'messages': [
        Message('43', 'Student left school.', false),
        Message('44', 'Bus will arrive in 2 minutes.', true),
      ],
    },
  ];

  void _markAsRead(int dateIndex, int messageIndex) {
    var message = notifications[dateIndex]['messages'][messageIndex];
    if (!message.read) {
      setState(() {
        message.read = true;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        for (var message in notification['messages']) {
          message.read = true;
        }
      }
    });
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('d MMMM').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03B0C1),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: screenHeight * 0.03,
            ),
          ),
        ),
        title: Text(
          'Notifications',
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
            icon: Icon(Icons.mark_email_read, size: screenHeight * 0.03),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          var formattedDate = _formatDate(notification['date']);
          return Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    color: Color(0xFF03B0C1),
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.025,
                    fontFamily: GoogleFonts.lato().fontFamily,
                  ),
                ),
              ),
              ...notification['messages'].asMap().entries.map((messageEntry) {
                int messageIndex = messageEntry.key;
                var message = messageEntry.value;
                return ListTile(
                  leading: Icon(
                    message.read
                        ? Icons.notifications_none
                        : Icons.notifications,
                    color: message.read ? Colors.grey : Colors.teal,
                    size: screenHeight * 0.03,
                  ),
                  title: Text(
                    message.message,
                    style: TextStyle(
                      color: message.read ? Colors.grey : Colors.black,
                      fontWeight: message.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontFamily: GoogleFonts.lato().fontFamily,
                      fontSize: screenHeight * 0.022,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  onTap: () {
                    if (!message.read) {
                      _markAsRead(index, messageIndex);
                    }
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}


