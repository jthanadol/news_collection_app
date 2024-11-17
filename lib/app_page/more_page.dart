import 'package:flutter/material.dart';

import 'bottom_bar.dart';

class MorePage extends StatelessWidget {
  static const routeName = "more page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("More"),
        backgroundColor: Colors.greenAccent[400],
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Center(
        child: Text("This Body"),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
