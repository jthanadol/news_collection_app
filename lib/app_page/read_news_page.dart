import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadNewsPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewsPage({super.key});

  @override
  State<ReadNewsPage> createState() => _ReadNewsPageState();
}

class _ReadNewsPageState extends State<ReadNewsPage> {
  String path = '';
  int indexNew = -1;
  News? _news;
  List<String> _content = [];
  bool _getContent = false; //
  bool _isLoading = false; //สถานะการโหลดข้อมูล
  bool _isTranslate = true; //สถานะการแปล
  String? _errorMessage;
  bool _isLoadingAudioFile = false;
  bool _getAudioFile = false; //สถานะรับรายชื่อไฟล์เสียง ถ้าเป็น true แปลว่ารับไฟล์เสียงแล้ว
  final AudioPlayer _audioPlayerTH = AudioPlayer();
  final AudioPlayer _audioPlayerEN = AudioPlayer();
  Duration positionTH = Duration.zero;
  Duration durationTH = Duration.zero;
  Duration positionEN = Duration.zero;
  Duration durationEN = Duration.zero;

  Color colorTranslate = Colors.blue;

  @override
  void dispose() {
    _audioPlayerTH.dispose();
    _audioPlayerEN.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      if (path != '') {
        Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: path);
        print(data['data']);
        NewsResponse newsResponse = NewsResponse.fromJson(data['data']);
        print(newsResponse.news![indexNew].content);

        if (newsResponse.news![indexNew].content == null || newsResponse.news![indexNew].content!.isEmpty) {
          if (await ApiAction.apiAction.checkInternet()) {
            List<String> content = await ApiAction.apiAction.getContent(id: newsResponse.news![indexNew].newsId!);
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
            setState(() {
              _errorMessage = 'โปรดเชื่อมต่ออินเตอร์เน็ต';
            });
          }
        } else {
          print('มีเนิ้อหาข่าวอยู่แล้ว');
          _getContent = true;
        }
        _news = newsResponse.news![indexNew];
      } else {
        if (_news!.content == null || _news!.content!.isEmpty) {
          if (await ApiAction.apiAction.checkInternet()) {
            List<String> content = await ApiAction.apiAction.getContent(id: _news!.newsId!);
            if (content[0].isNotEmpty) {
              _news!.content = content[0];
              _news!.contentTh = content[1];
            } else {
              _news!.content = "";
              _news!.contentTh = "";
            }
          } else {
            setState(() {
              _errorMessage = 'โปรดเชื่อมต่ออินเตอร์เน็ต';
            });
          }
        }
      }

