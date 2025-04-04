import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_news_page.dart';
import 'package:news_app/config/auth.dart';
import 'package:news_app/config/setting_app.dart';

class SearchNewsPage extends StatefulWidget {
  static const routeName = "/search_news_page";

  const SearchNewsPage({super.key});

  @override
  State<SearchNewsPage> createState() => _SearchNewsPageState();
}

class _SearchNewsPageState extends State<SearchNewsPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSearchCheck = true;
  String? searchText = '';
  bool _isLoading = false;
  bool _fillData = false;
  bool _isTranslate = true;
  String? _errorMessage;
  NewsResponse? _newsResponse;
  final ScrollController _scrollController = ScrollController();
  bool _isNewsEnd = false; //ข้อมูลที่ขอกับ server หมดหรือยังถ้ายังเป็น false
  List<String>? popularWords; //list คำค้นหายอดฮิต
  List<String>? filteredWords;
  List<String>? historySearch;
  List<String>? historyDate;
  bool _openHistory = false;
  bool _isNewsFromWaitBingSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getPopularSearch();
    getHistorySearch();
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
    if (searchText!.trim().isNotEmpty) {
      if (await ApiAction.apiAction.checkInternet()) {
        try {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          getNewsButWaitBingSearch(searchText!);
          NewsResponse newsResponse = await ApiAction.apiAction.searchNews(text: searchText!, accountId: Auth.auth.accountId, waitBingSearch: false);
          if (!_isNewsFromWaitBingSearch) {
            _newsResponse = newsResponse;
          }

          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          _errorMessage = e.toString();
        }
      } else {
        setState(() {
          _newsResponse = null;
          _errorMessage = 'ยังไม่ได้ทำการเชื่อมต่ออินเตอร์เน็ต';
        });
      }
    }
  }

  Future<void> getNewsNextPage() async {
    if (await ApiAction.apiAction.checkInternet()) {
      if (!_fillData) {
        try {
          if (!_isNewsEnd) {
            setState(() {
              _errorMessage = null;
              _fillData = true;
            });
            var newsNext = await ApiAction.apiAction.searchNews(text: searchText!, offset: _newsResponse!.news!.length, accountId: Auth.auth.accountId, waitBingSearch: false);
            if (newsNext.news!.isEmpty) {
              _isNewsEnd = true;
            } else {
              _newsResponse!.news!.addAll(newsNext.news!);
            }

            setState(() {
              _fillData = false;
            });
          }
        } catch (e) {
          _errorMessage = e.toString();
        }
      }
    }
  }

  Future<void> getNewsButWaitBingSearch(String text) async {
    NewsResponse newsResponse = await ApiAction.apiAction.searchNews(text: text, accountId: Auth.auth.accountId, waitBingSearch: true);
    bool repeatedNews = true;
    if (_newsResponse != null) {
      for (var i = 0; i < newsResponse.news!.length; i++) {
        if (jsonEncode(_newsResponse!.news![i].toJson()) != jsonEncode(newsResponse.news![i].toJson())) {
          print("ช่องที่ $i ไม่เท่ากัน");
          repeatedNews = false;
          break;
        }
      }
    }
    if (!repeatedNews) {
      if (text == searchText) {
        setState(() {
          _newsResponse = newsResponse;
          _isNewsFromWaitBingSearch = true;
          _isLoading = true;
        });
        Timer.periodic(
          const Duration(milliseconds: 800),
          (timer) {
            setState(() {
              _isLoading = false;
            });
          },
        );
      }
    }
  }

  Future<void> getPopularSearch() async {
    try {
      if (popularWords == null) {
        try {
          popularWords = await ApiAction.apiAction.getPopularSearch();
        } catch (e) {
          popularWords = [];
        }
        filteredWords = List.from(popularWords!);
        setState(() {});
      }
    } catch (e) {}
  }

  Future<void> getHistorySearch() async {
    try {
      if (historySearch == null || historyDate == null) {
        var res = await ApiAction.apiAction.getHistorySearch(accountId: Auth.auth.accountId);
        if (res.isNotEmpty) {
          historySearch = res[0];
          historyDate = res[1];
        } else {
          historySearch = [];
          historyDate = [];
        }
      }
    } catch (e) {
      historySearch = [];
      historyDate = [];
    }
    setState(() {});
  }

  void onSearchChanged(String search) {
    if (search.isEmpty) {
      filteredWords = List.from(popularWords!);
    } else {
      filteredWords = popularWords!.where((word) => word.toLowerCase().contains(search.toLowerCase())).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    buildHistoryPage() => (historySearch != null && historySearch!.isNotEmpty)
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            leading: Icon(
                              Icons.history,
                              color: SettingApp.settingApp.colorIcon,
                            ),
                            tileColor: SettingApp.settingApp.colorButton,
                            title: Text(
                              historySearch![index],
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeBody,
                                color: SettingApp.settingApp.colorText,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMEd().format(
                                DateTime.parse(historyDate![index]),
                              ),
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeCaption,
                                color: SettingApp.settingApp.colorText,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _textEditingController.text = historySearch![index];
                                searchText = historySearch![index];
                                _openHistory = false;
                                _isSearchCheck = true;
                              });
                            },
                          ),
                          Divider(
                            color: SettingApp.settingApp.colorLine,
                            height: 3,
                            thickness: 3,
                          ),
                        ],
                      );
                    },
                    itemCount: historySearch!.length),
              ),
            ],
          )
        : Center(
            child: Text(
              'ไม่พบประวัติการค้นหา',
              style: TextStyle(
                color: SettingApp.settingApp.colorText,
                fontWeight: FontWeight.bold,
                fontSize: SettingApp.settingApp.textSizeH3,
              ),
            ),
          );

    buildPage() => Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    Image? image;
                    if (_newsResponse!.news![index].imgUrl != null) {
                      if (ApiAction.apiAction.isValidUrl(url: _newsResponse!.news![index].imgUrl!)) {
                        if (SettingApp.settingApp.showImageOnline) {
                          image = Image.network(
                            _newsResponse!.news![index].imgUrl!,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            width: 150,
                          );
                        }
                      } else {
                        image = Image.file(
                          File(_newsResponse!.news![index].imgUrl!),
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          width: 150,
                        );
                      }
                    }
                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.96,
                          decoration: BoxDecoration(
                            color: SettingApp.settingApp.colorButton,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: SettingApp.settingApp.colorShadow,
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.35,
                              ),
                              child: image,
                            ),
                            title: Text(
                              (_isTranslate) ? _newsResponse!.news![index].titleTh! : _newsResponse!.news![index].title!,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeBody,
                                color: SettingApp.settingApp.colorText,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    style: TextStyle(
                                      fontSize: SettingApp.settingApp.textSizeCaption,
                                      color: SettingApp.settingApp.colorText,
                                    ),
                                  ),
                                Text(
                                  DateFormat.yMMMEd().format(
                                    DateTime.parse(_newsResponse!.news![index].pubDate!),
                                  ),
                                  style: TextStyle(
                                    fontSize: SettingApp.settingApp.textSizeCaption,
                                    color: SettingApp.settingApp.colorText,
                                  ),
                                ),
                                if (_newsResponse!.news![index].factCheck!.claims!.isEmpty)
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "ไม่พบการตรวจสอบ",
                                              style: TextStyle(
                                                fontSize: SettingApp.settingApp.textSizeCaption,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        "พบการตรวจสอบ : ${_newsResponse!.news![index].factCheck!.claims!.length} รายการ",
                                        style: TextStyle(
                                          fontSize: SettingApp.settingApp.textSizeCaption,
                                          color: SettingApp.settingApp.colorText,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int k = 0; k < _newsResponse!.news![index].factCheck!.claims!.length; k++)
                                            for (int j = 0; j < _newsResponse!.news![index].factCheck!.claims![k].claimReview!.length; j++)
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: (ApiAction.apiAction.checkFact(_newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating!)) ? Colors.greenAccent : Colors.redAccent,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        (ApiAction.apiAction.checkFact(_newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating!)) ? Icons.check : Icons.close,
                                                        color: Colors.black,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          (_isTranslate) ? _newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating! : _newsResponse!.news![index].factCheck!.claims![k].claimReview![j].textualRating!,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: SettingApp.settingApp.textSizeCaption,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ReadNewsPage.routeName,
                                arguments: {
                                  "index": index,
                                  "fileName": '',
                                  "new": _newsResponse!.news![index],
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    );
                  },
                  controller: _scrollController,
                  itemCount: _newsResponse!.news!.length),
            ),
            if (_fillData)
              Text(
                "กำลังโหลดข้อมูลเพิ่มเติม . . .",
                style: TextStyle(
                  color: SettingApp.settingApp.colorText,
                  fontSize: SettingApp.settingApp.textSizeBody,
                ),
              ),
          ],
        );

    buildErrorPage() => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: SettingApp.settingApp.textSizeH2,
                fontWeight: FontWeight.bold,
                color: SettingApp.settingApp.colorText,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                  backgroundColor: SettingApp.settingApp.colorButton,
                  side: BorderSide(
                    color: SettingApp.settingApp.colorIconHighlight,
                    width: 3,
                  )),
              onPressed: () {
                getNews();
              },
              label: Text(
                'รีเฟรช',
                style: TextStyle(
                  color: SettingApp.settingApp.colorText,
                  fontSize: SettingApp.settingApp.textSizeButton,
                ),
              ),
              icon: Icon(
                Icons.refresh,
                size: SettingApp.settingApp.iconSize,
                color: SettingApp.settingApp.colorIcon,
              ),
            ),
          ],
        );

    buildLoadingOverlay() => Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
            child: CircularProgressIndicator(
          color: SettingApp.settingApp.colorIconHighlight,
        )));

    buildListPopularSearch() => Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            (historySearch == null) ? Icons.trending_up : (historySearch!.contains(filteredWords![index]) ? Icons.history : Icons.trending_up),
                            color: SettingApp.settingApp.colorIcon,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tileColor: SettingApp.settingApp.colorButton,
                          title: Text(
                            filteredWords![index],
                            style: TextStyle(
                              fontSize: SettingApp.settingApp.textSizeBody,
                              color: SettingApp.settingApp.colorText,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _textEditingController.text = filteredWords![index];
                              searchText = filteredWords![index];
                              onSearchChanged(filteredWords![index]);
                            });
                          },
                        ),
                        Divider(
                          color: SettingApp.settingApp.colorLine,
                          height: 3,
                          thickness: 3,
                        ),
                      ],
                    );
                  },
                  itemCount: filteredWords!.length),
            ),
          ],
        );

    return Scaffold(
      backgroundColor: SettingApp.settingApp.colorBackground,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: (SettingApp.settingApp.darkThemp)
                ? []
                : [
                    BoxShadow(
                      color: SettingApp.settingApp.colorShadow,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
            image: DecorationImage(
              image: (SettingApp.settingApp.darkThemp) ? const AssetImage('assets/img/appbar_dark.jpg') : const AssetImage('assets/img/appbar_light.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
          color: SettingApp.settingApp.colorIcon,
        ),
        centerTitle: true,
        title: _isSearchCheck
            ? Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    onSearchChanged(value);
                  },
                  onSubmitted: (value) {
                    searchText = value;

                    setState(() {
                      _isSearchCheck = false;
                    });
                    getNews();
                  },
                  decoration: InputDecoration(
                    hintText: "คำค้นหา. . .",
                    hintStyle: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                      color: SettingApp.settingApp.colorText,
                    ),
                    filled: true,
                    fillColor: SettingApp.settingApp.colorBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: SettingApp.settingApp.colorIconHighlight,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: SettingApp.settingApp.colorIconHighlight,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: SettingApp.settingApp.colorIconHighlight,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                    color: SettingApp.settingApp.colorText,
                  ),
                ),
              )
            : Text(
                "ค้นหาข่าว",
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH2,
                  color: SettingApp.settingApp.colorText,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (!_isSearchCheck)
            IconButton(
              onPressed: () {
                setState(() {
                  _openHistory = !_openHistory;
                  if (historySearch == null) {
                    getHistorySearch();
                  }
                });
              },
              icon: Icon(
                Icons.history,
                color: (_openHistory) ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
              ),
              iconSize: SettingApp.settingApp.iconSize,
            ),
          IconButton(
            onPressed: () {
              setState(() {
                setState(() {
                  _isSearchCheck = !_isSearchCheck;
                  _openHistory = false;

                  if (!_isSearchCheck) {
                    _textEditingController.clear();
                    searchText = null;
                  }
                });
              });
            },
            iconSize: SettingApp.settingApp.iconSize,
            icon: _isSearchCheck ? const Icon(Icons.close) : const Icon(Icons.search),
            color: SettingApp.settingApp.colorIcon,
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          if (!_isSearchCheck && !_openHistory)
            Container(
              decoration: BoxDecoration(
                color: SettingApp.settingApp.colorButton,
                boxShadow: [
                  BoxShadow(
                    color: SettingApp.settingApp.colorShadow,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.scale(
                    scale: (SettingApp.settingApp.appSize.contains('big')) ? 1.2 : (SettingApp.settingApp.appSize.contains('small') ? 0.8 : 1),
                    child: Checkbox(
                      checkColor: SettingApp.settingApp.colorButton,
                      focusColor: SettingApp.settingApp.colorIconHighlight,
                      activeColor: SettingApp.settingApp.colorIconHighlight,
                      value: _isTranslate,
                      onChanged: (value) {
                        setState(() {
                          _isTranslate = value!;
                        });
                        //
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "แปลภาษา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeButton,
                        color: SettingApp.settingApp.colorText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                if (_openHistory) buildHistoryPage(),
                if (_errorMessage != null && !_isSearchCheck && !_openHistory) buildErrorPage(),
                if (_isSearchCheck && popularWords != null && !_openHistory) buildListPopularSearch(),
                if (!_isLoading && _newsResponse != null && !_isSearchCheck && !_openHistory) buildPage(),
                if (_isLoading) buildLoadingOverlay(),
                if (_newsResponse == null && !_isSearchCheck && !_isLoading && _errorMessage == null && !_openHistory)
                  Center(
                    child: Text(
                      "ยังไม่ได้กรอกคำค้นหา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: SettingApp.settingApp.colorText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
