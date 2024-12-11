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
  String? _errorMessage;
  NewsResponse? _newsResponse;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> getNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      var stopwatch = Stopwatch();
      stopwatch.start();

      _newsResponse = await ApiAction().getBingSearchNewsApi(q: searchText);
      List<String> q = await ApiAction().separateWord(text: searchText!);
      String searchQ = "";
      for (var i = 0; i < q.length; i++) {
        if (i == 0) {
          searchQ += q[i];
        } else {
          searchQ += "OR${q[i]}";
        }
      }
      NewsResponse newsSearchQ = await ApiAction().getBingSearchNewsApi(q: searchQ);
      _newsResponse!.news!.addAll(newsSearchQ.news!);

      stopwatch.stop();
      print("Bing ใช้เวลาทั้งหมด ${stopwatch.elapsedMilliseconds} มิลลิวินาที");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    buildPage() => ListView.separated(
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
                    color: Colors.amber,
                    child: const Text("ไม่พบการตรวจสอบ"),
                  )
                else
                  Text("พบการตรวจสอบทั้งหมด : ${_newsResponse!.news![index].factCheckResponse!.claims!.length} รายการ"),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, ReadNewPage.routeName, arguments: _newsResponse!.news![index]),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _newsResponse!.news!.length);

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
        body: Stack(
          children: [
            if (!_isLoading && _newsResponse != null) buildPage(),
            if (_isLoading) buildLoadingOverlay(),
            if (searchText == null && _newsResponse == null) const Center(child: Text("ยังไม่ได้กรอกคำค้นหา")),
            if (_errorMessage != null) buildError(),
          ],
        ));
  }
}
