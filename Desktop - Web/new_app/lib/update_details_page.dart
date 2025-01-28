import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common_sidebar.dart'; // Adjust the path if needed

class UpdateDetailsPage extends StatelessWidget {
  final List<Map<String, String>> busDetails = List.generate(20, (index) {
    return {
      'Bus Number': 'Bus ${index + 1}',
      'Estimated Time': '9:00 AM',
      'Estimated Pick-up Time': '8:00 AM',
      'Estimated Drop-off Time': '4:00 PM',
    };
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
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
          if (!isMobile)
            CommonSidebar(
              isMobile: isMobile,
              onNavigate: (int index) {
                // Handle navigation based on index if needed
              },
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF03B0C1),
                      ),
                    ),
                    SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : constraints.maxWidth < 900
                            ? 2
                            : 3;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: busDetails.length,
                          itemBuilder: (context, index) {
                            final busDetail = busDetails[index];
                            return _buildSmallButtonInRow(
                              context: context,
                              onPressed: () {
                                _openGoogleMaps(busDetail['Bus Number']!);
                              },
                              busNumber: busDetail['Bus Number']!,
                              estimatedTime: busDetail['Estimated Time']!,
                              pickupTime: busDetail['Estimated Pick-up Time']!,
                              dropTime: busDetail['Estimated Drop-off Time']!,
                              color: Colors.white,
                              borderColor: Color(0xFF03B0C1),
                            );
                          },
                        );
                      },
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

  void _openGoogleMaps(String location) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$location";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Widget _buildSmallButtonInRow({
    required BuildContext context,
    required VoidCallback onPressed,
    required String busNumber,
    required String estimatedTime,
    required String pickupTime,
    required String dropTime,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF03B0C1),
                ),
              ),
              Text(
                'Estimated: $estimatedTime',
                style: TextStyle(fontSize: 14, color: Color(0xFF03B0C1)),
              ),
              Text(
                'Pick-up: $pickupTime',
                style: TextStyle(fontSize: 14, color: Color(0xFF03B0C1)),
              ),
              Text(
                'Drop-off: $dropTime',
                style: TextStyle(fontSize: 14, color: Color(0xFF03B0C1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
