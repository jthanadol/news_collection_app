import 'package:flutter/material.dart';

import '../api_response/news_response.dart';

class ReadNewPage extends StatefulWidget {
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
  late News news;
  late List<String> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
