import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/fact_check_tools_response.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:news_app/manage_file.dart';
import 'package:url_launcher/url_launcher.dart';

class FactCheckPage extends StatefulWidget {
  static const routeName = "/fact_check_page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const FactCheckPage({super.key});

  @override
  State<FactCheckPage> createState() => _FactCheckPageState();
}

class _FactCheckPageState extends State<FactCheckPage> {
  List<FactCheckResponse>? _factCheckResponse; //[0] แบบเดิม, [1] แบบแปล
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSearchCheck = false;
  bool _isLoading = false; //สถานะการโหลดข้อมูล
  bool _fillData = false; //สถานะโหลดข้อมูลเพิ่ม
  bool _isTranslate = true; //สถานะการแปล
  bool _isEnd = false; //สถานะไม่มีข้อมูลเพิ่มอีกแล้วถ้าเป็น true
  String? _errorMessage; //เก็บข้อความ error
  String? searchText = '';
  late String search;
  final ScrollController _scrollController = ScrollController();

  String fileName = '';

  @override
  void initState() {
    super.initState();
    getFactCheck();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    saveFactCheck();
    //ยกเลิกทรัพยากรที่ไม่จำเป็นเมื่อ widget ถูกลบออกจาก widget tree เพื่อป้องกัน memory leak
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    //ตรวจจับการเลื่อนจอ
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // เมื่อเลื่อนถึงจุดสิ้นสุด
      getFactCheckNextPage();
    }
  }

  Future<void> getFactCheck() async {
    if (searchText != null && searchText!.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        search = searchText!;
        fileName = '/factcheck_$search';
        fileName = fileName.replaceAll('.', '');
        fileName = (await PathFile.pathFile.getCachePath()) + fileName + '.json';

        DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        // print(date);
        //ตรวจว่ามีไฟล์อยู่ไม
        if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
          //มีไฟล์
          Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: fileName);

          if (date.isAtSameMomentAs(DateTime.parse(data["time"]))) {
            _factCheckResponse = [FactCheckResponse.fromJson(data['data'][0]), FactCheckResponse.fromJson(data['data'][1])];
            // print('อ่านไฟล์สำเร็จ');
          } else {
            await ManageFile.manageFile.deleteAllFilesInDir(pathDir: await PathFile.pathFile.getCachePath());

            if (await ApiAction.apiAction.checkInternet()) {
              _factCheckResponse = await ApiAction.apiAction.searchFactCheck(query: search);
              Map<String, dynamic> data = {
                "data": [_factCheckResponse![0].toJson(), _factCheckResponse![1].toJson()],
                "time": date.toString(),
              };
              ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
              // print('อัพเดทข้อมูลข่าวใหม่สำเร็จ');
            } else {
              setState(() {
                _errorMessage = 'ยังไม่ได้ทำการเชื่อมต่ออินเตอร์เน็ต';
                _factCheckResponse = null;
              });
            }
          }
        } else {
          //ไม่มีไฟล์
          if (await ApiAction.apiAction.checkInternet()) {
            _factCheckResponse = await ApiAction.apiAction.searchFactCheck(query: search);
            Map<String, dynamic> data = {
              "data": [_factCheckResponse![0].toJson(), _factCheckResponse![1].toJson()],
              "time": date.toString(),
            };
            ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
            // print('เขียนไฟล์สำเร็จ');
          } else {
            setState(() {
              _errorMessage = 'ยังไม่ได้ทำการเชื่อมต่ออินเตอร์เน็ต';
              _factCheckResponse = null;
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
  }

  Future<void> getFactCheckNextPage() async {
    if (await ApiAction.apiAction.checkInternet()) {
      if (!_fillData) {
        try {
          if (!_isEnd) {
            setState(() {
              _errorMessage = null;
              _fillData = true;
            });

            if (_factCheckResponse![0].nextPageToken != null) {
              var factCheckNext = await ApiAction.apiAction.searchFactCheck(query: search, nextPage: _factCheckResponse![0].nextPageToken);
              if (factCheckNext[0].claims!.isEmpty) {
                _isEnd = true;
              }
              _factCheckResponse![0].claims!.addAll(factCheckNext[0].claims!);
              _factCheckResponse![0].nextPageToken = factCheckNext[0].nextPageToken;
              _factCheckResponse![1].claims!.addAll(factCheckNext[1].claims!);
              _factCheckResponse![1].nextPageToken = factCheckNext[1].nextPageToken;

              await saveFactCheck();
            } else {
              _isEnd = true;
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

  Future<void> saveFactCheck() async {
    if (_factCheckResponse != null) {
      DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      Map<String, dynamic> data = {
        "data": [_factCheckResponse![0].toJson(), _factCheckResponse![1].toJson()],
        "time": date.toString(),
      };
      await ManageFile.manageFile.writeFileJson(fileName: fileName, data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    buildLoadingOverlay() => Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
            child: CircularProgressIndicator(
          color: SettingApp.settingApp.colorIconHighlight,
        )));

    buildPage() => Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
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
                          title: Text(
                            (_isTranslate) ? _factCheckResponse![1].claims![index].text! : _factCheckResponse![0].claims![index].text!,
                            style: TextStyle(
                              fontSize: SettingApp.settingApp.textSizeBody,
                              color: SettingApp.settingApp.colorText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < _factCheckResponse![0].claims![index].claimReview!.length; i++)
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
                                            color: (ApiAction.apiAction.checkFact(_factCheckResponse![1].claims![index].claimReview![i].textualRating!)) ? Colors.greenAccent : Colors.redAccent,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.45,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  (ApiAction.apiAction.checkFact(_factCheckResponse![1].claims![index].claimReview![i].textualRating!)) ? Icons.check : Icons.close,
                                                  color: Colors.black,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Text(
                                                    (_isTranslate) ? _factCheckResponse![1].claims![index].claimReview![i].textualRating! : _factCheckResponse![0].claims![index].claimReview![i].textualRating!,
                                                    maxLines: 2,
                                                    softWrap: true,
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
                                      onPressed: () {
                                        launchUrl(Uri.parse(_factCheckResponse![1].claims![index].claimReview![i].url!));
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        overlayColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        (_isTranslate) ? _factCheckResponse![1].claims![index].claimReview![i].title! : _factCheckResponse![0].claims![index].claimReview![i].title!,
                                        style: TextStyle(
                                          fontSize: SettingApp.settingApp.textSizeCaption,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    if (_factCheckResponse![0].claims![index].claimReview![i].reviewDate == null)
                                      Text(
                                        "ไม่ทราบวันที่",
                                        style: TextStyle(
                                          fontSize: SettingApp.settingApp.textSizeCaption,
                                          color: SettingApp.settingApp.colorText,
                                        ),
                                      )
                                    else
                                      Text(
                                        DateFormat.yMMMEd().format(
                                          DateTime.parse(_factCheckResponse![0].claims![index].claimReview![i].reviewDate!),
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
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  );
                },
                itemCount: _factCheckResponse![0].claims!.length,
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
                getFactCheck();
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
        centerTitle: true,
        title: _isSearchCheck
            ? Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TextField(
                  cursorColor: SettingApp.settingApp.colorIconHighlight,
                  controller: _textEditingController,
                  onSubmitted: (value) async {
                    await saveFactCheck();
                    searchText = value;
                    getFactCheck();
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
                "ตรวจสอบข้อเท็จจริง",
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH2,
                  color: SettingApp.settingApp.colorText,
                  fontWeight: FontWeight.bold,
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
            icon: _isSearchCheck ? const Icon(Icons.close) : const Icon(Icons.search),
            iconSize: SettingApp.settingApp.iconSize,
            color: SettingApp.settingApp.colorIcon,
          ),
        ],
        backgroundColor: Colors.black12,
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
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_errorMessage != null) buildErrorPage(),
                if (_factCheckResponse == null && _errorMessage == null)
                  Center(
                    child: Text(
                      "ยังไม่ได้ทำการค้นหา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: SettingApp.settingApp.colorText,
                      ),
                    ),
                  ),
                if (!_isLoading && _factCheckResponse != null && _factCheckResponse![0].claims!.isEmpty)
                  Center(
                    child: Text(
                      "ไม่พบการค้นหา",
                      style: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: SettingApp.settingApp.colorText,
                      ),
                    ),
                  ),
                if (!_isLoading && _factCheckResponse != null) buildPage(),
                if (_isLoading) buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
