// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location_tracker/constants.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LocationForm extends StatefulWidget {
  const LocationForm({super.key});

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  late IO.Socket socket;
  double? latitude;
  double? longitude;
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    listen();
  }

  listen() async {
    await initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket = IO.io(socketUri, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      print('trying connnection');
      socket.connect();

      socket.onConnect((data) {
        print('Connect: ${socket.id}');
      });
    } catch (e) {
      print('error');
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: globalKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FormHelper.inputFieldWidget(
                    context,
                    "Latitude",
                    "Latitude",
                    (value) {
                      if (value.isEmpty) {
                        return "* Required!";
                      }

                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Provide a valid coordinate';
                      }

                      return null;
                    },
                    (value) {
                      latitude = double.parse(value);
                    },
                    borderRadius: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FormHelper.inputFieldWidget(
                    context,
                    "Longitude",
                    "Longitude",
                    (value) {
                      if (value.isEmpty) {
                        return "* Required!";
                      }

                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Provide a valid coordinate';
                      }

                      return null;
                    },
                    (value) {
                      longitude = double.parse(value);
                    },
                    borderRadius: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FormHelper.submitButton("Send Location", () {
                    if (validateAndSave()) {
                      var coords = {"lat": latitude, "long": longitude};

                      socket.emit('position-change', jsonEncode(coords));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location sent')));
                    }
                  })
                ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    initState();
    super.dispose();
  }

  bool validateAndSave() {
    final form = globalKey.currentState;

    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
