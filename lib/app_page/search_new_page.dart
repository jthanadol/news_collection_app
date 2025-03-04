import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'package:news_app/config/auth.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';

class SearchNewPage extends StatefulWidget {
  static const routeName = "/search_new_page";

  const SearchNewPage({super.key});

  @override
  State<SearchNewPage> createState() => _SearchNewPageState();
}

class _SearchNewPageState extends State<SearchNewPage> {
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
  List<String>? popularWords = null; //list คำค้นหายอดฮิต
  List<String>? filteredWords = null;
  String fileName = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getPopularSearch();
  }

  @override
  void dispose() {
    saveNews();
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
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        print(date);
        fileName = '/searchnews_$searchText';
        fileName = fileName.replaceAll('.', '');
        fileName = (await PathFile.pathFile.getCachePath()) + fileName + '.json';
        print(fileName);
        //ตรวจว่ามีไฟล์อยู่ไม
        if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
          //มีไฟล์
          Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: fileName);

          if (date.isAtSameMomentAs(DateTime.parse(data["time"]))) {
            _newsResponse = NewsResponse.fromJson(data['data']);
            print('อ่านไฟล์สำเร็จ');
          } else {
            await ManageFile.manageFile.deleteAllFilesInDir(pathDir: await PathFile.pathFile.getCachePath());

            _newsResponse = await ApiAction.apiAction.searchNews(text: searchText!, accountId: Auth.auth.accountId);
            Map<String, dynamic> data = {
              "data": _newsResponse!.toJson(),
              "time": date.toString(),
            };
            ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
            print('อัพเดทข้อมูลข่าวใหม่สำเร็จ');
          }
        } else {
          //ไม่มีไฟล์
          _newsResponse = await ApiAction.apiAction.searchNews(text: searchText!, accountId: Auth.auth.accountId);
          Map<String, dynamic> data = {
            "data": _newsResponse!.toJson(),
            "time": date.toString(),
          };
          ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
          print('เขียนไฟล์สำเร็จ');
        }

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
          var newsNext = await ApiAction.apiAction.searchNews(text: searchText!, offset: _newsResponse!.news!.length, accountId: Auth.auth.accountId);
          if (newsNext.news!.isEmpty) {
            _isNewsEnd = true;
          } else {
            _newsResponse!.news!.addAll(newsNext.news!);
          }
          await saveNews();
          print('เขียนข้อมูลเพิ่มสำเร็จ');

          setState(() {
            _fillData = false;
          });
        }
      } catch (e) {
        _errorMessage = e.toString();
      }
    }
  }

  Future<void> getPopularSearch() async {
    if (popularWords == null) {
      try {
        popularWords = await ApiAction.apiAction.getPopularSearch();
      } catch (e) {
        popularWords = [];
      }
      filteredWords = List.from(popularWords!);
      setState(() {});
    }
  }

  void onSearchChanged(String search) {
    if (search.isEmpty) {
      filteredWords = List.from(popularWords!);
    } else {
      filteredWords = popularWords!.where((word) => word.toLowerCase().contains(search.toLowerCase())).toList();
    }
    setState(() {});
  }

  Future<void> saveNews() async {
    if (_newsResponse != null) {
      DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      Map<String, dynamic> data = {
        "data": _newsResponse!.toJson(),
        "time": date.toString(),
      };
      await ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
    }
  }

  Future<void> saveImageNews({required int newId, required int newIndex, required String urlImage}) async {
    String imagePath = await PathFile.pathFile.getCachePath();
    imagePath += '/$newId.jpg';
    bool canDownload = await ApiAction.apiAction.downloadImage(url: urlImage, fileName: imagePath);
    if (canDownload) {
      _newsResponse!.news![newIndex].imgUrl = imagePath;
      print('ดาวโหลดรูป ${_newsResponse!.news![newIndex].imgUrl}');
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
                      if (ApiAction.apiAction.isValidUrl(url: _newsResponse!.news![index].imgUrl!)) {
                        if (SettingApp.settingApp.showImageOnline) {
                          image = Image.network(
                            _newsResponse!.news![index].imgUrl!,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            width: 150,
                          );
                          saveImageNews(newId: _newsResponse!.news![index].newId!, newIndex: index, urlImage: _newsResponse!.news![index].imgUrl!);
                        }
                      } else {
                        image = Image.file(
                          File(_newsResponse!.news![index].imgUrl!),
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          width: 150,
                        );
                      }
                    }
                    return ListTile(
                        leading: image,
                        title: Text(
                          (_isTranslate) ? _newsResponse!.news![index].titleTh! : _newsResponse!.news![index].title!,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
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
                                ),
                              ),
                            Text(
                              DateFormat.yMMMEd().format(
                                DateTime.parse(_newsResponse!.news![index].pubDate!),
                              ),
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeCaption,
                              ),
                            ),
                            if (_newsResponse!.news![index].factCheck!.claims!.isEmpty)
                              Container(
                                color: Colors.amber,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline),
                                    SizedBox(width: 8),
                                    Text(
                                      "ไม่พบการตรวจสอบ",
                                      style: TextStyle(
                                        fontSize: SettingApp.settingApp.textSizeCaption,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "พบการตรวจสอบ : ${_newsResponse!.news![index].factCheck!.claims!.length} รายการ",
                                    style: TextStyle(
                                      fontSize: SettingApp.settingApp.textSizeCaption,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      for (int k = 0; k < _newsResponse!.news![index].factCheck!.claims!.length; k++)
                                        for (int j = 0; j < _newsResponse!.news![index].factCheck!.claims![k].claimReview!.length; j++)
                                          Container(
                                            decoration: BoxDecoration(color: (ApiAction.apiAction.checkFact(_newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating!)) ? Colors.greenAccent : Colors.redAccent),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon((ApiAction.apiAction.checkFact(_newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating!)) ? Icons.check : Icons.close),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    (_isTranslate) ? _newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating! : _newsResponse!.news![index].factCheck!.claims![k].claimReview![j].textualRating!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: SettingApp.settingApp.textSizeCaption,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onTap: () async {
                          await saveNews();
                          Navigator.pushNamed(
                            context,
                            ReadNewPage.routeName,
                            arguments: {
                              "index": index,
                              "fileName": fileName,
                            },
                          );
                        });
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

    buildListPopularSearch() => Column(
          children: [
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredWords![index],
                        style: TextStyle(
                          fontSize: SettingApp.settingApp.textSizeBody,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _textEditingController.text = filteredWords![index];
                          searchText = filteredWords![index];
                          onSearchChanged(filteredWords![index]);
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: filteredWords!.length),
            ),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
        ),
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
                    onSearchChanged(value);
                  },
                  onSubmitted: (value) async {
                    await saveNews();
                    searchText = value;

                    setState(() {
                      _isSearchCheck = false;
                    });
                    getNews();
                  },
                  decoration: const InputDecoration(hintText: "คำค้นหา. . ."),
                  style: TextStyle(fontSize: SettingApp.settingApp.textSizeBody),
                ),
              )
            : Text(
                "ค้นหาข่าว",
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH2,
                ),
              ),
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
            iconSize: SettingApp.settingApp.iconSize,
            icon: _isSearchCheck ? const Icon(Icons.close) : const Icon(Icons.search),
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          if (!_isSearchCheck)
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
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      "แปลภาษา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                if (_isSearchCheck && popularWords != null) buildListPopularSearch(),
                if (!_isLoading && _newsResponse != null && !_isSearchCheck) buildPage(),
                if (_isLoading) buildLoadingOverlay(),
                if (_newsResponse == null && !_isSearchCheck && !_isLoading)
                  Center(
                    child: Text(
                      "ยังไม่ได้กรอกคำค้นหา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                      ),
                    ),
                  ),
                if (_errorMessage != null) buildError(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
