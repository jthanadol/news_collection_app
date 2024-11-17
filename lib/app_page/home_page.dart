// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';

import '../api_response/api_action.dart';
import '../api_response/news_response.dart';
import 'bottom_bar.dart';

class HomePage extends StatefulWidget {
  static const routeName = "home page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NewsResponse _newsResponse;
  bool _isLoading = false;
  bool _fillData = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  String? _q;
  String? _qInTitle;
  String? _qInMeta;
  String? _country = "th";
  String? _category = 'politics';
  String? _language = 'th';
  String? _tag;
  int? _size;

  @override
  void initState() {
    super.initState();
    getNewsFromNewsData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      getNewsFromNewsDataNextPage();
    }
  }

  Future<void> getNewsFromNewsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _newsResponse = await ApiAction().getNewsDataApi(
        category: _category,
        country: _country,
        language: _language,
        q: _q,
        qInMeta: _qInMeta,
        qInTitle: _qInTitle,
        size: _size,
        tag: _tag,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getNewsFromNewsDataNextPage() async {
    try {
      setState(() {
        _errorMessage = null;
        _fillData = true;
      });
      var newsNext = await ApiAction().getNewsDataApi(
        category: _category,
        country: _country,
        language: _language,
        q: _q,
        qInMeta: _qInMeta,
        qInTitle: _qInTitle,
        size: _size,
        tag: _tag,
        page: _newsResponse.nextPage,
      );

      setState(() {
        _newsResponse.news.addAll(newsNext.news);
        _newsResponse.nextPage = newsNext.nextPage;
        _fillData = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    buildPage() => Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _newsResponse.news.length,
                itemBuilder: (context, index) {
                  Image? image;
                  if (_newsResponse.news[index].image_url != null) image = Image.network(_newsResponse.news[index].image_url!);
                  return ListTile(
                    leading: image,
                    title: Text(
                      _newsResponse.news[index].title!,
                      softWrap: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_newsResponse.news[index].description != null)
                          Text(
                            _newsResponse.news[index].description!,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(_newsResponse.news[index].pubDate!),
                        if (_newsResponse.news[index].factCheckResponse!.claims!.length == 0)
                          Text("ไม่พบการตรวจสอบ")
                        else
                          Text("พบการตรวจสอบทั้งหมด : ${_newsResponse.news[index].factCheckResponse!.claims!.length} รายการ"),
                      ],
                    ),
                  );
                },
                controller: _scrollController,
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
            if (_fillData) Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: Center(child: CircularProgressIndicator()));

    buildErrorPage() => Container(
            child: Center(
          child: Text(_errorMessage!),
        ));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Home"),
        backgroundColor: Colors.greenAccent[400],
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text("หมวดข่าว")],
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_isLoading) buildPage(),
                if (_errorMessage != null) buildErrorPage(),
                if (_isLoading) buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
