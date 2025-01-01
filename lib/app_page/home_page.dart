import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'package:news_app/app_page/search_new_page.dart';
import 'package:news_app/config.dart';

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
  bool _isNewsEnd = false; //ข้อมูลที่ขอกับ server หมดหรือยังถ้ายังเป็น false
  String? _errorMessage;
  bool _isLast = true; //true เรียงข่าวจากล่าสุด
  final ScrollController _scrollController = ScrollController();

  String _country = "th";
  String _category = 'ธุรกิจ';
  String _date = 'last';
  final category = Config.config.category;

  @override
  void initState() {
    super.initState();
    getNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      getNewsNextPage();
    }
  }

  Future<void> getNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _newsResponse = await ApiAction.apiAction.getNews(country: _country, category: category[_category]!, date: _date);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getNewsNextPage() async {
    if (!_fillData) {
      try {
        if (!_isNewsEnd) {
          setState(() {
            _errorMessage = null;
            _fillData = true;
          });
          var newsNext = await ApiAction.apiAction.getNews(country: _country, category: category[_category]!, date: _date, offset: _newsResponse!.news!.length);

          setState(() {
            if (newsNext.news!.isEmpty) {
              _isNewsEnd = true;
            } else {
              _newsResponse!.news!.addAll(newsNext.news!);
            }

            _fillData = false;
          });
        }
      } catch (e) {
        _errorMessage = e.toString();
      }
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
                  if (_newsResponse!.news![index].imgUrl != null) {
                    image = Image.network(
                      _newsResponse!.news![index].imgUrl!,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      width: 150,
                    );
                  } else {
                    image = null;
                  }
                  return ListTile(
                    leading: image,
                    title: Text(
                      _newsResponse!.news![index].titleTh!,
                      softWrap: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_newsResponse!.news![index].descriptionTh != null)
                          Text(
                            _newsResponse!.news![index].descriptionTh!,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(DateFormat.yMMMEd().format(DateTime.parse(_newsResponse!.news![index].pubDate!))),
                        if (_newsResponse!.news![index].factCheck!.claims!.isEmpty)
                          Container(
                            color: Colors.amber,
                            child: const Text("ไม่พบการตรวจสอบ"),
                          )
                        else
                          Text("พบการตรวจสอบทั้งหมด : ${_newsResponse!.news![index].factCheck!.claims!.length} รายการ"),
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
                    getNews();
                  },
                  items: category.keys.toList().map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  value: _category,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isLast = !_isLast;
                    _date = (_isLast) ? 'last' : 'old';
                    getNews();
                  });
                },
                icon: Icon(
                  Icons.filter_alt,
                  color: (!_isLast) ? Colors.red : Colors.grey,
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
