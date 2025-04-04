import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_news_page.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';

class OfflineNews extends StatefulWidget {
  const OfflineNews({super.key});
  static const routeName = "/offline_news";

  @override
  State<OfflineNews> createState() => _OfflineNewsState();
}

class _OfflineNewsState extends State<OfflineNews> {
  NewsResponse? _newsResponse;
  bool _isTranslate = true;
  String fileName = '';
  bool _isLastNews = true;
  bool _isDeleteCheck = false;
  List<int> deleteList = [];

  @override
  void initState() {
    super.initState();
    readFile();
  }

  Future<void> readFile() async {
    fileName = '${await PathFile.pathFile.getDocPath()}/offlinenews.json';
    if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
      //ถ้ามีไฟล์
      Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: fileName);
      _newsResponse = NewsResponse.fromJson(data['data']);
    }
    sortNews();
  }

  Future<void> deleteNews() async {
    String path = await PathFile.pathFile.getDocPath();
    if (deleteList.length == _newsResponse!.news!.length) {
      _newsResponse = null;

      ManageFile.manageFile.deleteAllFilesInDir(pathDir: path);
    } else {
      for (var i = 0; i < deleteList.length; i++) {
        ManageFile.manageFile.deleteOneFile(fileName: '$path/${deleteList[i]}.jpg');
        ManageFile.manageFile.deleteOneFile(fileName: '$path/${deleteList[i]}.wav');
        ManageFile.manageFile.deleteOneFile(fileName: '$path/${deleteList[i]}.mp3');
        _newsResponse!.news!.removeWhere((news) => news.newsId == deleteList[i]);
      }
      deleteList = [];
      Map<String, dynamic> data = {"data": _newsResponse!.toJson()};
      await ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
    }

    setState(() {});
  }

  void sortNews() {
    if (_newsResponse != null && _newsResponse!.news != null) {
      setState(() {
        if (_isLastNews) {
          _newsResponse!.news!.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
        } else {
          _newsResponse!.news!.sort((a, b) => a.pubDate!.compareTo(b.pubDate!));
        }
      });
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
                  itemBuilder: (context, index) {
                    Image? image;
                    if (_newsResponse!.news![index].imgUrl != null) {
                      image = Image.file(
                        File(_newsResponse!.news![index].imgUrl!),
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        fit: BoxFit.cover,
                      );
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
                            trailing: (_isDeleteCheck)
                                ? Icon(
                                    (deleteList.contains(_newsResponse!.news![index].newsId!)) ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: (deleteList.contains(_newsResponse!.news![index].newsId!)) ? Colors.red : SettingApp.settingApp.colorIcon,
                                    size: SettingApp.settingApp.iconSize,
                                  )
                                : null,
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
                            onTap: (_isDeleteCheck)
                                ? () {
                                    setState(() {
                                      if (deleteList.contains(_newsResponse!.news![index].newsId)) {
                                        deleteList.remove(_newsResponse!.news![index].newsId);
                                      } else {
                                        deleteList.add(_newsResponse!.news![index].newsId!);
                                      }
                                    });
                                  }
                                : () async {
                                    Navigator.pushNamed(
                                      context,
                                      ReadNewsPage.routeName,
                                      arguments: {
                                        "index": index,
                                        "fileName": fileName,
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
                  itemCount: _newsResponse!.news!.length),
            ),
            if (_isDeleteCheck)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                  backgroundColor: SettingApp.settingApp.colorButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
                ),
                onPressed: () {
                  if (deleteList.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: SettingApp.settingApp.colorButton,
                          title: Text(
                            'ต้องการลบข้อมูลของข่าวที่บันทึก ${deleteList.length} หรือไม่ ?',
                            style: TextStyle(
                              fontSize: SettingApp.settingApp.textSizeBody,
                              color: SettingApp.settingApp.colorText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'ยกเลิก',
                                  style: TextStyle(
                                    fontSize: SettingApp.settingApp.textSizeButton,
                                    color: SettingApp.settingApp.colorTextButton,
                                  ),
                                )),
                            TextButton(
                                onPressed: () {
                                  deleteNews();
                                  _isDeleteCheck = false;
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'ตกลง',
                                  style: TextStyle(
                                    fontSize: SettingApp.settingApp.textSizeButton,
                                    color: Colors.red,
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'ลบข่าวจำนวน ${deleteList.length} รายการ',
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeButton,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
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
        title: Text(
          'ข่าวที่บันทึก',
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
            color: SettingApp.settingApp.colorText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isDeleteCheck)
            IconButton(
              onPressed: () {
                if (_newsResponse != null) {
                  setState(() {
                    if (_newsResponse!.news!.length == deleteList.length) {
                      deleteList = [];
                    } else {
                      deleteList = [];
                      for (var i = 0; i < _newsResponse!.news!.length; i++) {
                        deleteList.add(_newsResponse!.news![i].newsId!);
                      }
                    }
                  });
                }
              },
              iconSize: SettingApp.settingApp.iconSize,
              icon: Icon(
                (_newsResponse != null)
                    ? (deleteList.length == _newsResponse!.news!.length)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank
                    : Icons.check_box_outline_blank,
                color: (_newsResponse != null)
                    ? (deleteList.length == _newsResponse!.news!.length)
                        ? Colors.red
                        : SettingApp.settingApp.colorIcon
                    : SettingApp.settingApp.colorIcon,
              ),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _isDeleteCheck = !_isDeleteCheck;
                if (!_isDeleteCheck) {
                  deleteList = [];
                }
              });
            },
            iconSize: SettingApp.settingApp.iconSize,
            icon: Icon(
              Icons.delete,
              color: (_isDeleteCheck) ? Colors.red : SettingApp.settingApp.colorIcon,
            ),
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
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isLastNews = !_isLastNews;
                    });
                    sortNews();
                  },
                  icon: Icon(
                    Icons.swap_vert,
                    color: (!_isLastNews) ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                    size: SettingApp.settingApp.iconSize,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_newsResponse != null && _newsResponse!.news!.isNotEmpty)
                  buildPage()
                else
                  Center(
                    child: Text(
                      'ไม่มีข่าวที่บันทึก',
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