      getAudio();
      swapContent();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getAudio() async {
    if (!_isLoadingAudioFile) {
      _isLoadingAudioFile = true;
      print(_news!.audioTH);
      print(_news!.audioEN);

      if ((_news!.audioEN == null && _news!.audioTH == null)) {
        if (await ApiAction.apiAction.checkInternet()) {
          var res = await ApiAction.apiAction.getAudio(id: _news!.newsId!);
          _news!.audioTH = res[0];
          _news!.audioEN = res[1];
          if (res[0] != null) {
            _getAudioFile = true;
          }
        }
      } else {
        _getAudioFile = true;
      }

      List<Future> audioSet = [];
      if (_news!.audioTH != null) {
        audioSet.add(setAudioPlayer('th'));
      }
      if (_news!.audioEN != null) {
        audioSet.add(setAudioPlayer('en'));
      }
      if (audioSet.isNotEmpty) {
        await Future.wait(audioSet);
      }
      if (path.isNotEmpty) {
        Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: path);
        print(data['data']);
        NewsResponse newsResponse = NewsResponse.fromJson(data['data']);
        newsResponse.news![indexNew] = _news!;
        data['data'] = newsResponse.toJson();
        await ManageFile.manageFile.writeFileJson(fileName: path, data: data);
      }
      setState(() {
        _isLoadingAudioFile = false;
      });
    }
  }

  Future<void> setAudioPlayer(String language) async {
    if (language == 'th') {
      if (ApiAction.apiAction.isValidUrl(url: _news!.audioTH!)) {
        if (path.isNotEmpty) {
          String audioFile = path.substring(0, path.lastIndexOf('/')) + _news!.audioTH!.substring(_news!.audioTH!.lastIndexOf('/'));
          print(audioFile);
          if (await ApiAction.apiAction.downloadFile(url: _news!.audioTH!, fileName: audioFile)) {
            _news!.audioTH = audioFile;
            _audioPlayerTH.setFilePath(_news!.audioTH!);
          } else {
            _audioPlayerTH.setUrl(_news!.audioTH!);
          }
        }
      } else {
        _audioPlayerTH.setFilePath(_news!.audioTH!);
      }

      _audioPlayerTH.positionStream.listen((p) {
        setState(() {
          positionTH = p;
        });
      });
      _audioPlayerTH.durationStream.listen((d) {
        setState(() {
          durationTH = d!;
        });
      });
    } else {
      if (ApiAction.apiAction.isValidUrl(url: _news!.audioEN!)) {
        if (path.isNotEmpty) {
          String audioFile = path.substring(0, path.lastIndexOf('/')) + _news!.audioEN!.substring(_news!.audioEN!.lastIndexOf('/'));
          print(audioFile);
          if (await ApiAction.apiAction.downloadFile(url: _news!.audioEN!, fileName: audioFile)) {
            _news!.audioEN = audioFile;
            _audioPlayerEN.setFilePath(_news!.audioEN!);
          } else {
            _audioPlayerEN.setUrl(_news!.audioEN!);
          }
        }
      } else {
        _audioPlayerEN.setFilePath(_news!.audioEN!);
      }

      _audioPlayerEN.positionStream.listen((p) {
        setState(() {
          positionEN = p;
        });
      });
      _audioPlayerEN.durationStream.listen((d) {
        setState(() {
          durationEN = d!;
        });
      });
    }
  }

  Future<void> playAudio(String playFile) async {
    if (playFile == 'th') {
      if (_audioPlayerTH.playing) {
        _audioPlayerTH.pause();
      } else {
        if (_audioPlayerEN.playing) {
          _audioPlayerEN.pause();
        }
        _audioPlayerTH.play();
      }
    } else {
      if (_audioPlayerEN.playing) {
        _audioPlayerEN.pause();
      } else {
        if (_audioPlayerTH.playing) {
          _audioPlayerTH.pause();
        }
        _audioPlayerEN.play();
      }
    }
    setState(() {});
  }

  Future<void> saveOfflineNews() async {
    String path = await PathFile.pathFile.getDocPath();
    News news = News.fromJson(_news!.toJson());
    path = '$path/offlinenews.json';
    //น่าจะต้องมีโหลดรูปด้วย
    String imagePath = '${await PathFile.pathFile.getDocPath()}/${news.newsId}.jpg';
    if (news.imgUrl != null) {
      if (ApiAction.apiAction.isValidUrl(url: news.imgUrl!)) {
        // print('เป็น URL');

        if (await ApiAction.apiAction.downloadFile(url: news.imgUrl!, fileName: imagePath)) {
          news.imgUrl = imagePath;
        }
      } else {
        // print('เป็นไฟล์ในเครื่อง');
        //ถ้าไม่มีไฟล์ในโฟเดอ doc ของ app
        if (!(await ManageFile.manageFile.checkFileExists(fileName: imagePath))) {
          if (await ManageFile.manageFile.copyFile(sourcePath: news.imgUrl!, copyPath: imagePath)) {
            news.imgUrl = imagePath;
          }
        }
      }
    }

    if (news.audioTH != null) {
      String audioFile = '${await PathFile.pathFile.getDocPath()}${news.audioTH!.substring(news.audioTH!.lastIndexOf('/'))}';
      // print(audioFile);
      if (ApiAction.apiAction.isValidUrl(url: news.audioTH!)) {
        if (await ApiAction.apiAction.downloadFile(url: news.audioTH!, fileName: audioFile)) {
          news.audioTH = audioFile;
        }
      } else {
        if (!(await ManageFile.manageFile.checkFileExists(fileName: audioFile))) {
          if (await ManageFile.manageFile.copyFile(sourcePath: news.audioTH!, copyPath: audioFile)) {
            news.audioTH = audioFile;
          }
        }
      }
    }

    if (news.audioEN != null) {
      String audioFile = '${await PathFile.pathFile.getDocPath()}${news.audioEN!.substring(news.audioEN!.lastIndexOf('/'))}';
      if (ApiAction.apiAction.isValidUrl(url: news.audioEN!)) {
        if (await ApiAction.apiAction.downloadFile(url: news.audioEN!, fileName: audioFile)) {
          news.audioEN = audioFile;
        }
      } else {
        if (!(await ManageFile.manageFile.checkFileExists(fileName: audioFile))) {
          if (await ManageFile.manageFile.copyFile(sourcePath: news.audioEN!, copyPath: audioFile)) {
            news.audioEN = audioFile;
          }
        }
      }
    }

    if (await ManageFile.manageFile.checkFileExists(fileName: path)) {
      //มีไฟล์
      Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: path);
      NewsResponse newsRes = NewsResponse.fromJson(data['data']);
      bool notFind = true;
      for (var i = 0; i < newsRes.news!.length; i++) {
        if (newsRes.news![i].newsId == news.newsId) {
          notFind = false;
          newsRes.news![i] = news;
          break;
        }
      }
      if (notFind) {
        newsRes.news!.add(news);
      }

      data['data'] = newsRes.toJson();
      await ManageFile.manageFile.writeFileJson(fileName: path, data: data);
    } else {
      //ไม่มีไฟล์
      Map<String, dynamic> data = {
        'data': {
          "results": [news.toJson()]
        }
      };
      await ManageFile.manageFile.writeFileJson(fileName: path, data: data);
    }
    print('บันทึกไฟล์สำเร็จ');
  }

  swapContent() {
    if (_news!.contentTh != null && _news!.content != null) {
      setState(() {
        _content = (_isTranslate) ? _news!.contentTh!.trim().split('\n') : _news!.content!.trim().split('\n');
      });
    }
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString()}:${seconds.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    if (!_getContent) {
      path = arguments['fileName'];
      _news = arguments['new'];
      indexNew = arguments['index'];

      getData();
      _getContent = true;
    }

    buildLoadingOverlay() => Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
            child: CircularProgressIndicator(
          color: SettingApp.settingApp.colorIconHighlight,
        )));

    buildContent() => Container(
          width: MediaQuery.of(context).size.width * 0.95, //ขนาดกว้างไม่เกิน 95% ของหน้าจอปัจจุบัน
          decoration: BoxDecoration(
            color: SettingApp.settingApp.colorButton,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: SettingApp.settingApp.colorShadow,
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: (_news!.content != null && _news!.content!.trim().isNotEmpty)
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          '     ${_content[index]}',
                          style: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                            color: SettingApp.settingApp.colorText,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    );
                  },
                  itemCount: _content.length,
                )
              : Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'เกิดข้อผิดพลาดบางอย่าง',
                        style: TextStyle(
                          color: SettingApp.settingApp.colorText,
                          fontSize: SettingApp.settingApp.textSizeH2,
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
                          getData();
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
                          ),
                        ),
                        onPressed: () async {
                          Uri uri = Uri.parse(_news!.newsUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            setState(() {
                              _errorMessage = 'ไม่สามารถเปิดเว็บไซต์นี้ได้';
                            });
                          }
                        },
                        label: Text(
                          'ไปยังเว็บไซต์ต้นทาง',
                          style: TextStyle(
                            color: SettingApp.settingApp.colorText,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                        icon: Icon(
                          Icons.open_in_new,
                          size: SettingApp.settingApp.iconSize,
                          color: SettingApp.settingApp.colorIcon,
                        ),
                      ),
                    ],
                  ),
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
                    color: SettingApp.settingApp.colorText,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "ไม่พบการตรวจสอบข้อเท็จจริงของข่าว",
                  style: TextStyle(
                    fontSize: SettingApp.settingApp.textSizeBody,
                    color: SettingApp.settingApp.colorText,
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
                      color: SettingApp.settingApp.colorText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _news!.factCheck!.claims![index].claimReview!.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "ผลการตรวจสอบ : ",
                                  style: TextStyle(fontSize: SettingApp.settingApp.textSizeBody, color: SettingApp.settingApp.colorText),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: (ApiAction.apiAction.checkFact(_news!.factCheckTh!.claims![index].claimReview![i].textualRating!)) ? Colors.greenAccent : Colors.redAccent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          (ApiAction.apiAction.checkFact(_news!.factCheckTh!.claims![index].claimReview![i].textualRating!)) ? Icons.check : Icons.close,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            (_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].textualRating! : _news!.factCheckTh!.claims![index].claimReview![i].textualRating!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: SettingApp.settingApp.textSizeBody,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                launchUrl(Uri.parse(_news!.factCheckTh!.claims![index].claimReview![i].url!));
                              },
                              child: Text(
                                (_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].title! : _news!.factCheck!.claims![index].claimReview![i].title!,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeBody,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                ),
                              ),
                            ),
                            if (_news!.factCheck!.claims![index].claimReview![i].reviewDate == null)
                              Text(
                                "ไม่ทราบวันที่ระบุ",
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeCaption,
                                  color: SettingApp.settingApp.colorText,
                                ),
                              )
                            else
                              Text(
                                DateFormat.yMMMEd().format(
                                  DateTime.parse(_news!.factCheck!.claims![index].claimReview![i].reviewDate!),
                                ),
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeCaption,
                                  color: SettingApp.settingApp.colorText,
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

    buildPage() => Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: SettingApp.settingApp.colorButton,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: SettingApp.settingApp.colorShadow,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText(
                          (_isTranslate) ? _news!.titleTh! : _news!.title!,
                          style: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeH1,
                            color: SettingApp.settingApp.colorTextTitle,
                            fontWeight: FontWeight.w900,
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
                            color: SettingApp.settingApp.colorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                if (_news!.imgUrl != null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: (ApiAction.apiAction.isValidUrl(url: _news!.imgUrl!))
                            ? Image.network(
                                _news!.imgUrl!,
                                width: MediaQuery.of(context).size.width * 0.95,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              )
                            : Image.file(
                                File(_news!.imgUrl!),
                                width: MediaQuery.of(context).size.width * 0.95,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                      ),
                    ],
                  ),
                if (_getAudioFile && (_news!.audioEN != null || _news!.audioTH != null))
                  Column(
                    children: [
                      if (_news!.audioTH != null && _getAudioFile)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: SettingApp.settingApp.colorButton,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: SettingApp.settingApp.colorShadow,
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'เล่นเสียงไทย',
                                style: TextStyle(
                                  color: _audioPlayerTH.playing ? SettingApp.settingApp.colorTextTitle : SettingApp.settingApp.colorText,
                                  fontSize: SettingApp.settingApp.textSizeBody,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatDuration(positionTH),
                                    style: TextStyle(
                                      color: SettingApp.settingApp.colorText,
                                      fontSize: SettingApp.settingApp.textSizeBody,
                                    ),
                                  ),
                                  Slider(
                                    activeColor: SettingApp.settingApp.colorIconHighlight,
                                    value: positionTH.inSeconds.toDouble(),
                                    min: 0.0,
                                    max: durationTH.inSeconds.toDouble(),
                                    onChanged: (p) {
                                      _audioPlayerTH.seek(Duration(seconds: p.toInt()));
                                    },
                                  ),
                                  Text(
                                    formatDuration(durationTH),
                                    style: TextStyle(
                                      color: SettingApp.settingApp.colorText,
                                      fontSize: SettingApp.settingApp.textSizeBody,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      playAudio('th');
                                    },
                                    icon: Icon(
                                      _audioPlayerTH.playing ? Icons.pause : Icons.play_arrow,
                                      color: _audioPlayerTH.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                                      size: SettingApp.settingApp.iconSize,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _audioPlayerTH.seek(Duration.zero);
                                    },
                                    icon: Icon(
                                      Icons.stop,
                                      color: _audioPlayerTH.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                                      size: SettingApp.settingApp.iconSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (_news!.audioEN != null && _getAudioFile)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: SettingApp.settingApp.colorButton,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: SettingApp.settingApp.colorShadow,
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'เล่นเสียงอังกฤษ',
                                style: TextStyle(
                                  color: _audioPlayerEN.playing ? SettingApp.settingApp.colorTextTitle : SettingApp.settingApp.colorText,
                                  fontSize: SettingApp.settingApp.textSizeBody,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatDuration(positionEN),
                                    style: TextStyle(
                                      color: SettingApp.settingApp.colorText,
                                      fontSize: SettingApp.settingApp.textSizeBody,
                                    ),
                                  ),
                                  Slider(
                                    activeColor: SettingApp.settingApp.colorIconHighlight,
                                    value: positionEN.inSeconds.toDouble(),
                                    min: 0.0,
                                    max: durationEN.inSeconds.toDouble(),
                                    onChanged: (p) {
                                      _audioPlayerEN.seek(Duration(seconds: p.toInt()));
                                    },
                                  ),
                                  Text(
                                    formatDuration(durationEN),
                                    style: TextStyle(
                                      color: SettingApp.settingApp.colorText,
                                      fontSize: SettingApp.settingApp.textSizeBody,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      playAudio('EN');
                                    },
                                    icon: Icon(
                                      _audioPlayerEN.playing ? Icons.pause : Icons.play_arrow,
                                      color: _audioPlayerEN.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                                      size: SettingApp.settingApp.iconSize,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _audioPlayerEN.seek(Duration.zero);
                                    },
                                    icon: Icon(
                                      Icons.stop,
                                      color: _audioPlayerEN.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                                      size: SettingApp.settingApp.iconSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: SettingApp.settingApp.colorButton,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: SettingApp.settingApp.colorShadow,
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'กำลังแปลงเสียง โดยลองใหม่ภายหลัง. . .',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorText,
                                fontSize: SettingApp.settingApp.textSizeBody,
                                fontWeight: FontWeight.bold,
                              ),
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
                                getAudio();
                              },
                              label: Text(
                                'รีเฟรช',
                                style: TextStyle(
                                  fontSize: SettingApp.settingApp.textSizeButton,
                                  color: SettingApp.settingApp.colorTextButton,
                                ),
                              ),
                              icon: Icon(
                                Icons.refresh,
                                color: SettingApp.settingApp.colorIcon,
                                size: SettingApp.settingApp.iconSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 8,
                ),
                buildContent(),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: SettingApp.settingApp.colorButton,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: SettingApp.settingApp.colorShadow,
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
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
                                  color: SettingApp.settingApp.colorText,
                                ),
                              ),
                            )
                          else
                            ListTile(
                              title: Text(
                                _news!.sourceName!,
                                style: TextStyle(
                                  color: SettingApp.settingApp.colorText,
                                  fontSize: SettingApp.settingApp.textSizeBody,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ที่มา : ',
                                  style: TextStyle(
                                    fontSize: SettingApp.settingApp.textSizeBody,
                                    color: SettingApp.settingApp.colorText,
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      overlayColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      launchUrl(Uri.parse(_news!.newsUrl!));
                                    },
                                    child: Text(
                                      _news!.newsUrl!,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: SettingApp.settingApp.textSizeBody,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: SettingApp.settingApp.colorButton,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: SettingApp.settingApp.colorShadow,
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: buildFactCheck(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        );
    buildErrorPage() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: SettingApp.settingApp.colorText,
                fontSize: SettingApp.settingApp.textSizeH1,
              ),
            ),
            const SizedBox(
              height: 24,
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
                getData();
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
            boxShadow: [
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
            _audioPlayerEN.stop();
            _audioPlayerTH.stop();
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
          color: SettingApp.settingApp.colorIcon,
        ),
        actions: [
          PopupMenuButton<String>(
            color: SettingApp.settingApp.colorButton,
            itemBuilder: (BuildContext context) {
              if (_getAudioFile) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'เล่นเสียงไทย',
                    onTap: () {
                      playAudio('th');
                    },
                    enabled: (_news!.audioTH != null && _getAudioFile) ? true : false,
                    child: Row(
                      children: [
                        Icon(
                          _audioPlayerTH.playing ? Icons.pause : Icons.play_arrow,
                          color: _audioPlayerTH.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                        ),
                        Text(
                          'เสียงไทย',
                          style: TextStyle(
                            color: _audioPlayerTH.playing ? SettingApp.settingApp.colorTextTitle : SettingApp.settingApp.colorText,
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
                    enabled: (_news!.audioEN != null && _getAudioFile) ? true : false,
                    child: Row(
                      children: [
                        Icon(
                          _audioPlayerEN.playing ? Icons.pause : Icons.play_arrow,
                          color: _audioPlayerEN.playing ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
                        ),
                        Text(
                          'เสียงอังกฤษ',
                          style: TextStyle(
                            color: _audioPlayerEN.playing ? SettingApp.settingApp.colorTextTitle : SettingApp.settingApp.colorText,
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
                        const Icon(Icons.refresh),
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
            icon: const Icon(Icons.headphones),
            iconSize: SettingApp.settingApp.iconSize,
            iconColor: (_audioPlayerEN.playing || _audioPlayerTH.playing) ? SettingApp.settingApp.colorIconHighlight : SettingApp.settingApp.colorIcon,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isTranslate = !_isTranslate;
              });
              swapContent();
            },
            icon: Icon(
              Icons.g_translate,
              color: (_isTranslate) ? Colors.blue : SettingApp.settingApp.colorIcon,
            ),
            iconSize: SettingApp.settingApp.iconSize,
          ),
          PopupMenuButton(
            color: SettingApp.settingApp.colorButton,
            iconSize: SettingApp.settingApp.iconSize,
            icon: Icon(
              Icons.text_fields,
              color: SettingApp.settingApp.colorIcon,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    SettingApp.settingApp.textSize = 'big';
                    SettingApp.settingApp.setTextSize();
                    SettingApp.settingApp.saveSettingFile();
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 20,
                              color: SettingApp.settingApp.colorIcon,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'ขนาดใหญ่',
                            style: TextStyle(
                              fontSize: 20,
                              color: SettingApp.settingApp.colorTextButton,
                            ),
                          ),
                        ],
                      ),
                      (SettingApp.settingApp.textSize.contains('big')) ? Icon(Icons.check_box, color: SettingApp.settingApp.colorIconHighlight) : const SizedBox.shrink(),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    SettingApp.settingApp.textSize = 'normal';
                    SettingApp.settingApp.setTextSize();
                    SettingApp.settingApp.saveSettingFile();
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 16,
                              color: SettingApp.settingApp.colorIcon,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'ขนาดปกติ',
                            style: TextStyle(
                              fontSize: 16,
                              color: SettingApp.settingApp.colorTextButton,
                            ),
                          ),
                        ],
                      ),
                      (SettingApp.settingApp.textSize.contains('normal')) ? Icon(Icons.check_box, color: SettingApp.settingApp.colorIconHighlight) : const SizedBox.shrink(),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    SettingApp.settingApp.textSize = 'small';
                    SettingApp.settingApp.setTextSize();
                    SettingApp.settingApp.saveSettingFile();
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 14,
                              color: SettingApp.settingApp.colorIcon,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'ขนาดเล็ก',
                            style: TextStyle(
                              fontSize: 14,
                              color: SettingApp.settingApp.colorTextButton,
                            ),
                          ),
                        ],
                      ),
                      (SettingApp.settingApp.textSize.contains('small')) ? Icon(Icons.check_box, color: SettingApp.settingApp.colorIconHighlight) : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ];
            },
          ),
          PopupMenuButton(
            color: SettingApp.settingApp.colorButton,
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$valueเรียบร้อย',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            iconSize: SettingApp.settingApp.iconSize,
            iconColor: SettingApp.settingApp.colorIcon,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'บันทึกข่าว',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: SettingApp.settingApp.iconSize,
                        color: SettingApp.settingApp.colorIcon,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'บันทึกข่าว',
                        style: TextStyle(
                          fontSize: SettingApp.settingApp.textSizeButton,
                          color: SettingApp.settingApp.colorTextButton,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    saveOfflineNews();
                  },
                ),
                PopupMenuItem<String>(
                  value: 'คัดลอก URL',
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy,
                        size: SettingApp.settingApp.iconSize,
                        color: SettingApp.settingApp.colorIcon,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'คัดลอก URL',
                        style: TextStyle(
                          fontSize: SettingApp.settingApp.textSizeButton,
                          color: SettingApp.settingApp.colorTextButton,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _news!.newsUrl!));
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading) buildLoadingOverlay(),
          if (_errorMessage != null) buildErrorPage(),
          if (!_isLoading && _errorMessage == null) buildPage(),
        ],
      ),
    );
  }
}
