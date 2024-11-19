import 'package:flutter/material.dart';

import '../api_response/news_response.dart';

class ReadNewPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
  late News news;

  @override
  Widget build(BuildContext context) {
    news = ModalRoute.of(context)?.settings.arguments as News;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          child: ListView(
            children: [
              Text(
                news.title!,
              ),
              Text("วันที่ : ${news.pubDate!}"),
              Image.network(
                news.image_url!,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ),
              Text("เนื้อหาที่ได้จาก web scraping"),
              ListTile(
                leading: Image.network(news.source_icon!),
                title: Text(news.source_id!),
              ),
              Text("ที่มา : ${news.linkNews}"),
              if (news.factCheckResponse!.claims!.length != 0)
                Text("การตรวจสอบข้อเท็จจริงของข่าวที่พบทั้งหมด ${news.factCheckResponse!.claims!.length} : ")
              else
                Text("ไม่พบการตรวจสอบข้อเท็จจริงของข่าว"),
              if (news.factCheckResponse!.claims!.length != 0)
                for (int i = 0; i < news.factCheckResponse!.claims!.length; i++)
                  ListTile(
                      title: Text(news.factCheckResponse!.claims![i].text),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < news.factCheckResponse!.claims![i].claimReview.length; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ข้อมูลการตรวจสอบ : ${news.factCheckResponse!.claims![i].claimReview[i].textualRating}"),
                                Text(news.factCheckResponse!.claims![i].claimReview[i].title),
                                Text("วันที่ : ${news.factCheckResponse!.claims![i].claimDate}"),
                              ],
                            ),
                        ],
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
