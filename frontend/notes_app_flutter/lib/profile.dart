import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:notes_app_frontend/constants/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetProfileScreen extends StatefulWidget {
  const GetProfileScreen({super.key});
  @override
// ignore: library_private_types_in_public_api
  _GetProfileScreenState createState() => _GetProfileScreenState();
}

class _GetProfileScreenState extends State<GetProfileScreen> {
  Map<String, String> profile = {
    'id': '',
    'fullname': '',
    'username': '',
  };
  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await Dio().get("$baseUrl/profile",
          options: Options(headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}'
          }));
      if (response.statusCode == 200) {
        setState(() {
          profile['id'] = response.data['id'];
          profile['fullname'] = response.data['fullname'];
          profile['username'] = response.data['username'];
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('ID: ${profile['id']}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Full Name: ${profile['fullname']}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Username: ${profile['username']}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
