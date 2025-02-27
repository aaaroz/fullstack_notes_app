// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:notes_app_frontend/auth/login.dart';
import 'package:notes_app_frontend/constants/api_url.dart';
import 'package:notes_app_frontend/notes/create_note.dart';
import 'package:notes_app_frontend/notes/update_note.dart';
import 'package:notes_app_frontend/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetNotesScreen extends StatefulWidget {
  const GetNotesScreen({super.key});
  @override
// ignore: library_private_types_in_public_api
  _GetNotesScreenState createState() => _GetNotesScreenState();
}

class _GetNotesScreenState extends State<GetNotesScreen> {
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final dio = Dio();
      final url = '$baseUrl/notes?page=$pageKey&page_size=5';
      final response = await dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}'
          }));
      final List<dynamic> data = response.data['data'];
      final isLastPage = data.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(data);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      if (error is DioException && error.response?.statusCode == 404) {
        _pagingController.appendLastPage([]);
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('accessToken');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void deleteNote(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await Dio().delete(
        '$baseUrl/notes/$id',
        options: Options(headers: {
          'Authorization': 'Bearer ${prefs.getString('accessToken')}'
        }),
      );
      print(response.data);
      if (response.statusCode == 200) {
        _pagingController.refresh();
      }
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GetProfileScreen()),
              );
            },
            icon: const Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            heightFactor: 2,
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateNotesScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    'Buat catatan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const FractionallySizedBox(
            widthFactor: 0.75,
            child: Text('Daftar Catatan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, dynamic>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FractionallySizedBox(
                        widthFactor: 0.75,
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(item['name']),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(item['description']),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Tutup'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            title: Text(item['name']),
                            subtitle: Text(item['description']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateNoteScreen(noteId: item['id']),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                              'Apakah Anda yakin ingin menghapus catatan ini?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Tutup dialog
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteNote(item[
                                                    'id']); // Hapus catatan
                                                Navigator.of(context)
                                                    .pop(); // Tutup dialog
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
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
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
