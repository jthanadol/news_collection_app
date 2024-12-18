import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'fact_check_tools_response.dart';
import 'news_response.dart';

class ApiAction {
  static final ApiAction apiAction = ApiAction(); //ใช้เป็นตัวกลางในการเรียกใช้ method จากไฟล์อื่นโดยไม่ต้องสร้าง object ซ้ำ
  final _dio = Dio(); //ใช้สำหรับโหลดไฟล์เสียง
  String factCheckApiKey = "AIzaSyAdumZj0pFWv-G2vLKhkunwZ10wm_IlPE0"; //key fact chack tools api
  String msNewsApiKey = "f9630a02661f41c1a60f42b8932ea2ba"; //key Bing News Search api
  String newsDataApiKey = "pub_62137fb070f1770c76b5c6f92993530c07d4e"; //key NewsData api
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

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(response.body);
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

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    print("จาก getNewsDataApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonNewsData(data);

    //ค้นหาการตรวจสอบข้อเท็จจริงกับ fact check tools api
    List<Future<FactCheckResponse>> futureFactCheck = newsResponse.news!.map((n) => getFactCheckApi(query: n.title)).toList();
    List<FactCheckResponse> factcheck = await Future.wait(futureFactCheck);
    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = factcheck[i];
    }
    return newsResponse;
  }

  Future<String> translateText({
    required String taget, //ข้อความที่จะแปล
    required String to, //จะแปลเป็นภาษาอะไร
    String? from, //ข้อความ taget เป็นภาษาอะไร ถ้าไม่ใส่ตัว Api จะตรวจจับให้
  }) async {
    String url = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=$to";
    if (from != null) url += "&from=$from";

    var response = await http.post(Uri.parse(url),
        headers: {
          "Content-type": "application/json",
          "Ocp-Apim-Subscription-Key": azureAiTranslatorApiKey,
          "Ocp-Apim-Subscription-Region": "southeastasia",
        },
        body: json.encode([
          {"text": taget}
        ]));

    var data = json.decode(response.body);
    //print("จาก translateText : $data");

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

    var response = await http.get(
      Uri.parse(url),
      headers: {"Ocp-Apim-Subscription-Key": msNewsApiKey},
    );
    Map<String, dynamic> data = json.decode(response.body);
    print("จาก getBingSearchNewsApi : $data");
    NewsResponse newsResponse = NewsResponse.fromJsonBingNewsSearch(data);

    //เช็คการตรวจสอบข้อเท็จจริง
    List<Future<FactCheckResponse>> futureFactCheck = newsResponse.news!.map((n) => getFactCheckApi(query: n.title)).toList();
    List<FactCheckResponse> factcheck = await Future.wait(futureFactCheck);
    for (var i = 0; i < newsResponse.news!.length; i++) {
      newsResponse.news![i].factCheckResponse = factcheck[i];
    }

    return newsResponse;
  }

  Future<List<String>> separateNounWord({
    required String text, //ข้อความที่ต้องการตัดคำ
  }) async {
    String url = "https://api.aiforthai.in.th/tpos";

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Apikey": aiForThaiApiKey,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "text=$text",
    );

    var data = json.decode(response.body);
    List<dynamic> words = data["words"];
    List<String> noun = [];

    //แยกเอาคำนาม
    for (var i = 0; i < words.length; i++) {
      if (data["tags"][i] == "NN" || data["tags"][i] == "FWN") {
        noun.add(words[i]);
      }
    }
    //print(noun.toString());
    return noun;
  }

  Future<String> getVaja9Api({
    required String input_text, //ข้อความที่ต้องการสังเคราะห์เสียง (สูงสุดไม่เกิน 300 ตัวอักษร)
    int speaker = 0, //ประเภทของเสียงที่ต้องการ | 0 : เสียงผู้ชาย | 1 : เสียงผู้หญิง | 2 : เสียงเด็กผู้ชาย | 3 : เสียงเด็กผู้หญิง
    int phrase_break = 0, //ประเภทของการหยุดเว้นวรรค | 0 : หยุดเว้นวรรคแบบอัตโนมัติ | 1 : ไม่หยุดเว้นวรรค
    int audiovisual = 0, //ประเภทของโมเดล | 0 : โมเดลสังเคราะห์เสียง | 1 : โมเดลสังเคราะห์เสียง และภาพ
  }) async {
    //print(input_text);
    var response = await http.post(
      Uri.parse("https://api.aiforthai.in.th/vaja9/synth_audiovisual"),
      headers: {"Apikey": aiForThaiApiKey, "Content-Type": "application/json"},
      body: json.encode({"input_text": input_text, "speaker": speaker, "phrase_break": phrase_break, "audiovisual": audiovisual}),
    );
    var data = json.decode(response.body);

    for (;;) {
      if (data["message"] == null) {
        break;
      }
      response = await http.post(
        Uri.parse("https://api.aiforthai.in.th/vaja9/synth_audiovisual"),
        headers: {"Apikey": aiForThaiApiKey, "Content-Type": "application/json"},
        body: json.encode({"input_text": input_text, "speaker": speaker, "phrase_break": phrase_break, "audiovisual": audiovisual}),
      );
      data = json.decode(response.body);
    }
    String wavUrl = data['wav_url'];
    await Future.delayed(const Duration(seconds: 1)); //หยุด 1 วิเพื่อไม่ให้เกิน rate limit
    //print(wavUrl);
    Directory directory = await getTemporaryDirectory();
    String saveFile = wavUrl.substring(wavUrl.lastIndexOf('/'));
    saveFile = "${directory.path}/audio$saveFile";
    //print(saveFile);
    Options options = Options(headers: {"Apikey": aiForThaiApiKey});
    await _dio.download(wavUrl, saveFile, options: options);
    //print("โหลดเสร็จเสร็จ");
    _dio.interceptors.clear();
    return saveFile;
  }

  Future<List<String>> separateWord({
    required String text, //ข้อความที่ต้องการตัดคำ
  }) async {
    String url = "https://api.aiforthai.in.th/tpos";
    //print("separateWord : $text");
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Apikey": aiForThaiApiKey,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "text=$text",
    );
    var data = json.decode(response.body);
    List<dynamic> dataWord = data["words"];
    List<String> words = dataWord.map((item) => item.toString()).toList();
    return words;
  }
}
