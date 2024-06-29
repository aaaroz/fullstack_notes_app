import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notes_app_frontend/constants/api_url.dart';
import 'package:notes_app_frontend/notes/get_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateNoteScreen extends StatefulWidget {
  final String noteId;
  const UpdateNoteScreen({super.key, required this.noteId});
  @override
// ignore: library_private_types_in_public_api
  _UpdateNoteScreenState createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  String? accessToken;
  bool isValid = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadAccessToken();
    _getNotesById();
  }

  void _loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('accessToken') ?? '';
    });
  }

  void _validateInputs() {
    setState(() {
      isValid = name.text.isNotEmpty && description.text.isNotEmpty;
    });
  }

  void _getNotesById() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Dio().get(
        '$baseUrl/notes/${widget.noteId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          name.text = response.data['name'];
          description.text = response.data['description'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    _validateInputs();
  }

  void _updateNote(
    String name,
    String description,
    String accessToken,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await Dio().patch(
        '$baseUrl/notes/${widget.noteId}',
        data: {
          'name': name,
          'description': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      if (response.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const GetNotesScreen(),
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: TextField(
                  controller: name,
                  onChanged: (_) => _validateInputs(),
                  decoration: const InputDecoration(
                    labelText: 'Masukan nama',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: TextField(
                  controller: description,
                  onChanged: (_) => _validateInputs(),
                  decoration: const InputDecoration(
                    labelText: 'Masukan deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : isValid
                          ? () => _updateNote(
                              name.text, description.text, accessToken!)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.black),
                          ))
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Simpan perubahan data',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
