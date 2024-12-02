// ignore_for_file: sort_child_properties_last, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'package:news_app/app_page/search_new_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home_page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsResponse? _newsResponse;
  bool _isLoading = false;
  bool _fillData = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  String _country = "th";
  String _language = 'th';
  String _category = 'ธุรกิจ';
  Map<String, String> mapCategory = {
    'ธุรกิจ': 'business',
    'อาชญากรรม': 'crime',
    'ภายในประเทศ': 'domestic',
    'การศึกษา': 'education',
    'บันเทิง': 'entertainment',
    'สิ่งแวดล้อม': 'environment',
    'อาหาร': 'food',
    'สุขภาพ': 'health',
    'ไลฟ์สไตล์': 'lifestyle',
    'อื่นๆ': 'other',
    'การเมือง': 'politics',
    'วิทยาศาสตร์': 'science',
    'กีฬา': 'sports',
    'เทคโนโลยี': 'technology',
    'ยอดนิยม': 'top',
    'การท่องเที่ยว': 'tourism',
    'โลก': 'world',
  };

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
        category: mapCategory[_category],
        country: _country,
        language: _language,
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
        category: mapCategory[_category],
        country: _country,
        language: _language,
        page: _newsResponse!.nextPage,
      );

      setState(() {
        _newsResponse!.news!.addAll(newsNext.news!);
        _newsResponse!.nextPage = newsNext.nextPage;
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
                itemCount: _newsResponse!.news!.length,
                itemBuilder: (context, index) {
                  Image? image;
                  if (_newsResponse!.news![index].image_url != null) {
                    image = Image.network(
                      _newsResponse!.news![index].image_url!,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    );
                  } else {
                    image = null;
                  }
                  return ListTile(
                    leading: image,
                    title: Text(
                      _newsResponse!.news![index].title!,
                      softWrap: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_newsResponse!.news![index].description != null)
                          Text(
                            _newsResponse!.news![index].description!,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(DateFormat.yMMMEd().format(DateTime.parse(_newsResponse!.news![index].pubDate!))),
                        if (_newsResponse!.news![index].factCheckResponse!.claims!.isEmpty)
                          Container(
                            child: const Text("ไม่พบการตรวจสอบ"),
                            color: Colors.amber,
                          )
                        else
                          Text("พบการตรวจสอบทั้งหมด : ${_newsResponse!.news![index].factCheckResponse!.claims!.length} รายการ"),
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(context, ReadNewPage.routeName, arguments: _newsResponse!.news![index]),
                  );
                },
                controller: _scrollController,
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            if (_fillData) const Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

    buildErrorPage() => Center(
          child: Text(_errorMessage!),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("ข่าวประเทศไทย"),
        backgroundColor: Colors.black12,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, SearchNewPage.routeName);
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("หมวดข่าว"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                    getNewsFromNewsData();
                  },
                  items: mapCategory.keys.toList().map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  value: _category,
                ),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_isLoading && _newsResponse != null) buildPage(),
                if (!_isLoading && _newsResponse!.news!.isEmpty)
                  const Center(
                    child: Text("ไม่มีข่าว"),
                  ),
                if (_errorMessage != null) buildErrorPage(),
                if (_isLoading) buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
