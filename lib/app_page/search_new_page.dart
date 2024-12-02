import 'package:flutter/material.dart';

class SearchNewPage extends StatefulWidget {
  static const routeName = "/search_new_page";

  const SearchNewPage({super.key});

  @override
  State<SearchNewPage> createState() => _SearchNewPageState();
}

class _SearchNewPageState extends State<SearchNewPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSearchCheck = true;
  String? searchText;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearchCheck
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  onSubmitted: (value) {},
                  decoration: const InputDecoration(hintText: "คำค้นหา. . ."),
                ),
              )
            : const Text("ค้นหาข่าว"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                setState(() {
                  _isSearchCheck = !_isSearchCheck;

                  if (!_isSearchCheck) {
                    _textEditingController.clear();
                    searchText = null;
                  }
                });
              });
            },
            icon: _isSearchCheck ? const Icon(Icons.close) : const Icon(Icons.search),
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Center(child: Text(searchText ?? "ยังไม่กรอกคำค้นหา")),
    );
  }
}
