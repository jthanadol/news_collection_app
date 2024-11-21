import 'dart:convert';

import 'package:http/http.dart' as http;
import 'fact_check_tools_response.dart';
import 'news_response.dart';

class ApiAction {
  String factCheckApiKey = "AIzaSyAdumZj0pFWv-G2vLKhkunwZ10wm_IlPE0"; //key fact chack tools api
  String msNewsApiKey = "f9630a02661f41c1a60f42b8932ea2ba"; //key Bing News Search api
  String newsDataApiKey = "pub_5523073a37a1c1f1ace0fad685bdec4808963"; //key NewsData api

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
    if (query != null) url += "query=$query&";
    if (languageCode != null) url += "languageCode=$languageCode&";
    if (reviewPublisherSiteFilter != null) url += "reviewPublisherSiteFilter=$reviewPublisherSiteFilter&";
    if (maxAgeDays != null) url += "maxAgeDays=$maxAgeDays&";
    if (pageSize != null) url += "pageSize=$pageSize&";
    if (pageToken != null) url += "pageToken=$pageToken&";
    if (offset != null) url += "offset=$offset&";

    url += "key=$factCheckApiKey";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(response.body);

    return FactCheckResponse.fromJson(data);
  }

  Future<NewsResponse> getNewsDataApi({
    String? id,
    String? q,
    String? qInTitle,
    String? qInMeta,
    String? timeframe,
    String? country,
    String? category,
    String? excludecategory,
    String? language,
    String? tag,
    String? domain,
    String? domainurl,
    String? excludedomain,
    String? excludefield,
    String? prioritydomain,
    int? image,
    int? video,
    int? removeduplicate,
    int? size,
    String? page,
  }) async {
    String url = 'https://newsdata.io/api/1/latest?apikey=$newsDataApiKey';
    if (id != null) url += "&id=$id";
    if (q != null) url += "&q=$q";
    if (qInTitle != null && q == null) url += "&qInTitle=$qInTitle";
    if (qInMeta != null && q == null && qInTitle == null) url += "&qInMeta=$qInMeta";
    if (timeframe != null) url += "&timeframe=$timeframe";
    if (country != null) url += "&country=$country";
    if (category != null) url += "&category=$category";
    if (excludecategory != null) url += "&excludecategory=$excludecategory";
    if (language != null) url += "&language=$language";
    if (tag != null) url += "&tag=$tag";
    if (domain != null) url += "&domain=$domain";
    if (domainurl != null) url += "&domainurl=$domainurl";
    if (excludedomain != null) url += "&excludedomain=$excludedomain";
    if (excludefield != null) url += "&excludefield=$excludefield";
    if (prioritydomain != null) url += "&prioritydomain=$prioritydomain";
    if (image != null) url += "&image=$image";
    if (video != null) url += "&video=$video";
    if (removeduplicate != null) url += "&removeduplicate=$removeduplicate";
    if (size != null) url += "&size=$size";
    if (page != null) url += "&page=$page";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    //print(data);
    NewsResponse newsResponse = NewsResponse.fromJsonNewsData(data);

    for (var i = 0; i < newsResponse.news.length; i++) {
      newsResponse.news[i].factCheckResponse = await getFactCheckApi(query: newsResponse.news[i].title);
    }

    return newsResponse;
  }
}
