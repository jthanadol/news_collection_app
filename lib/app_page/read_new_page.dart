import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';

class ReadNewPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
  String path = '';
  int indexNew = -1;
  News? _news;
  bool _getContent = false; //
  bool _isLoading = false; //สถานะการโหลดข้อมูล
  bool _isTranslate = true; //สถานะการแปล
  String? _errorMessage;
  bool _isLoadingAudioFile = false;
  bool _getAudioFile = false; //สถานะรับรายชื่อไฟล์เสียง ถ้าเป็น true แปลว่ารับไฟล์เสียงแล้ว
  bool _isPlayAudioTh = false;
  bool _isPlayAudioEn = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConcatenatingAudioSource _playList;

  Color colorTranslate = Colors.blue;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: path);
      NewsResponse newsResponse = NewsResponse.fromJson(data['data']);

      if (newsResponse.news![indexNew].content == null || newsResponse.news![indexNew].content!.isEmpty) {
        List<String> content = await ApiAction.apiAction.getContent(id: newsResponse.news![indexNew].newId!);
        if (content[0].isNotEmpty) {
          newsResponse.news![indexNew].content = content[0];
          newsResponse.news![indexNew].contentTh = content[1];
          data['data'] = newsResponse.toJson();
          await ManageFile.manageFile.writeFileJson(fileName: path, data: data);
        } else {
          newsResponse.news![indexNew].content = "";
          newsResponse.news![indexNew].contentTh = "";
        }
      } else {
        print('มีเนิ้อหาข่าวอยู่แล้ว');
        _getContent = true;
      }
      _news = newsResponse.news![indexNew];

      getAudio();
      // print(_news!.content!.split('\n'));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getAudio() async {
    if (!_isLoadingAudioFile) {
      _isLoadingAudioFile = !_isLoadingAudioFile;

      if (!_getAudioFile) {
        if (_news!.audioTh != null) {
          _getAudioFile = true;
        } else {
          var res = await ApiAction.apiAction.getAudio(id: _news!.newId!);
          if (res[0] == 'ส่งรายชื่อไฟล์สำเร็จ') {
            _news!.audioTh = res[1];
            _news!.audioEn = res[2];

            _getAudioFile = true;
          } else if (res[0] == 'ไม่สามารแปลงเสียงได้') {
            _getAudioFile = true;
          }
        }
      }
      _isLoadingAudioFile = !_isLoadingAudioFile;
      setState(() {});
    }
  }

  Future<void> playAudio(String playFile) async {
    var listAudios = [];
    if (playFile == 'th') {
      _isPlayAudioTh = !_isPlayAudioTh;

      listAudios = _news!.audioTh!;
      if (_isPlayAudioTh && _isPlayAudioEn) {
        _isPlayAudioEn = false;

        _audioPlayer.stop();
      }
    } else if (playFile == 'en') {
      _isPlayAudioEn = !_isPlayAudioEn;

      listAudios = _news!.audioEn!;
      if (_isPlayAudioEn && _isPlayAudioTh) {
        _isPlayAudioTh = false;

        _audioPlayer.stop();
      }
    }
    setState(() {});
    print(_isPlayAudioTh.toString() + ' ' + _isPlayAudioEn.toString());
    if (_isPlayAudioTh || _isPlayAudioEn) {
      _playList = ConcatenatingAudioSource(children: listAudios.map((i) => AudioSource.uri(Uri.parse(i))).toList());
      _audioPlayer.setAudioSource(_playList);
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }
  }

  Future<void> saveNew() async {
    String path = await PathFile.pathFile.getDocPath();
    final file = File('$path/offlinenews.json');
    //น่าจะต้องมีโหลดรูปด้วย
    String imagePath = '${await PathFile.pathFile.getDocPath()}/${_news!.newId}.jpg';
    if (_news!.imgUrl != null) {
      if (ApiAction.apiAction.isValidUrl(url: _news!.imgUrl!)) {
        print('เป็น URL');

        //ถ้าไม่มีไฟล์แปลว่ารูปนี้ไม่เคยโหลด
        bool canDownloadImage = true;
        //ถ้าไม่มีไฟล์ในโฟเดอ doc ของ app
        if (!(await ManageFile.manageFile.checkFileExists(fileName: imagePath))) {
          canDownloadImage = await ApiAction.apiAction.downloadImage(url: _news!.imgUrl!, fileName: imagePath);
        }
        _news!.imgUrl = (canDownloadImage) ? imagePath : _news!.imgUrl;
      } else {
        print('เป็นไฟล์ในเครื่อง');
        //ถ้าไม่มีไฟล์ในโฟเดอ doc ของ app
        if (!(await ManageFile.manageFile.checkFileExists(fileName: imagePath))) {
          var bytes = await ManageFile.manageFile.readFileBytes(fileName: _news!.imgUrl!);
          await ManageFile.manageFile.writeFileBytes(fileName: imagePath, bytes: bytes);
          _news!.imgUrl = imagePath;
          print('คัดลอกรูปจาก cache ไปเก็บใน doc สำเร็จ');
        }
      }
    }

    if (await file.exists()) {
      //มีไฟล์
      String jsonString = await file.readAsString();
      NewsResponse news = NewsResponse.fromJson(json.decode(jsonString));
      news.news!.add(_news!);
      Map<String, dynamic> data = news.toJson();
      jsonString = json.encode(data);
      await file.writeAsString(jsonString);
    } else {
      //ไม่มีไฟล์
      Map<String, dynamic> data = {
        "data": {
          "results": [_news!.toJson()]
        }
      };
      String jsonString = json.encode(data);
      await file.writeAsString(jsonString);
    }
    print('บันทึกไฟล์สำเร็จ');
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    if (!_getContent) {
      indexNew = arguments['index'];
      path = arguments['fileName'];
      print(indexNew);
      print(path);
      getData();
      _getContent = true;
    }

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

    buildContent() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SelectableText(
                (_isTranslate) ? _news!.contentTh! : _news!.content!,
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeBody,
                ),
              ),
            ],
          ),
        );

    buildFactCheck() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_news!.factCheck!.claims!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "การตรวจสอบข้อเท็จจริงของข่าวที่พบทั้งหมด ${_news!.factCheck!.claims!.length} : ",
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "ไม่พบการตรวจสอบข้อเท็จจริงของข่าว",
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                  ),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _isTranslate ? _news!.factCheckTh!.claims![index].text! : _news!.factCheck!.claims![index].text!,
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _news!.factCheck!.claims![index].claimReview!.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ข้อมูลการตรวจสอบ : ${(_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].textualRating : _news!.factCheck!.claims![index].claimReview![i].textualRating}",
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeBody,
                              ),
                            ),
                            Text(
                              (_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].title! : _news!.factCheck!.claims![index].claimReview![i].title!,
                              style: TextStyle(
                                fontSize: SettingApp.settingApp.textSizeBody,
                              ),
                            ),
                            if (_news!.factCheck!.claims![index].claimReview![i].reviewDate == null)
                              Text(
                                "ไม่ทราบวันที่ระบุ",
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeCaption,
                                ),
                              )
                            else
                              Text(
                                DateFormat.yMMMEd().format(
                                  DateTime.parse(_news!.factCheck!.claims![index].claimReview![i].reviewDate!),
                                ),
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeCaption,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
              itemCount: _news!.factCheck!.claims!.length,
            ),
          ],
        );

    buildPage() => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (_isTranslate) ? _news!.titleTh! : _news!.title!,
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeH2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat.yMMMEd().format(
                    DateTime.parse(_news!.pubDate!),
                  ),
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                  ),
                ),
              ),
              if (_news!.imgUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (ApiAction.apiAction.isValidUrl(url: _news!.imgUrl!))
                      ? Image.network(
                          _news!.imgUrl!,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        )
                      : Image.file(
                          File(_news!.imgUrl!),
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                ),
              if (!_isLoading) buildContent(),
              if (_news!.sourceIcon != null)
                ListTile(
                  leading: Image.network(
                    _news!.sourceIcon!,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  title: Text(
                    _news!.sourceName!,
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                )
              else
                ListTile(
                  title: Text(_news!.sourceName!),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(
                  "ที่มา : ${_news!.newUrl}",
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                  ),
                ),
              ),
              buildFactCheck(),
            ],
          ),
        );
    buildErrorPage() => Center(
          child: Text(_errorMessage!),
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
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              if (_getAudioFile) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'เล่นเสียงไทย',
                    onTap: () {
                      playAudio('th');
                    },
                    enabled: (_news!.audioTh!.isEmpty && _getAudioFile) ? false : true,
                    child: Row(
                      children: [
                        Icon(
                          _isPlayAudioTh ? Icons.pause : Icons.play_arrow,
                          color: _isPlayAudioTh ? Colors.red : Colors.black,
                        ),
                        Text(
                          'เสียงไทย',
                          style: TextStyle(
                            color: _isPlayAudioTh ? Colors.red : Colors.black,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'เล่นเสียงอังกฤษ',
                    onTap: () {
                      playAudio('en');
                    },
                    enabled: (_news!.audioEn!.isEmpty && _getAudioFile) ? false : true,
                    child: Row(
                      children: [
                        Icon(
                          _isPlayAudioEn ? Icons.pause : Icons.play_arrow,
                          color: _isPlayAudioEn ? Colors.red : Colors.black,
                        ),
                        Text(
                          'เสียงอังกฤษ',
                          style: TextStyle(
                            color: _isPlayAudioEn ? Colors.red : Colors.black,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              } else {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'กำลังแปลงเสียง โดยลองใหม่ภายหลัง. . .',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SettingApp.settingApp.textSizeButton,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ส่งคำขอใหม่',
                    onTap: () {
                      getAudio();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        Text(
                          'รีเฟรช',
                          style: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }
            },
            icon: Icon(Icons.headphones),
            iconSize: SettingApp.settingApp.iconSize,
            iconColor: (_isPlayAudioTh || _isPlayAudioEn) ? Colors.red : Colors.black,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isTranslate = !_isTranslate;
              });
            },
            icon: Icon(
              Icons.g_translate,
              color: (_isTranslate) ? Colors.blue : Colors.black,
            ),
            iconSize: SettingApp.settingApp.iconSize,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.text_fields),
            iconSize: SettingApp.settingApp.iconSize,
          ),
          PopupMenuButton(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$valueเรียบร้อย',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            iconSize: SettingApp.settingApp.iconSize,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'บันทึกข่าว',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: SettingApp.settingApp.iconSize,
                      ),
                      Text(
                        'บันทึกข่าว',
                        style: TextStyle(
                          fontSize: SettingApp.settingApp.textSizeButton,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    saveNew();
                  },
                ),
                PopupMenuItem<String>(
                  value: 'Option 2',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share_sharp,
                      size: SettingApp.settingApp.iconSize,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Stack(
        children: [
          if (_isLoading) buildLoadingOverlay(),
          if (_errorMessage != null) buildErrorPage(),
          if (_news != null) buildPage(),
        ],
      ),
    );
  }
}
