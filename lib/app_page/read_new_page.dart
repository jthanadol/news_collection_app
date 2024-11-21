import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as validators;

import '../api_response/news_response.dart';
import '../service/web_scraping.dart';

class ReadNewPage extends StatefulWidget {
  static const routeName = "/read_page";
  const ReadNewPage({super.key});

  @override
  State<ReadNewPage> createState() => _ReadNewPageState();
}

class _ReadNewPageState extends State<ReadNewPage> {
  News? news;
  bool isLoading = false; //สถานะการโหลดข้อมูล

  Future<void> getData(String url) async {
    setState(() {
      isLoading = true;
    });

    news!.content = await WebScraping().scrapingThisWeb(url);

    setState(() {
      isLoading = false;
    });
  }

  bool checkDuplicateImage(String url) {
    //ซ้ำ true ไม่ซ้ำ false
    if (news!.image_url != null) {
      if (url == news!.image_url || url == Uri.decodeFull(news!.image_url!)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (news == null) {
      news = ModalRoute.of(context)?.settings.arguments as News;
      getData(news!.linkNews!);
    }

    buildContent() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                if (validators.isURL(news!.content![index]) && !checkDuplicateImage(news!.content![index]))
                  Image.network(
                    news!.content![index],
                    errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
                  )
                else
                  Text(news!.content![index]),
              ],
            );
          },
          itemCount: news!.content!.length,
        );

    buildFactCheck() => Column(
          children: [
            if (news!.factCheckResponse!.claims!.length != 0)
              Text("การตรวจสอบข้อเท็จจริงของข่าวที่พบทั้งหมด ${news!.factCheckResponse!.claims!.length} : ")
            else
              Text("ไม่พบการตรวจสอบข้อเท็จจริงของข่าว"),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var c = news!.factCheckResponse!.claims![index];
                return ListTile(
                  title: Text(c.text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < c.claimReview.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ข้อมูลการตรวจสอบ : ${c.claimReview[i].textualRating}"),
                            Text(c.claimReview[i].title),
                            Text("วันที่ : ${c.claimDate}"),
                          ],
                        ),
                    ],
                  ),
                );
              },
              itemCount: news!.factCheckResponse!.claims!.length,
            ),
          ],
        );

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              news!.title!,
            ),
            Text("วันที่ : ${news!.pubDate!}"),
            if (news!.image_url != null)
              Image.network(
                news!.image_url!,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ),
            if (!isLoading) buildContent(),
            if (news!.source_icon != null)
              ListTile(
                leading: Image.network(
                  news!.source_icon!,
                  errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
                ),
                title: Text(news!.source_id!),
              )
            else
              ListTile(
                title: Text(news!.source_id!),
              ),
            Text("ที่มา : ${news!.linkNews}"),
            buildFactCheck(),
          ],
        ),
      ),
    );
  }
}
