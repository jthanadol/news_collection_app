import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';

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
  bool _isLoading = false;
  bool _fillData = false;
  bool _isTranslate = false;
  String? _errorMessage;
  NewsResponse? _newsResponse;
  final ScrollController _scrollController = ScrollController();
  bool _isNewsEnd = false; //ข้อมูลที่ขอกับ server หมดหรือยังถ้ายังเป็น false

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      getNewsNextPage();
    }
  }

  Future<void> getNews() async {
    if (searchText?.length != 0) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        _newsResponse = await ApiAction.apiAction.searchNews(text: searchText!);

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        _errorMessage = e.toString();
      }
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
          var newsNext = await ApiAction.apiAction.searchNews(text: searchText!, offset: _newsResponse!.news!.length);

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
                  itemBuilder: (context, index) {
                    Image? image;
                    if (_newsResponse!.news![index].imgUrl != null) {
                      image = Image.network(
                        _newsResponse!.news![index].imgUrl!,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      );
                    } else {
                      image = null;
                    }
                    return ListTile(
                      leading: image,
                      title: Text(
                        (_isTranslate) ? _newsResponse!.news![index].titleTh! : _newsResponse!.news![index].title!,
                        softWrap: true,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_newsResponse!.news![index].description != null)
                            Text(
                              (_isTranslate) ? _newsResponse!.news![index].descriptionTh! : _newsResponse!.news![index].description!,
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
                  itemCount: _newsResponse!.news!.length),
            ),
            if (_fillData) const Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildError() => Center(
          child: Text(_errorMessage!),
        );

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

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
                    onSubmitted: (value) {
                      searchText = value;
                      getNews();
                    },
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: _isTranslate,
                    onChanged: (value) {
                      setState(() {
                        _isTranslate = value!;
                      });
                      //
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text("แปลภาษา"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (!_isLoading && _newsResponse != null) buildPage(),
                  if (_isLoading) buildLoadingOverlay(),
                  if (searchText == null && _newsResponse == null) const Center(child: Text("ยังไม่ได้กรอกคำค้นหา")),
                  if (_errorMessage != null) buildError(),
                ],
              ),
            ),
          ],
        ));
  }
}
