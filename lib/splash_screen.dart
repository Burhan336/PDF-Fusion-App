import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'main.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add any necessary initialization or data loading tasks here
    // For example, you could load user preferences or check for updates
    // using asynchronous functions or Future.delayed()
    navigateToHome(); // Replace this with your actual navigation function
  }

  // Example function for navigating to the home screen
  void navigateToHome() {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
    ));

    return Scaffold(
      backgroundColor: Colors.white, // Replace with your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace this with your logo widget or image
            Image.asset(
              'assets/images/logo.png', // Replace with the path to your custom image
              width: 100,
            ),
            SizedBox(height: 20),
            Text(
              'PDF Fusion',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            SpinKitCircle(
              color: Colors.blue, // Customize the loading spinner color
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
