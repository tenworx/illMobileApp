import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outlook/responsive.dart';
import 'components/list_of_emails.dart';

class MainScreen extends StatefulWidget {
  final role;
  MainScreen({required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime pre_backpress = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.role == 'user' ? _determinePosition() : null;
  }

  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final timegap = DateTime.now().difference(pre_backpress);
          final cantExit = timegap >= Duration(seconds: 2);
          pre_backpress = DateTime.now();
          if (cantExit) {
            //show snackbar
            final snack = SnackBar(
              content: Text('Press Back button again to Exit'),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
            return false;
          } else {
            exit(0);
          }
        },
        child: Responsive(
          // Let's work on our mobile part
          mobile: ListOfEmails(
            role: widget.role,
          ),
          tablet: Row(
            children: [
              Expanded(
                flex: 6,
                child: ListOfEmails(role: widget.role),
              ),
            ],
          ),
          desktop:
              // Row(
              //   children: [
              //     // Once our width is less then 1300 then it start showing errors
              //     // Now there is no error if our width is less then 1340
              //     Expanded(
              //       flex: 1,
              //       // flex: _size.width > 1340 ? 2 : 4,
              //       child: role == 'admin' ? SideMenu() : UserSideMenu(),
              //     ),
              //     Expanded(
              //       flex: 4,
              //       // flex: _size.width > 1340 ? 3 : 5,
              //       child: ListOfEmails(role: role),
              //     ),
              //     // Expanded(
              //     //   // flex: _size.width > 1340 ? 8 : 10,
              //     //   // child: role == 'admin' ? EmailScreen() : DoctorProfile(),
              //     // ),
              //   ],
              // ),
              ListOfEmails(
            role: widget.role,
          ),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
