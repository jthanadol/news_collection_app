import 'dart:convert';

import 'package:http/http.dart' as http;
import 'fact_check_tools_response.dart';
import 'news_response.dart';

class ApiAction {
  String factCheckApiKey = "AIzaSyAdumZj0pFWv-G2vLKhkunwZ10wm_IlPE0"; //key fact chack tools api
  String msNewsApiKey = "f9630a02661f41c1a60f42b8932ea2ba"; //key Bing News Search api
  String newsDataApiKey = "pub_5523073a37a1c1f1ace0fad685bdec4808963"; //key NewsData api
  String azureAiTranslatorApiKey = "B4rmGh3hSwENanvIJtuQDAqSxROxB8ivQY4Bt4BQPcs1CL4ksfAhJQQJ99AKACqBBLyXJ3w3AAAbACOG4kP8"; // key Azure AI Translator
  String aiForThaiApiKey = "FqpwcASpPzy7CrXZX1qvx6Ut8aeNrGWh"; //key ai for thai

  ApiAction();

  //method ที่ใช้เรียก Fact Check Tools Api
  Future<FactCheckResponse> getFactCheckApi({
    String? query, //ข้อความที่จะค้น ต้องระบุเว้นแต่จะระบุ reviewPublisherSiteFilter ไว้
    String? languageCode, //รหัสภาษา BCP-47 เช่น "en-US" ใช้เพื่อจํากัดผลลัพธ์ตามภาษา
    String? reviewPublisherSiteFilter, //เว็บไซต์ของผู้เผยแพร่ตรวจสอบเพื่อกรองผลลัพธ์
    int? maxAgeDays, //อายุสูงสุดของผลการค้นหาที่ส่งคืน หน่วยเป็นวัน
    int? pageSize, //ขนาดผลลัพธ์ ค่าเริ่มต้นจะเป็น 10
    String? pageToken, //คุณอาจส่ง nextPageToken กลับมาจากคําขอลิสต์ก่อนหน้า (หากมี) เพื่อไปยังหน้าถัดไป
    int? offset,
  }) async {
    String url = "https://factchecktools.googleapis.com/v1alpha1/claims:search?";
    if (query != null) {
      if (query.indexOf("&") != -1) {
        query = query.replaceAll("&", " and ");
      }
      print(query);
      url += "query=$query&";
    }
    if (languageCode != null) url += "languageCode=$languageCode&";
    if (reviewPublisherSiteFilter != null) url += "reviewPublisherSiteFilter=$reviewPublisherSiteFilter&";
    if (maxAgeDays != null) url += "maxAgeDays=$maxAgeDays&";
    if (pageSize != null) url += "pageSize=$pageSize&";
    if (pageToken != null) url += "pageToken=$pageToken&";
    if (offset != null) url += "offset=$offset&";

    url += "key=$factCheckApiKey";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(response.body);
    print("จาก getFactCheckApi : $data");

    return FactCheckResponse.fromJson(data);
  }

  Future<NewsResponse> getNewsDataApi({
    String? id,
    String? q,
    String? qInTitle,
    String? qInMeta,
    String? country,
    String? category,
    String? excludecategory,
    String? language,
    String? domain,
    String? domainurl,
    String? excludedomain, //ชื่อ domain ข่าวที่ไม่ต้องการ สูงสุด 5
    String? excludefield,
    String? prioritydomain,
    int? removeduplicate,
    int? size,
    String? page,
  }) async {
    String url = 'https://newsdata.io/api/1/latest?apikey=$newsDataApiKey';
    if (id != null) url += "&id=$id";
    if (q != null) url += "&q=$q";
    if (qInTitle != null && q == null) url += "&qInTitle=$qInTitle";
    if (qInMeta != null && q == null && qInTitle == null) url += "&qInMeta=$qInMeta";
    if (country != null) url += "&country=$country";
    if (category != null) url += "&category=$category";
    if (excludecategory != null) url += "&excludecategory=$excludecategory";
    if (language != null) url += "&language=$language";
    if (domain != null) url += "&domain=$domain";
    if (domainurl != null) url += "&domainurl=$domainurl";
    if (excludedomain != null) url += "&excludedomain=$excludedomain";
    if (excludefield != null) url += "&excludefield=$excludefield";
    if (prioritydomain != null) url += "&prioritydomain=$prioritydomain";
    if (removeduplicate != null) url += "&removeduplicate=$removeduplicate";
    if (size != null) url += "&size=$size";
    if (page != null) url += "&page=$page";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    print("จาก getNewsDataApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonNewsData(data);
    //print(newsResponse.news.length);
    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = await getFactCheckApi(query: newsResponse.news![i].title);
    }

    return newsResponse;
  }

