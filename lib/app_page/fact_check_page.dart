import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/fact_check_tools_response.dart';

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
  String? searchText = 'ประเทศไทย';
  late String search;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getFactCheck();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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
    if (searchText?.length != 0 && searchText != null) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        _factCheckResponse = await ApiAction.apiAction.searchFactCheck(query: searchText!);
        search = searchText!;

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        _errorMessage = e.toString();
      }
    }
  }

  Future<void> getFactCheckNextPage() async {
    if (!_fillData) {
      try {
        if (!_isEnd) {
          setState(() {
            _errorMessage = null;
            _fillData = true;
          });

          var factCheckNext = await ApiAction.apiAction.searchFactCheck(query: search, nextPage: _factCheckResponse![0].nextPageToken);
          if (factCheckNext[0].claims!.isEmpty) {
            _isEnd = true;
          }

          setState(() {
            _factCheckResponse![0].claims!.addAll(factCheckNext[0].claims!);
            _factCheckResponse![0].nextPageToken = factCheckNext[0].nextPageToken;
            _factCheckResponse![1].claims!.addAll(factCheckNext[1].claims!);
            _factCheckResponse![1].nextPageToken = factCheckNext[1].nextPageToken;
            _fillData = false;
          });
        }
      } catch (e) {
        _errorMessage = e.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    buildLoadingOverlay() => Container(
          color: Colors.black.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );

    buildPage() => Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text((_isTranslate) ? _factCheckResponse![1].claims![index].text! : _factCheckResponse![0].claims![index].text!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _factCheckResponse![0].claims![index].claimReview!.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("ข้อมูลการตรวจสอบ : "),
                                  Container(
                                    decoration: BoxDecoration(color: (ApiAction.apiAction.checkFact(_factCheckResponse![1].claims![index].claimReview![i].textualRating!)) ? Colors.greenAccent : Colors.redAccent),
                                    child: Row(
                                      children: [
                                        Icon((ApiAction.apiAction.checkFact(_factCheckResponse![1].claims![index].claimReview![i].textualRating!)) ? Icons.check : Icons.close),
                                        const SizedBox(width: 8),
                                        Text(
                                          (_isTranslate) ? _factCheckResponse![1].claims![index].claimReview![i].textualRating! : _factCheckResponse![0].claims![index].claimReview![i].textualRating!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text((_isTranslate) ? _factCheckResponse![1].claims![index].claimReview![i].title! : _factCheckResponse![0].claims![index].claimReview![i].title!),
                              if (_factCheckResponse![0].claims![index].claimReview![i].reviewDate == null)
                                const Text("ไม่ทราบวันที่")
                              else
                                Text(DateFormat.yMMMEd().format(DateTime.parse(_factCheckResponse![0].claims![index].claimReview![i].reviewDate!))),
                            ],
                          ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: _factCheckResponse![0].claims!.length,
                controller: _scrollController,
              ),
            ),
            if (_fillData) const Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildErrorPage() => Center(
          child: Text(_errorMessage!),
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearchCheck
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: (value) {
                    searchText = value;
                    getFactCheck();
                  },
                  decoration: const InputDecoration(hintText: "คำค้นหา. . ."),
                ),
              )
            : const Text("Fact Check"),
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
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                value: _isTranslate,
                onChanged: (value) {
                  setState(() {
                    _isTranslate = value!;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text("แปลภาษา"),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_isLoading && _factCheckResponse![0].claims!.isEmpty)
                  const Center(
                    child: Text("ไม่พบการค้นหา"),
                  ),
                if (!_isLoading) buildPage(),
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
