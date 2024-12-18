import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/api_response/api_action.dart';

class MorePage extends StatefulWidget {
  static const routeName = "/more_page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    play();
  }

  Future<void> play() async {
    final player = AudioPlayer(); // Create a player
    String path = await ApiAction.apiAction.getVaja9Api(input_text: "ทดสอบเสียง");

    final duration = await player.setUrl(// Load a URL
        path);
    await player.play();
    int i = path.lastIndexOf('/');

    final directory = Directory(path.substring(0, i));

    if (await directory.exists()) {
      try {
        // อ่านไฟล์ทั้งหมดในโฟลเดอร์
        final files = directory.listSync();

        for (var file in files) {
          if (file is File) {
            await file.delete(); // ลบไฟล์
            print('Deleted file: ${file.path}');
          }
        }

        print('All files in ${directory.path} have been deleted.');
      } catch (e) {
        print('Error while deleting files: $e');
      }
    } else {
      print('Directory does not exist: ${directory.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("More"),
        backgroundColor: Colors.black12,
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: const Center(
        child: Text("This Body"),
      ),
    );
  }
}
