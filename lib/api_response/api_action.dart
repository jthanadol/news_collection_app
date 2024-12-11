import 'dart:convert';

import 'package:dio/dio.dart';
import 'fact_check_tools_response.dart';
import 'news_response.dart';

class ApiAction {
  final Dio _dio = Dio(BaseOptions(responseType: ResponseType.plain));
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
    String? reviewPublisherSiteFilter, //domain เว็บไซต์ของผู้เผยแพร่ตรวจสอบเพื่อกรองผลลัพธ์
    int? maxAgeDays, //อายุสูงสุดของผลการค้นหาที่ส่งคืน หน่วยเป็นวัน
    int? pageSize, //ขนาดผลลัพธ์ ค่าเริ่มต้นจะเป็น 10
    String? pageToken, //ส่ง nextPageToken กลับมาจากคําขอลิสต์ก่อนหน้าเพื่อไปยังหน้าถัดไป
    int? offset,
  }) async {
    String url = "https://factchecktools.googleapis.com/v1alpha1/claims:search?";
    if (query != null) {
      if (query.contains("&")) {
        query = query.replaceAll("&", " and ");
      }
      url += "query=$query&";
    }
    if (languageCode != null) url += "languageCode=$languageCode&";
    if (reviewPublisherSiteFilter != null) url += "reviewPublisherSiteFilter=$reviewPublisherSiteFilter&";
    if (maxAgeDays != null) url += "maxAgeDays=$maxAgeDays&";
    if (pageSize != null) url += "pageSize=$pageSize&";
    if (pageToken != null) url += "pageToken=$pageToken&";
    if (offset != null) url += "offset=$offset&";

    url += "key=$factCheckApiKey";

    var response = await _dio.get(url);
    Map<String, dynamic> data = json.decode(response.data);
    //print("จาก getFactCheckApi : $data");

    return FactCheckResponse.fromJson(data);
  }

  Future<NewsResponse> getNewsDataApi({
    String? id, //ค้นหาบทความข่าวจากรหัสบทความเฉพาะ (article_id)
    String? q, //ค้นหาบทความข่าวโดยใช้คำสำคัญหรือวลีที่เฉพาะเจาะจงซึ่งปรากฏในหัวข้อข่าว, เนื้อหา, URL, คำสำคัญในเมต้า (meta keywords) และคำอธิบายเมต้า (meta description)
    String? qInTitle, //ค้นหาบทความข่าวโดยใช้คำสำคัญหรือวลีที่เฉพาะเจาะจงซึ่งปรากฏในหัวข้อข่าวเท่านั้น
    String? qInMeta, //ค้นหาบทความข่าวโดยใช้คำสำคัญหรือวลีที่เฉพาะเจาะจงซึ่งปรากฏในหัวข้อข่าว, URL, คำสำคัญในเมต้า (meta keywords) และคำอธิบายเมต้า (meta description)
    String? country, //ค้นหาบทความข่าวจากประเทศเฉพาะ สามารถเพิ่มประเทศได้สูงสุด 5 ประเทศในคำค้นเดียว
    String? category, //ค้นหาบทความข่าวในหมวดหมู่เฉพาะ สามารถเพิ่มหมวดหมู่ได้สูงสุด 5 หมวดหมู่ในคำค้นเดียว
    String? excludecategory, //ยกเว้นหมวดหมู่เฉพาะในการค้นหาบทความข่าวได้ สามารถยกเว้นได้สูงสุด 5 หมวดหมู่ในคำค้นเดียว
    String? language, //ค้นหาบทความข่าวในภาษาที่เฉพาะเจาะจง สามารถเพิ่มภาษาลงในคำค้นได้สูงสุด 5 ภาษา
    String? domain, //ค้นหาบทความข่าวจากโดเมนหรือแหล่งข่าวเฉพาะ สามารถเพิ่มโดเมนได้สูงสุด 5 โดเมนในคำค้นเดียว
    String? domainurl, //ค้นหาบทความข่าวจากโดเมนหรือแหล่งข่าวเฉพาะ สามารถเพิ่มโดเมนได้สูงสุด 5 โดเมนในคำค้นเดียว
    String? excludedomain, //ชื่อ domain ข่าวที่ไม่ต้องการ สูงสุด 5
    String? excludefield,
    String? prioritydomain, //ค้นหาบทความข่าวจากโดเมนข่าวชั้นนำเท่านั้น Top: ดึงบทความข่าวจากโดเมนข่าว 10% แรก Medium: ดึงบทความข่าวจากโดเมนข่าว 30% แรก ด้วยLow: ดึงบทความข่าวจากโดเมนข่าว 50% แรก
    int? removeduplicate, //ใช้ค่า 1 เพื่อกำจัดบทความข่าวที่ซ้ำกัน
    int? size, //ปรับแต่งจำนวนบทความที่จะได้รับต่อคำขอ API ได้ตั้งแต่ 1 ถึง 50 บทความ
    String? page, //ไปยังหน้าถัดไป
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

    var response = await _dio.get(url);
    Map<String, dynamic> data = json.decode(response.data);
    print("จาก getNewsDataApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonNewsData(data);

    List<Future<FactCheckResponse>> futureFactCheck = newsResponse.news!.map((n) => getFactCheckApi(query: n.title)).toList();
    List<FactCheckResponse> factcheck = await Future.wait(futureFactCheck);

    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = factcheck[i];
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
    _dio.options.headers = head;
    var response = await _dio.post(url,
        data: json.encode([
          {"text": "$taget"}
        ]));

    var data = json.decode(response.data);
    print("จาก translateText : $data");

    _dio.options.headers = {};
    return data[0]['translations'][0]['text'];
  }

  Future<NewsResponse> getBingSearchNewsApi({
    String? cc, //รหัสประเทศ 2 ตัวอักษรของประเทศที่ผลลัพธ์มาจาก สำหรับรายการค่าที่เป็นไปได้ ต้องระบุส่วนหัว Accept-Language ด้วย
    String? category, //หมวดหมู่ข่าว ใช้คู่กับ mkt
    int? count = 100, //จำนวนบทความข่าว 10-100
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
    if (count != null) url += "&count=$count";
    if (freshness != null) url += "&freshness=$freshness";
    if (mkt != null) url += "&mkt=$mkt";
    if (offset != null) url += "&offset=$offset";

    url += "&originalImg=$originalImg";

    if (q != null) {
      if (q.contains("&")) {
        q = q.replaceAll("&", " and ");
      }
      url += "&q=$q";
    }
    if (safeSearch != null) url += "&safeSearch=$safeSearch";
    if (setLang != null) url += "&setLang=$setLang";
    if (since != null) url += "&since=$since";
    if (sortBy != null) url += "&sortBy=$sortBy";

    _dio.options.headers = {"Ocp-Apim-Subscription-Key": msNewsApiKey};
    var response = await _dio.get(url);
    Map<String, dynamic> data = json.decode(response.data);
    print("จาก getBingSearchNewsApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonBingNewsSearch(data);

    //เช็คการตัวสอบข้อเท็จจริง
    List<Future<FactCheckResponse>> futureFactCheck = newsResponse.news!.map((n) => getFactCheckApi(query: n.title)).toList();
    List<FactCheckResponse> factcheck = await Future.wait(futureFactCheck);
    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = factcheck[i];
    }

    _dio.options.headers = {};
    return newsResponse;
  }

  Future<List<String>> separateWord({
    required String text, //ข้อความที่ต้องการตัดคำ
  }) async {
    String url = "https://api.aiforthai.in.th/tpos?text=$text";
    _dio.options.headers = {
      "Apikey": aiForThaiApiKey,
    };
    var response = await _dio.get(url);
    var data = json.decode(response.data);
    List<dynamic> words = data["words"];
    List<String> noun = [];

    //แยกเอาคำนาม
    for (var i = 0; i < words.length; i++) {
      if (data["tags"][i] == "NN" || data["tags"][i] == "FWN") {
        noun.add(words[i]);
      }
    }
    return noun;
  }
}
