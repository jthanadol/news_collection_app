import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/service/web_scraping.dart';
import 'package:validators/validators.dart' as validators;

class ReadNewPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
  News? _news;
  News? _newsRaw;
  News? _newsTranslate;
  bool _isLoading = false; //สถานะการโหลดข้อมูล
  bool _isTranslate = true; //สถานะการแปล
  String? _errorMessage;
  Color colorTranslate = Colors.blue;
  List<String> playList = [];
  bool isLoadingAudio = false;
  bool playAudio = false;
  final player = AudioPlayer();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> getData(String url) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _newsRaw!.content = await WebScraping.webScraping.scrapingThisWeb(url);

      await getTranslate();
      getAudio();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getTranslate() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      _newsTranslate = News.copy(_newsRaw!);
      _newsTranslate!.title = await ApiAction.apiAction.translateText(taget: _newsTranslate!.title!, to: "th");

      for (var i = 0; i < _newsTranslate!.content!.length; i++) {
        if (!validators.isURL(_newsTranslate!.content![i])) {
          _newsTranslate!.content![i] = await ApiAction.apiAction.translateText(taget: _newsTranslate!.content![i], to: "th");
        }
      }

      swapNews();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> playAudioFile() async {
    if (!isLoadingAudio) {
      if (playAudio) {
        player.stop();
        setState(() {
          playAudio = !playAudio;
        });
      } else {
        player.play();
        setState(() {
          playAudio = !playAudio;
        });
      }
    }
  }

  Future<void> setPlayList() async {
    ConcatenatingAudioSource concatenatingAudioSource = ConcatenatingAudioSource(children: playList.map((item) => AudioSource.file(item)).toList());
    await player.setAudioSource(concatenatingAudioSource);
  }

  Future<void> getAudio() async {
    setState(() {
      isLoadingAudio = true;
    });
    int textLimit = 150; //จำนวนตัวอักษรสูงสุดที่ vaja9 api รับได้
    List<String> content = _newsTranslate!.content!;
    List<String> word = []; //คำในข้อความ
    String textContent = "";
    for (var i = 0; i < content.length; i++) {
      textContent = content[i].replaceAll("%", " เปอร์เซ็น");
      textContent = textContent.replaceAll("\"", "");
      textContent = textContent.replaceAll("'", "");
      textContent.trim();
      if (!validators.isURL(textContent) && textContent.isNotEmpty) {
        if (textContent.length > textLimit) {
          int sumLength = 0; //จำนวนตัวอักษรที่ถูกแปลงเป็นเสียงแล้ว
          String text = ""; //ข้อความที่จะแปลงเสียง
          int indexOfLastWord = 0; //ตำแหน่งคำสุดท้าย
          for (var j = 0; j < (textContent.length / textLimit).ceil(); j++) {
            if ((sumLength + textLimit) > textContent.length) {
              text = textContent.substring(sumLength, textContent.length);
              text.trim();
              if (text.isNotEmpty) {
                playList.add(await ApiAction.apiAction.getVaja9Api(input_text: text));
                sumLength = textContent.length;
                print(text);
              }
            } else {
              word = await ApiAction.apiAction.separateWord(text: textContent.substring(sumLength, sumLength + textLimit));
              indexOfLastWord = textContent.indexOf(word[word.length - 2], sumLength); //-2 เพื่อเอาคำก่อนตัวสุดท้าย
              text = textContent.substring(sumLength, indexOfLastWord);
              text.trim();
              if (text.isNotEmpty) {
                playList.add(await ApiAction.apiAction.getVaja9Api(input_text: text)); //ดาวน์โหลดไฟล์เสียงและเก็บที่อยู่ลง playList
                sumLength += text.length;
                Future.delayed(const Duration(seconds: 1)); //หยุด 1 วิ เพื่อไม่ให้เกิน Rate limit ของ Vaja9
                print(text);
              }
            }
          }
        } else {
          playList.add(await ApiAction.apiAction.getVaja9Api(input_text: textContent));
          print(textContent);
        }
        Future.delayed(const Duration(seconds: 1)); //หยุด 1 วิ เพื่อไม่ให้เกิน Rate limit ของ Vaja9
      }
    }
    setPlayList();

    setState(() {
      isLoadingAudio = false;
    });
  }

  bool checkDuplicateImage(String url) {
    //ซ้ำ true ไม่ซ้ำ false
    if (_news!.image_url != null) {
      if (url == _news!.image_url || url == Uri.decodeFull(_news!.image_url!)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void swapNews() {
    if (_isTranslate) {
      setState(() {
        _news = _newsTranslate;
        colorTranslate = Colors.blue;
      });
    } else {
      setState(() {
        _news = _newsRaw!;
        colorTranslate = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_newsRaw == null) {
      _newsRaw = ModalRoute.of(context)?.settings.arguments as News;
      _news = _newsRaw;
      getData(_newsRaw!.linkNews!);
    }

    buildContent() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                if (validators.isURL(_news!.content![index]) && !checkDuplicateImage(_news!.content![index]))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      _news!.content![index],
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  )
                else if (!validators.isURL(_news!.content![index]))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_news!.content![index]),
                  ),
              ],
            );
          },
          itemCount: _news!.content!.length,
        );

    buildFactCheck() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_news!.factCheckResponse!.claims!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("การตรวจสอบข้อเท็จจริงของข่าวที่พบทั้งหมด ${_news!.factCheckResponse!.claims!.length} : "),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("ไม่พบการตรวจสอบข้อเท็จจริงของข่าว"),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var c = _news!.factCheckResponse!.claims![index];
                return ListTile(
                  title: Text(c.text!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < c.claimReview!.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ข้อมูลการตรวจสอบ : ${c.claimReview![i].textualRating}"),
                            Text(c.claimReview![i].title!),
                            Text(DateFormat.yMMMEd().format(DateTime.parse(c.claimReview![i].reviewDate!))),
                          ],
                        ),
                    ],
                  ),
                );
              },
              itemCount: _news!.factCheckResponse!.claims!.length,
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
                  _news!.title!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(DateFormat.yMMMEd().format(DateTime.parse(_news!.pubDate!))),
              ),
              if (_news!.image_url != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    _news!.image_url!,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              if (!_isLoading) buildContent(),
              if (_news!.source_icon != null)
                ListTile(
                  leading: Image.network(
                    _news!.source_icon!,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  title: Text(_news!.source_id!),
                )
              else
                ListTile(
                  title: Text(_news!.source_id!),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText("ที่มา : ${_news!.linkNews}"),
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
        actions: [
          IconButton(
            onPressed: () {
              playAudioFile();
            },
            icon: const Icon(Icons.headphones),
            color: (playAudio) ? Colors.redAccent : Colors.black,
          ),
          IconButton(
            onPressed: () {
              _isTranslate = !_isTranslate;
              swapNews();
            },
            icon: Icon(
              Icons.g_translate,
              color: colorTranslate,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.text_fields),
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Option 1',
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
                ),
                PopupMenuItem<String>(
                  value: 'Option 2',
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.share_sharp)),
                ),
              ];
            },
          )
        ],
        backgroundColor: Colors.black12,
      ),
      body: Stack(
        children: [
          if (_errorMessage != null) buildErrorPage(),
          buildPage(),
        ],
      ),
    );
  }
}
