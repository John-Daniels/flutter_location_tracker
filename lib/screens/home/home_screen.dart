import 'package:flutter/material.dart';
import 'package:location_tracker/screens/LocationForm/LocationFormScreen.dart';
import 'package:location_tracker/screens/LocationMap/LocationMap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 150,
                  color: Colors.red,
                ),
                const Text(
                  'Location Tracker',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.red.shade400,
                      textColor: Colors.white,
                      elevation: 0,
                      child: const Text('sender'),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LocationForm()))),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.red.shade400,
                      textColor: Colors.white,
                      elevation: 0,
                      child: const Text('reciever'),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LocationMap()))),
                ),
              ]),
        ),
      ),
    );
  }
}
