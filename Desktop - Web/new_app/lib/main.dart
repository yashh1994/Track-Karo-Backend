import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'busdetail_page.dart';
import 'student_detail_page.dart';
import 'on_route_page.dart';
import 'standby_page.dart';
import 'out_of_service_page.dart';
import 'live_tracking_page.dart'; // Import LiveTrackingPage
import 'update_details_page.dart'; // Import UpdateDetailsPage
import 'package:provider/provider.dart';
import 'pie_chart_data_model.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set initial route to SplashScreen
      routes: {
        '/': (context) => SplashScreen(), // SplashScreen as the initial route
        '/login': (context) => LoginPage(), // Define route for LoginPage
        '/home': (context) => HomePage(), // Define route for HomePage
        '/busDetail': (context) =>
            BusDetailPage(), // Define route for BusDetailPage
        '/studentDetail': (context) =>
            StudentDetailPage(), // Define route for StudentDetailPage
        '/onRoute': (context) => OnRoutePage(), // Define route for OnRoutePage
        '/standby': (context) => StandbyPage(), // Define route for StandbyPage
        '/outOfService': (context) =>
            OutOfServicePage(), // Define route for OutOfServicePage
        '/liveTracking': (context) =>
            LiveTrackingPage(), // Define route for LiveTrackingPage
        '/updateDetails': (context) =>
            UpdateDetailsPage(), // Define route for UpdateDetailsPage
      },
    );
  }
}
