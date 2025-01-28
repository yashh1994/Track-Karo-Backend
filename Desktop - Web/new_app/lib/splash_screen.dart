import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_app/login_page.dart'; // Adjust the import path according to your project structure

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.teal.shade300,
      end: Colors.teal.shade100,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Timer(Duration(seconds: 3), () {
      // Navigate to the login page after 5 seconds
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: [
              // First background color with animation
              Container(
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                ),
              ),
              // Second background image with animation
              Center(
                child: ScaleTransition(
                  scale: _logoAnimation,
                  child: Opacity(
                    opacity: _logoAnimation.value,
                    child: Container(
                      margin: EdgeInsets.all(20.0), // Adjust margin as needed
                      width: 400, // Adjust width as needed
                      height: 400, // Adjust height as needed
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.contain, // Fit image inside container
                        ),
                      ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
