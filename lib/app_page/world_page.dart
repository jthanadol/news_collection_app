import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'package:news_app/app_page/search_new_page.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/server_config.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';

class WorldPage extends StatefulWidget {
  static const routeName = "/world_page"; //ชื่อที่ใช้อ้างถึงหน้านี้
  const WorldPage({super.key});

  @override
  State<WorldPage> createState() => _WorldPageState();
}

class _WorldPageState extends State<WorldPage> {
  NewsResponse? _newsResponse; //เก็บข่าวที่จะใช้แสดงบนหน้าจอ
  bool _isLoading = false; //สถานะการโหลดข้อมูลข่าวใหม่
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  bool _fillData = false; //สถานะการเติมข้อมูลข่าว
  bool _isTranslate = true; //สถานะว่าจะแสดงแบบแปลภาษาหรือไม่
  bool _isNewsEnd = false; //ข้อมูลที่ขอกับ server หมดหรือยังถ้ายังเป็น false
  bool _isLast = true; //true เรียงข่าวจากล่าสุด

  String fileName = ''; //ไฟล์ cache ที่อ่านล่าสุด

  String? _country = 'สหรัฐอเมริกา';
  String _category = 'ธุรกิจ';
  String _date = 'last';
  final category = ServerConfig.serverConfig.category;
  final country = ServerConfig.serverConfig.country;

  @override
  void initState() {
    super.initState();
    getNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    saveNews();
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
      DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      print(date);
      fileName = await PathFile.pathFile.getCachePath() + '/${country[_country]}${category[_category]!}$_date.json';
      print(fileName);

      //ตรวจว่ามีไฟล์อยู่ไม
      if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
        //มีไฟล์
        Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: fileName);
        if (date.isAtSameMomentAs(DateTime.parse(data["time"]))) {
          _newsResponse = NewsResponse.fromJson(data['data']);
          print('อ่านไฟล์สำเร็จ');
        } else {
          _newsResponse = await ApiAction.apiAction.getNews(country: country[_country]!, category: category[_category]!, date: _date);
          Map<String, dynamic> data = {
            "data": _newsResponse!.toJson(),
            "time": date.toString(),
          };
          ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
          print('อัพเดทข้อมูลข่าวใหม่สำเร็จ');
        }
      } else {
        //ไม่มีไฟล์
        _newsResponse = await ApiAction.apiAction.getNews(country: country[_country]!, category: category[_category]!, date: _date);
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

  Future<void> getNewsNextPage() async {
    if (!_fillData) {
      try {
        if (!_isNewsEnd) {
          setState(() {
            _errorMessage = null;
            _fillData = true;
          });
          var newsNext = await ApiAction.apiAction.getNews(country: country[_country]!, category: category[_category]!, date: _date, offset: _newsResponse!.news!.length);
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
                itemCount: _newsResponse!.news!.length,
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
              ),
            ),
            if (_fillData)
              Text(
                "กำลังโหลดข้อมูลเพิ่มเติม . . .",
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeBody,
                ),
              ),
          ],
        );

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

    buildErrorPage() => Center(
          child: Text(_errorMessage!),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "ข่าวต่างประเทศ",
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
          ),
        ),
        backgroundColor: Colors.black12,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              saveNews();
              Navigator.pushNamed(context, SearchNewPage.routeName);
            },
            icon: Icon(
              Icons.search,
              size: SettingApp.settingApp.iconSize,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
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
                      Row(
                        children: [
                          Text(
                            "หมวด",
                            style: TextStyle(
                              fontSize: SettingApp.settingApp.textSizeBody,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: DropdownButton<String>(
                              isExpanded: false,
                              onChanged: (String? newValue) async {
                                await saveNews();
                                setState(() {
                                  _category = newValue!;
                                });
                                getNews();
                              },
                              items: category.keys.toList().map<DropdownMenuItem<String>>((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: SettingApp.settingApp.textSizeButton,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: _category,
                              iconSize: SettingApp.settingApp.iconSize,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () async {
                          await saveNews();
                          setState(() {
                            _isLast = !_isLast;
                            _date = (_isLast) ? 'last' : 'old';
                            getNews();
                          });
                        },
                        icon: Icon(
                          Icons.filter_alt,
                          color: (!_isLast) ? Colors.red : Colors.grey,
                          size: SettingApp.settingApp.iconSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          "ประเทศ",
                          style: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: DropdownButton<String>(
                          isExpanded: false,
                          onChanged: (String? newValue) async {
                            await saveNews();
                            setState(() {
                              _country = newValue!;
                            });
                            getNews();
                          },
                          items: country.keys.toList().map<DropdownMenuItem<String>>((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(
                                country,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeButton,
                                ),
                              ),
                            );
                          }).toList(),
                          value: _country,
                          iconSize: SettingApp.settingApp.iconSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_isLoading && _newsResponse != null) buildPage(),
                if (!_isLoading && _newsResponse!.news!.isEmpty)
                  Center(
                    child: Text(
                      "ไม่มีข่าว",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                      ),
                    ),
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
