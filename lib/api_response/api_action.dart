import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app/config.dart';
import 'news_response.dart';

class ApiAction {
  static final ApiAction apiAction = ApiAction(); //ใช้เป็นตัวกลางในการเรียกใช้ method จากไฟล์อื่นโดยไม่ต้องสร้าง object ซ้ำ
  ApiAction();

  //parameter มี country เช่น 'th' , category เช่น food , date เช่น old(เรียงเก่าไปใหม่) , offset ข้ามข่าว เช่น 10 คือ ข้ามไปทำเอาอันที่ 11 เป็นต้นไป
  Future<NewsResponse> getNews({required String country, required String category, required String date, int offset = 0}) async {
    try {
      String url = '${Config.config.urlServer + Config.config.endPointNews}country=$country&category=$category&date=$date&offset=$offset';
      var response = await http.get(Uri.parse(url));
      print("Method getNews : $url");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        print("method getNews ERROR STATUS : ${response.statusCode}");
        return NewsResponse.fromJson({});
      }
    } catch (e) {
      print(e);
      return NewsResponse.fromJson({});
    }
  }

  //parameter text ใน body คือ คำค้น || since เวลาของข่าวเช่น ตั้งแต่ 2024-1-1 จน ปัจจุบัน, offset ข้ามข่าว เช่น 10 คือ ข้ามไปทำเอาอันที่ 11 เป็นต้นไป
  Future<NewsResponse> searchNews({required String text, String? since, int offset = 0}) async {
    String url = "${Config.config.urlServer + Config.config.endPointSearch}offset=$offset";
    if (since != null) {
      url += "&since=$since";
    }
    var response = await http.post(
      Uri.parse(url),
      body: json.encode({"text": text}),
      headers: {"Content-type": "application/json"},
    );
    print("Method getNews : $url");
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        print("method getNews ERROR STATUS : ${response.statusCode}");
        return NewsResponse.fromJson({});
      }
    } catch (e) {
      print(e);
      return NewsResponse.fromJson({});
    }
  }

  /* Future<String> getVaja9Api({
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
    print(saveFile);
    Options options = Options(headers: {"Apikey": aiForThaiApiKey});
    await _dio.download(wavUrl, saveFile, options: options);
    print("โหลดเสร็จเสร็จ");
    _dio.interceptors.clear();
    return saveFile;

    int textLimit = 150; //จำนวนตัวอักษรสูงสุดที่ vaja9 api รับได้
    List<String> content = _newsTranslate!.content!;
    List<String> word = []; //คำในข้อความ
    String textContent = "";
    for (var i = 0; i < content.length; i++) {
      textContent = content[i].replaceAll("%", " เปอร์เซ็น");
      textContent = textContent.replaceAll("\"", "");
      textContent = textContent.replaceAll("'", "");
      textContent.trim();
      if (!validators.isURL(textContent) && textContent.isNotEmpty) {
        if (textContent.length > textLimit) {
          int sumLength = 0; //จำนวนตัวอักษรที่ถูกแปลงเป็นเสียงแล้ว
          String text = ""; //ข้อความที่จะแปลงเสียง
          int indexOfLastWord = 0; //ตำแหน่งคำสุดท้าย
          for (var j = 0; j < (textContent.length / textLimit).ceil(); j++) {
            if ((sumLength + textLimit) > textContent.length) {
              text = textContent.substring(sumLength, textContent.length);
              text.trim();
              if (text.isNotEmpty) {
                playList.add(await ApiAction.apiAction.getVaja9Api(input_text: text));
                sumLength = textContent.length;
                print(text);
              }
            } else {
              word = await ApiAction.apiAction.separateWord(text: textContent.substring(sumLength, sumLength + textLimit));
              indexOfLastWord = textContent.indexOf(word[word.length - 2], sumLength); //-2 เพื่อเอาคำก่อนตัวสุดท้าย
              text = textContent.substring(sumLength, indexOfLastWord);
              text.trim();
              if (text.isNotEmpty) {
                playList.add(await ApiAction.apiAction.getVaja9Api(input_text: text)); //ดาวน์โหลดไฟล์เสียงและเก็บที่อยู่ลง playList
                sumLength += text.length;
                Future.delayed(const Duration(seconds: 1)); //หยุด 1 วิ เพื่อไม่ให้เกิน Rate limit ของ Vaja9
                print(text);
              }
            }
          }
        } else {
          playList.add(await ApiAction.apiAction.getVaja9Api(input_text: textContent));
          print(textContent);
        }
        Future.delayed(const Duration(seconds: 1)); //หยุด 1 วิ เพื่อไม่ให้เกิน Rate limit ของ Vaja9
      }
  } */
}
