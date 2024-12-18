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

  String s = "";
  var stopwatch = Stopwatch();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> searchBing() async {
    stopwatch.reset();
    stopwatch.start();
    _newsResponse = await ApiAction.apiAction.getBingSearchNewsApi(q: searchText);
    List<String> q = await ApiAction.apiAction.separateNounWord(text: searchText!);

    String searchQ = "";
    NewsResponse newsSearchQ;
    if (q.length == 1 && !q[0].contains(searchText!)) {
      for (var i = 0; i < q.length; i++) {
        if (i == 0) {
          searchQ += q[i];
        } else {
          searchQ += " OR ${q[i]}";
        }
      }
      newsSearchQ = await ApiAction.apiAction.getBingSearchNewsApi(q: searchQ);
      _newsResponse!.news!.addAll(newsSearchQ.news!);
    }

    if (_newsResponse!.news!.isEmpty) {
      s += "Bing ธรรมดา ไม่พบข่าวต้องค้นอีก";
      searchQ = "";
      _newsResponse = await ApiAction.apiAction.getBingSearchNewsApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "en"));
      if (q.length == 1 && !q[0].contains(searchText!)) {
        List<Future<String>> futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "en")).toList();
        q = await Future.wait(futureOrder);
        for (var i = 0; i < q.length; i++) {
          if (i == 0) {
            searchQ += q[i];
          } else {
            searchQ += " OR ${q[i]}";
          }
        }
        newsSearchQ = await ApiAction.apiAction.getBingSearchNewsApi(q: searchQ);
        _newsResponse!.news!.addAll(newsSearchQ.news!);
      }
    }
    stopwatch.stop();
    s += " Bing ค้นหาธรรมดา ใช้เวลาทั้งหมด ${stopwatch.elapsedMilliseconds / 1000} วินาที ||";
  }

  Future<void> searchBingEngFirst() async {
    stopwatch.reset();
    stopwatch.start();
    _newsResponse = await ApiAction.apiAction.getBingSearchNewsApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "en"));
    List<String> q = await ApiAction.apiAction.separateNounWord(text: searchText!);
    List<Future<String>> futureOrder;
    List<String> q2;
    String searchQ = "";
    NewsResponse newsSearchQ;
    if (q.length == 1 && !q[0].contains(searchText!)) {
      futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "en")).toList();
      q2 = await Future.wait(futureOrder);

      for (var i = 0; i < q2.length; i++) {
        if (i == 0) {
          searchQ += q2[i];
        } else {
          searchQ += " OR ${q2[i]}";
        }
      }
      newsSearchQ = await ApiAction.apiAction.getBingSearchNewsApi(q: searchQ);
      _newsResponse!.news!.addAll(newsSearchQ.news!);
    }

    if (_newsResponse!.news!.isEmpty) {
      s += "Bing Eng First ไม่พบข่าวต้องค้นอีก";
      _newsResponse = await ApiAction.apiAction.getBingSearchNewsApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "th"));
      searchQ = "";
      if (q.length == 1 && !q[0].contains(searchText!)) {
        futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "th")).toList();
        q = await Future.wait(futureOrder);
        for (var i = 0; i < q.length; i++) {
          if (i == 0) {
            searchQ += q[i];
          } else {
            searchQ += " OR ${q[i]}";
          }
        }
        newsSearchQ = await ApiAction.apiAction.getBingSearchNewsApi(q: searchQ);
        _newsResponse!.news!.addAll(newsSearchQ.news!);
      }
    }
    stopwatch.stop();
    s += " Bing ค้นหาด้วย Eng ก่อน ใช้เวลาทั้งหมด ${stopwatch.elapsedMilliseconds / 1000} วินาที ||";
  }

  Future<void> searchNewData() async {
    stopwatch.reset();
    stopwatch.start();
    NewsResponse n = await ApiAction.apiAction.getNewsDataApi(q: searchText);
    List<String> q = await ApiAction.apiAction.separateNounWord(text: searchText!);
    String searchQ = "";
    if (q.length == 1 && !q[0].contains(searchText!)) {
      for (var i = 0; i < q.length; i++) {
        if (i == 0) {
          searchQ += q[i];
        } else {
          searchQ += " OR ${q[i]}";
        }
      }
      n.news!.addAll((await ApiAction.apiAction.getNewsDataApi(q: searchQ)).news!);
    }

    if (n.news!.isEmpty) {
      s += " NewData ธรรมดา ไม่พบข่าวต้องค้นอีก";
      n = await ApiAction.apiAction.getNewsDataApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "en"));
      if (q.length == 1 && !q[0].contains(searchText!)) {
        List<Future<String>> futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "en")).toList();
        q = await Future.wait(futureOrder);
        searchQ = "";
        for (var i = 0; i < q.length; i++) {
          if (i == 0) {
            searchQ += q[i];
          } else {
            searchQ += " OR ${q[i]}";
          }
        }
        n.news!.addAll((await ApiAction.apiAction.getNewsDataApi(q: searchQ)).news!);
      }
    }
    _newsResponse!.news!.addAll(n.news!);
    stopwatch.stop();
    s += " NewsData ธรรมดา ก่อน ใช้เวลาทั้งหมด ${stopwatch.elapsedMilliseconds / 1000} วินาที ";
  }

  Future<void> searchNewDataEngFirst() async {
    stopwatch.reset();
    stopwatch.start();
    NewsResponse n = await ApiAction.apiAction.getNewsDataApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "en"));
    List<String> q = await ApiAction.apiAction.separateNounWord(text: searchText!);
    List<Future<String>> futureOrder;
    List<String> q2;
    String searchQ = "";
    if (q.length == 1 && !q[0].contains(searchText!)) {
      futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "en")).toList();
      q2 = await Future.wait(futureOrder);
      for (var i = 0; i < q2.length; i++) {
        if (i == 0) {
          searchQ += q2[i];
        } else {
          searchQ += " OR ${q2[i]}";
        }
      }
      n.news!.addAll((await ApiAction.apiAction.getNewsDataApi(q: searchQ)).news!);
    }

    if (n.news!.isEmpty) {
      s += " NewData Eng First ไม่พบข่าวต้องค้นอีก";
      n = await ApiAction.apiAction.getNewsDataApi(q: await ApiAction.apiAction.translateText(taget: searchText!, to: "th"));
      searchQ = "";
      if (q.length == 1 && !q[0].contains(searchText!)) {
        futureOrder = q.map((q) => ApiAction.apiAction.translateText(taget: q, to: "th")).toList();
        q = await Future.wait(futureOrder);
        for (var i = 0; i < q.length; i++) {
          if (i == 0) {
            searchQ += q[i];
          } else {
            searchQ += " OR ${q[i]}";
          }
        }
        n.news!.addAll((await ApiAction.apiAction.getBingSearchNewsApi(q: searchQ)).news!);
      }
    }
    _newsResponse!.news!.addAll(n.news!);
    stopwatch.stop();
    s += " NewData ค้นหาด้วย Eng ก่อน ใช้เวลาทั้งหมด ${stopwatch.elapsedMilliseconds / 1000} วินาที ";
  }

  Future<void> getNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      bool EngFirst = false;
      _newsResponse = null;
      s = "";

      if (EngFirst) {
        await searchBingEngFirst();
        await searchNewDataEngFirst();
      } else {
        await searchBing();
        await searchNewData();
      }

      print(s);
      _isLoading = false;
      setState(() {});
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
