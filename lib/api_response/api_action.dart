import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/api_response/fact_check_tools_response.dart';
import 'package:news_app/config/server_config.dart';
import 'package:news_app/manage_file.dart';
import 'news_response.dart';

class ApiAction {
  static final ApiAction apiAction = ApiAction(); //ใช้เป็นตัวกลางในการเรียกใช้ method จากไฟล์อื่นโดยไม่ต้องสร้าง object ซ้ำ
  ApiAction();

  //parameter มี country เช่น 'th' , category เช่น food , date เช่น old(เรียงเก่าไปใหม่) , offset ข้ามข่าว เช่น 10 คือ ข้ามไปทำเอาอันที่ 11 เป็นต้นไป
  Future<NewsResponse> getNews({required String country, required String category, required String date, int offset = 0}) async {
    try {
      String url = '${ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointNews}country=$country&category=$category&date=$date&offset=$offset';
      var response = await http.get(Uri.parse(url));
      print("Method getNews : $url");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
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
  Future<List<Object>> searchNews({required String text, String? since, int offset = 0, required int accountId, bool waitBingSearch = true, bool keepHistory = true}) async {
    String url = "${ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointSearch}offset=$offset&accountId=$accountId";
    if (since != null) {
      url += "&since=$since";
    }
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({"text": text, "waitBingSearch": waitBingSearch, "keepHistory": keepHistory}),
      headers: {"Content-type": "application/json"},
    );
    print("Method getNews : $url");
    try {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return [NewsResponse.fromJson(data), true];
      } else {
        print("method getNews ERROR STATUS : ${response.statusCode}");
        return [NewsResponse.fromJson({}), false];
      }
    } catch (e) {
      print(e);
      return [NewsResponse.fromJson({}), false];
    }
  }

