import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';

class ReadNewPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
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
      if (_news!.content == null) {
        List<String> content = await ApiAction.apiAction.getContent(id: _news!.newId!);
        if (content.isNotEmpty) {
          _news!.content = content[0];
          _news!.contentTh = content[1];
        } else {
          _news!.content = "";
          _news!.contentTh = "";
        }
      } else {
        _getContent = true;
      }
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
        var res = await ApiAction.apiAction.getAudio(id: _news!.newId!);
        if (res[0] == 'ส่งรายชื่อไฟล์สำเร็จ') {
          _news!.audioTh = res[1];
          _news!.audioEn = res[2];

          _getAudioFile = true;
        } else if (res[0] == 'ไม่สามารแปลงเสียงได้') {
          _getAudioFile = true;
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

      listAudios = _news!.audioTh;
      if (_isPlayAudioTh && _isPlayAudioEn) {
        _isPlayAudioEn = false;

        _audioPlayer.stop();
      }
    } else if (playFile == 'en') {
      _isPlayAudioEn = !_isPlayAudioEn;

      listAudios = _news!.audioEn;
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

  @override
  Widget build(BuildContext context) {
    _news = ModalRoute.of(context)?.settings.arguments as News;
    if (!_getContent) {
      getData();
      _getContent = true;
    }

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

    buildContent() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text((_isTranslate) ? _news!.contentTh! : _news!.content!),
            ],
          ),
        );

    buildFactCheck() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_news!.factCheck!.claims!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("การตรวจสอบข้อเท็จจริงของข่าวที่พบทั้งหมด ${_news!.factCheck!.claims!.length} : "),
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
                return ListTile(
                  title: Text(_isTranslate ? _news!.factCheckTh!.claims![index].text! : _news!.factCheck!.claims![index].text!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _news!.factCheck!.claims![index].claimReview!.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ข้อมูลการตรวจสอบ : ${(_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].textualRating : _news!.factCheck!.claims![index].claimReview![i].textualRating}"),
                            Text((_isTranslate) ? _news!.factCheckTh!.claims![index].claimReview![i].title! : _news!.factCheck!.claims![index].claimReview![i].title!),
                            if (_news!.factCheck!.claims![index].claimReview![i].reviewDate == null) const Text("ไม่ทราบวันที่ระบุ") else Text(DateFormat.yMMMEd().format(DateTime.parse(_news!.factCheck!.claims![index].claimReview![i].reviewDate!))),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(DateFormat.yMMMEd().format(DateTime.parse(_news!.pubDate!))),
              ),
              if (_news!.imgUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    _news!.imgUrl!,
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
                  title: Text(_news!.sourceIcon!),
                )
              else
                ListTile(
                  title: Text(_news!.sourceName!),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText("ที่มา : ${_news!.newUrl}"),
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
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              if (_getAudioFile) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'เล่นเสียงไทย',
                    onTap: () {
                      playAudio('th');
                    },
                    enabled: (_news!.audioTh.isEmpty && _getAudioFile) ? false : true,
                    child: Row(
                      children: [
                        Icon(
                          _isPlayAudioTh ? Icons.pause : Icons.play_arrow,
                          color: _isPlayAudioTh ? Colors.red : Colors.black,
                        ),
                        Text(
                          'เสียงไทย',
                          style: TextStyle(color: _isPlayAudioTh ? Colors.red : Colors.black),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'เล่นเสียงอังกฤษ',
                    onTap: () {
                      playAudio('en');
                    },
                    enabled: (_news!.audioEn.isEmpty && _getAudioFile) ? false : true,
                    child: Row(
                      children: [
                        Icon(
                          _isPlayAudioEn ? Icons.pause : Icons.play_arrow,
                          color: _isPlayAudioEn ? Colors.red : Colors.black,
                        ),
                        Text(
                          'เสียงอังกฤษ',
                          style: TextStyle(color: _isPlayAudioEn ? Colors.red : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ];
              } else {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'กำลังแปลงเสียง โดยลองใหม่ภายหลัง. . .',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ส่งคำขอใหม่',
                    onTap: () {
                      getAudio();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.refresh),
                        Text('รีเฟรช'),
                      ],
                    ),
                  ),
                ];
              }
            },
            icon: const Icon(Icons.headphones),
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
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Stack(
        children: [
          if (_isLoading) buildLoadingOverlay(),
          if (_errorMessage != null) buildErrorPage(),
          buildPage(),
        ],
      ),
    );
  }
}
