import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_news_page.dart';
import 'package:news_app/app_page/search_news_page.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/server_config.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';

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

  String fileName = ''; //ไฟล์ cache ที่อ่านล่าสุด

  String _country = "th";
  String _category = 'ธุรกิจ';
  String _date = 'last';
  final category = ServerConfig.serverConfig.category;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    saveNews();
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    }
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
      String dirFile = await PathFile.pathFile.getCachePath() + '/TH';
      await ManageFile.manageFile.createDir(dirPath: dirFile);
      fileName = '$dirFile/$_country${category[_category]!}$_date.json';
      print(fileName);
      //ตรวจว่ามีไฟล์อยู่ไม
      if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
        //มีไฟล์
        Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: fileName);

        if (date.isAtSameMomentAs(DateTime.parse(data["time"]))) {
          _newsResponse = NewsResponse.fromJson(data['data']);
          print('อ่านไฟล์สำเร็จ');
        } else {
          _newsResponse = NewsResponse.fromJson(data['data']);
          deleteCacheAndGetNews(dirFile, fileName);
        }
      } else {
        //ไม่มีไฟล์
        if (await ApiAction.apiAction.checkInternet()) {
          _newsResponse = await ApiAction.apiAction.getNews(country: _country, category: category[_category]!, date: _date);
          Map<String, dynamic> data = {
            "data": _newsResponse!.toJson(),
            "time": date.toString(),
          };
          ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
          print('เขียนไฟล์สำเร็จ');
        } else {
          setState(() {
            _errorMessage = 'โปรดเชื่อมต่ออินเตอร์เน็ต';
            _newsResponse = null;
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
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

            var newsNext = await ApiAction.apiAction.getNews(country: _country, category: category[_category]!, date: _date, offset: _newsResponse!.news!.length);

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
  }

  Future<void> deleteCacheAndGetNews(String dirFile, String file) async {
    if (await ApiAction.apiAction.checkInternet()) {
      NewsResponse newsResponse = await ApiAction.apiAction.getNews(country: _country, category: category[_category]!, date: _date);
      if (file == fileName) {
        await ManageFile.manageFile.deleteAllFilesInDir(pathDir: dirFile);
        setState(() {
          _newsResponse = newsResponse;
          _isLoading = true;
        });
        if (_timer != null) {
          if (_timer!.isActive) {
            _timer!.cancel();
          }
        }
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            setState(() {
              _isLoading = false;
            });
          },
        );
        saveNews();
      }
      print('อัพเดทข้อมูลข่าวใหม่สำเร็จ');
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
    if (await ApiAction.apiAction.checkInternet()) {
      String imagePath = await PathFile.pathFile.getCachePath();
      imagePath += '/$newId.jpg';
      bool canDownload = await ApiAction.apiAction.downloadFile(url: urlImage, fileName: imagePath);
      if (canDownload) {
        _newsResponse!.news![newIndex].imgUrl = imagePath;
        print('ดาวโหลดรูป ${_newsResponse!.news![newIndex].imgUrl}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    buildPage() => Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _newsResponse!.news!.length,
                itemBuilder: (context, index) {
                  Image? image;
                  if (_newsResponse!.news![index].imgUrl != null) {
                    if (ApiAction.apiAction.isValidUrl(url: _newsResponse!.news![index].imgUrl!)) {
                      if (SettingApp.settingApp.showImageOnline) {
                        image = Image.network(
                          _newsResponse!.news![index].imgUrl!,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          fit: BoxFit.cover,
                        );
                        saveImageNews(newId: _newsResponse!.news![index].newsId!, newIndex: index, urlImage: _newsResponse!.news![index].imgUrl!);
                      }
                    } else {
                      image = Image.file(
                        File(_newsResponse!.news![index].imgUrl!),
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        fit: BoxFit.cover,
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
                            _newsResponse!.news![index].titleTh!,
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
                              if (_newsResponse!.news![index].descriptionTh != null)
                                Text(
                                  _newsResponse!.news![index].descriptionTh!,
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
                                                        _newsResponse!.news![index].factCheckTh!.claims![k].claimReview![j].textualRating!,
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
                          onTap: () async {
                            await saveNews();
                            await Navigator.pushNamed(
                              context,
                              ReadNewsPage.routeName,
                              arguments: {
                                "index": index,
                                "fileName": fileName,
                                "new": _newsResponse!.news![index],
                              },
                            );
                            await getNews();
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

    buildLoadingOverlay() => Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
            child: CircularProgressIndicator(
          color: SettingApp.settingApp.colorIconHighlight,
        )));

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
            const SizedBox(
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
        automaticallyImplyLeading: false,
        title: Text(
          "ข่าวประเทศไทย",
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
            color: SettingApp.settingApp.colorText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              saveNews();
              Navigator.pushNamed(context, SearchNewsPage.routeName);
            },
            icon: Icon(
              Icons.search,
              size: SettingApp.settingApp.iconSize,
            ),
            color: SettingApp.settingApp.colorIcon,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SettingApp.settingApp.colorButton,
              boxShadow: [
                BoxShadow(
                  color: SettingApp.settingApp.colorShadow,
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "หมวดข่าว",
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeButton,
                      color: SettingApp.settingApp.colorText,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
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
                            color: SettingApp.settingApp.colorText,
                          ),
                        ),
                      );
                    }).toList(),
                    value: _category,
                    iconSize: SettingApp.settingApp.iconSize,
                    dropdownColor: SettingApp.settingApp.colorButton,
                    iconEnabledColor: SettingApp.settingApp.colorIcon,
                    iconDisabledColor: SettingApp.settingApp.colorIcon,
                  ),
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
                    Icons.swap_vert,
                    color: (!_isLast) ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                    size: SettingApp.settingApp.iconSize,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_errorMessage != null) buildErrorPage(),
                if (!_isLoading && _newsResponse != null) buildPage(),
                if (!_isLoading && _newsResponse != null && _newsResponse!.news!.isEmpty)
                  Center(
                    child: Text(
                      "ไม่มีข่าว",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: SettingApp.settingApp.colorText,
                      ),
                    ),
                  ),
                if (_isLoading) buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
