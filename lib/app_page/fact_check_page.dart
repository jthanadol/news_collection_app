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
  FactCheckResponse? _factCheckResponse;
  bool _isLoading = false; //สถานะการโหลดข้อมูล
  bool _fillData = false;
  String? _errorMessage; //เก็บข้อความ error
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
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _factCheckResponse = await ApiAction().getFactCheckApi(reviewPublisherSiteFilter: "factcheckthailand.afp.com");

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getFactCheckNextPage() async {
    try {
      setState(() {
        _errorMessage = null;
        _fillData = true;
      });

      var factCheckNext = await ApiAction().getFactCheckApi(
        reviewPublisherSiteFilter: "factcheckthailand.afp.com",
        pageToken: _factCheckResponse!.nextPageToken,
      );

      setState(() {
        _factCheckResponse!.claims!.addAll(factCheckNext.claims!);
        _factCheckResponse!.nextPageToken = factCheckNext.nextPageToken;
        _fillData = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
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
                    title: Text(_factCheckResponse!.claims![index].text!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _factCheckResponse!.claims![index].claimReview!.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ข้อมูลการตรวจสอบ : ${_factCheckResponse!.claims![index].claimReview![i].textualRating}"),
                              Text(_factCheckResponse!.claims![index].claimReview![i].title!),
                              Text(DateFormat.yMMMEd().format(DateTime.parse(_factCheckResponse!.claims![index].claimReview![i].reviewDate!))),
                            ],
                          ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: _factCheckResponse!.claims!.length,
                controller: _scrollController,
              ),
            ),
            if (_fillData) const Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildErrorPage() => Container(
            child: Center(
          child: Text(_errorMessage!),
        ));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fact Check"),
        backgroundColor: Colors.black12,
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Center(
        child: Stack(
          children: [
            if (!_isLoading) buildPage(),
            if (_errorMessage != null) buildErrorPage(),
            if (_isLoading) buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