  Future<String> translateText({required String taget, required String to, String? from}) async {
    String url = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=$to";
    if (from != null) url += "&from=$from";

    Map<String, String> head = {
      "Content-type": "application/json",
      "Ocp-Apim-Subscription-Key": azureAiTranslatorApiKey,
      "Ocp-Apim-Subscription-Region": "southeastasia",
    };
    var response = await http.post(Uri.parse(url),
        headers: head,
        body: json.encode([
          {"text": "$taget"}
        ]));

    var data = json.decode(response.body);
    print("จาก translateText : $data");
    return data[0]['translations'][0]['text'];
  }

  Future<NewsResponse> getBingSearchNewsApi({
    String? cc, //รหัสประเทศ 2 ตัวอักษรของประเทศที่ผลลัพธ์มาจาก สำหรับรายการค่าที่เป็นไปได้ ต้องระบุส่วนหัว Accept-Language ด้วย
    String? category, //หมวดหมู่ข่าว ใช้คู่กับ mkt
    int? count, //จำนวนบทความข่าว 10-100
    String? freshness, //กรองบทความข่าวโดยช่วงอายุ Day,Week,Month คือ 1,7,30 วันตามลำดับ
    String? mkt, //ประเทศที่ผู้ใช้ทำการขอข้อมูล ห้ามใช้กับ cc
    int? offset, //จำนวนบทความข่าวที่ต้องข้าม
    bool originalImg = true, //ถ้าเป็น true จะชี้ไปยังภาพต้นฉบับ
    String? q, //คำค้นหาของผู้ใช้ , หากต้องการจำกัดผลลัพธ์ให้เฉพาะโดเมนที่กำหนด ใช้ตัวดำเนินการ site: (q=fishing+site:fishing.contoso.com).
    //safeSearch ใช้เพื่อกรองบทความข่าวที่มีเนื้อหาผู้ใหญ่ ค่าที่เป็นไปได้มีดังนี้: Off ส่งคืนบทความข่าวที่เกี่ยวข้องกับเนื้อหาผู้ใหญ่ Moderate ส่งคืนบทความข่าวที่มีข้อความเกี่ยวกับเนื้อหาผู้ใหญ่ แต่ไม่มีรูปภาพหรือวิดีโอที่เกี่ยวข้อง Strict ไม่ส่งคืนบทความข่าวที่เกี่ยวข้องกับเนื้อหาผู้ใหญ่
    String? safeSearch,
    String? setLang, //ภาษาของข่าว สามารถระบุภาษาได้โดยใช้รหัส 2 ตัวอักษรหรือ 4 ตัวอักษร
    int? since, //ส่งคืนหัวข้อที่กำลังเป็นที่นิยมที่พบในวันที่และเวลาที่ระบุ หรือหลังจากนั้น วันเวลาที่ระบุเป็น Unix timestamp
    String? sortBy, //ส่งคืนค่าตามวันจากใหม่ไปเก่า Date , ส่งคืนหัวข้อข่าวที่จัดเรียงตามความเกี่ยวข้อง Relevance
  }) async {
    String url = "https://api.bing.microsoft.com/v7.0/news/search?";
    if (cc != null && mkt == null) url += "&cc=$cc";
    if (category != null) url += "&category=$category";
    if (count != null) url += "&category=$count";
    if (freshness != null) url += "&category=$freshness";
    if (mkt != null) url += "&category=$mkt";
    if (offset != null) url += "&category=$offset";

    url += "&category=$originalImg";

    if (q != null) {
      if (q.indexOf("&") != -1) {
        q = q.replaceAll("&", " and ");
      }
      url += "&category=$q";
    }
    if (safeSearch != null) url += "&category=$safeSearch";
    if (setLang != null) url += "&category=$setLang";
    if (since != null) url += "&category=$since";
    if (sortBy != null) url += "&category=$sortBy";

    var response = await http.get(
      Uri.parse(url),
      headers: {"Ocp-Apim-Subscription-Key": msNewsApiKey},
    );
    Map<String, dynamic> data = json.decode(response.body);
    print("จาก getBingSearchNewsApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonBingNewsSearch(data);
    //print(newsResponse.news.length);
    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = await getFactCheckApi(query: newsResponse.news![i].title);
    }

    return newsResponse;
  }
}