  Future<List<FactCheckResponse>> searchFactCheck({required String query, String? nextPage}) async {
    if (query.contains("&")) {
      query = query.replaceAll("&", " and ");
    }
    String url = "${ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointFactCheck}query=$query";
    if (nextPage != null) {
      url += "&nextPage=$nextPage";
      print("Fact Check : " + url);
    }
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<FactCheckResponse> factCheck = [];
        factCheck.add(FactCheckResponse.fromJson(data['fact_check']));
        factCheck.add(FactCheckResponse.fromJson(data['fact_check_th']));
        return factCheck;
      } else {
        print("Fact Check ERROR");
        List<FactCheckResponse> factCheck = [];
        factCheck.add(FactCheckResponse.fromJson(null));
        factCheck.add(FactCheckResponse.fromJson(null));
        return factCheck;
      }
    } catch (e) {
      print("Fact Check ERROR : $e");
      List<FactCheckResponse> factCheck = [];
      factCheck.add(FactCheckResponse.fromJson(null));
      factCheck.add(FactCheckResponse.fromJson(null));
      return factCheck;
    }
  }

  Future<List<String>> getContent({required int id}) async {
    String url = "${ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointContent}id=$id";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // print(data["data"]["content"]);
        return [data["data"]["content"], data["data"]["content_th"]];
      } else {
        return [];
      }
    } catch (e) {
      print("getContent ERROR : $e");
      return [];
    }
  }

  Future getAudio({required int id}) async {
    String url = "${ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointAudio}id=$id";
    try {
      var response = await http.get(Uri.parse(url));
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return [
          (data['fileTH'] != null) ? '${ServerConfig.serverConfig.urlServer}${data['path'].substring(1)}/th/${data['fileTH']}' : null,
          (data['fileEN'] != null) ? '${ServerConfig.serverConfig.urlServer}${data['path'].substring(1)}/en/${data['fileEN']}' : null,
        ];
      } else {
        return [null, null];
      }
    } catch (e) {
      print('getAudio Error ' + e.toString());
      return [null, null];
    }
  }

  bool checkFact(String text) {
    bool fact = false;
    //ถ้าไม่มีคำว่าไม่
    if (!text.contains("ไม่")) {
      if (text.contains("จริง")) {
        fact = true;
        if (text.contains("จริงบางส่วน")) {
          fact = false;
        }
      } else if (text.contains("เชื่อถือ")) {
        fact = true;
      } else if (text.contains("ถูก")) {
        //ถูกต้อง
        fact = true;
      } else if (text.contains("ยืนยัน")) {
        //ยื่นยันแล้ว
        fact = true;
      } else if (text.contains("รองรับ")) {
        // รับรอง มาจาก Supported
        fact = true;
      } else if (text.contains("ตรวจสอบแล้ว")) {
        //ตรวจสอบแล้ว มาจาก Verified
        fact = true;
      } else if (text.contains("แท้")) {
        fact = true;
      } else if (text.contains("พิสูจน์แล้ว")) {
        fact = true;
      }
    } else {
      //Not Unusual แปลได้เป็น ไม่ผิดปกติ
      if (text.contains("ไม่ผิดปกติ")) {
        fact = true;
      }
    }
    return fact;
  }

  Future<List> login({required String email, required String password}) async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointLogin;
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-type": "application/json"},
    );

    var data = jsonDecode(response.body);
    return [data['msg'], (response.statusCode == 200) ? data['accountId'] : -1];
  }

  Future<List> register({required String email, required String password}) async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointRegister;
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-type": "application/json"},
    );

    var data = jsonDecode(response.body);
    return [data['msg'], response.statusCode == 200];
  }

  Future<List> getOTP({required String email}) async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointOTP;
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({"email": email}),
      headers: {"Content-type": "application/json"},
    );

    var data = jsonDecode(response.body);
    return [data['msg'], response.statusCode == 200];
  }

  Future<List> forgot({required String email, String? otp, String? oldPass, required String password}) async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointForgot;
    Map<String, dynamic> body = (otp != null && otp.isNotEmpty)
        ? {
            "email": email,
            "password": password,
            "otp": otp,
          }
        : {
            "email": email,
            "password": password,
            "oldPassword": oldPass,
          };
    var response = await http.put(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {"Content-type": "application/json"},
    );

    var data = jsonDecode(response.body);
    return [data['msg'], response.statusCode == 200];
  }

  Future<List> googleLogin({required String email, required String googleId}) async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointGoogleLogin;
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({"email": email, "googleId": googleId}),
      headers: {"Content-type": "application/json"},
    );

    var data = jsonDecode(response.body);
    return [data['msg'], (response.statusCode == 200) ? data['accountId'] : -1];
  }

  Future<List<String>> getPopularSearch() async {
    String url = ServerConfig.serverConfig.urlServer + ServerConfig.serverConfig.endPointPopularSearch;
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<String> word = [];
      for (var i = 0; i < data['result'].length; i++) {
        word.add(data['result'][i]['search_text']);
      }
      return word;
    } else {
      return [];
    }
  }

  Future<List> getHistorySearch({required int accountId}) async {
    String url = '${ServerConfig.serverConfig.urlServer}${ServerConfig.serverConfig.endPointSearchHistory}?accountId=$accountId';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<String> word = [];
        List<String> date = [];
        var data = jsonDecode(response.body);
        for (var i = 0; i < data['history'].length; i++) {
          word.add(data['history'][i]['search_text']);
          date.add(data['history'][i]['search_date']);
        }
        return [word, date];
      } else {
        return [];
      }
    } catch (e) {
      print('getHistory Error : ' + e.toString());
      return [];
    }
  }

  Future<bool> downloadFile({required String url, required String fileName}) async {
    try {
      if (await ManageFile.manageFile.checkFileExists(fileName: fileName)) {
        print('มีไฟล์แล้ว');
      } else {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await ManageFile.manageFile.writeFileBytes(fileName: fileName, bytes: response.bodyBytes);
          print('ดาวน์โหลดสำเร็จ');
        }
      }

      return true;
    } catch (e) {
      print('downloadFile Error : ${e.toString()}');
    }

    return false;
  }

  //เช็คว่าเป็น url ไม
  bool isValidUrl({required String url}) {
    try {
      final uri = Uri.parse(url);

      //uri.hasScheme ตรวจว่ามี Scheme หรือไม่ เช่น http, https, ftp, mailto ฯลฯ หรือไม่
      //uri.hasAuthority ตรวจว่ามีdomain name หรือ IP address หรือไม่
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkInternet() async {
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    //ถ้ามีการเชื่อมเน็ตมือถือหรือ wifi ให้ return true
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  void deleteSearchHistory({required int accountId}) async {
    String url = '${ServerConfig.serverConfig.urlServer}${ServerConfig.serverConfig.endPointDeleteSearchHistory}accountId=$accountId';
    try {
      var response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('ลบประวัติการค้นหาเรียบร้อยแล้ว');
      } else {
        print('ลบประวัติการค้นหาไม่สำเร็จ');
      }
    } catch (e) {
      print('deleteSearchHistory Error : ' + e.toString());
    }
  }
}
