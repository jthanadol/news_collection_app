import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';
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
    setState(() {});
  }

  Future<void> deleteAllNews() async {
    _newsResponse = null;
    String fileName = '${await PathFile.pathFile.getDocPath()}/offlinenews.json';
    ManageFile.manageFile.deleteOneFile(fileName: fileName);
    setState(() {});
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
                    //เช็คว่าเป็น url ไม
                    if (ApiAction.apiAction.isValidUrl(url: _newsResponse!.news![index].imgUrl!)) {
                      image = Image.network(
                        _newsResponse!.news![index].imgUrl!,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        width: 150,
                      );
                    } else {
                      image = Image.file(
                        File(_newsResponse!.news![index].imgUrl!),
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        width: 150,
                      );
                    }
                  } else {
                    image = null;
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
                                                style: TextStyle(
                                                  fontSize: SettingApp.settingApp.textSizeCaption,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
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
                    onTap: () => Navigator.pushNamed(
                      context,
                      ReadNewPage.routeName,
                      arguments: {
                        "index": index,
                        "fileName": fileName,
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'ต้องการลบข้อมูลของข่าวที่บันทึกทั้งหมดหรือไม่ ?',
                        style: TextStyle(
                          fontSize: SettingApp.settingApp.textSizeBody,
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
                              ),
                            )),
                        TextButton(
                            onPressed: () {
                              deleteAllNews();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'ตกลง',
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            )),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  Text(
                    'ลบทั้งหมด',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeButton,
                    ),
                  ),
                ],
              ),
            )
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
        title: Text(
          'ข่าวที่บันทึก',
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_newsResponse != null && _newsResponse!.news!.isNotEmpty)
            buildPage()
          else
            Center(
              child: Text(
                'ไม่มีข่าวที่บันทึก',
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeBody,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
