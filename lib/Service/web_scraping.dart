import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class WebScraping {
  final Dio _dio = Dio(BaseOptions(responseType: ResponseType.plain));
  static final WebScraping webScraping = WebScraping();

  Future<List<String>> scrapingThisWeb(String url) async {
    var resposen = await _dio.get(url);
    String htmlString = resposen.data;
    var html = html_parser.parse(htmlString);

    var listH2 = html.querySelectorAll('h2');
    var listP = html.querySelectorAll('p');

    List<String> content = [];

    List<int> indexH2 = [];
    List<int> indexP = [];
    for (var i = 0; i < listH2.length; i++) {
      if (indexH2.length == 0) {
        indexH2.add(htmlString.indexOf("</h2>"));
      } else {
        indexH2.add(htmlString.indexOf("</h2>", indexH2[i - 1] + 1));
      }
    }

    for (var i = 0; i < listP.length; i++) {
      if (indexP.length == 0) {
        indexP.add(htmlString.indexOf("</p>"));
      } else {
        indexP.add(htmlString.indexOf("</p>", indexP[i - 1] + 1));
      }
    }

    String con;
    String? img;
    //ต้องดักพวก tag ที่หลุดเข้ามา
    for (;;) {
      if (listP.isEmpty && listH2.isEmpty) {
        break;
      } else {
        if (indexP.isEmpty) {
          indexP.add(2147483647);
        }
        if (indexH2.isEmpty) {
          indexH2.add(2147483647);
        }
        //print("ตำแหน่ง p : ${indexP[0]} || ตำแหน่ง h2 : ${indexH2[0]}");

        if (indexP[0] < indexH2[0]) {
          con = listP[0].text.trim(); // .text คือเขาข้อมูลภายใน tag ส่วน .trim ใช้ลบช่องว่างหน้าหลังออก
          con.replaceAll('\n', '');
          img = getSrcInImg(con);
          if (img != null) {
            //print("ใส่ของจาก p ที่เป็น img : $img");
            content.add(img);
          } else {
            content.add(con);
            //print("ใส่ของจาก p : $con");
          }
          listP.removeAt(0);
          indexP.removeAt(0);
        } else {
          con = listH2[0].text.trim();
          con.replaceAll('\n', '');
          img = getSrcInImg(con);
          if (img != null) {
            //print("ใส่ของจาก h2 ที่เป็น img : $img");
            content.add(img);
          } else {
            content.add(con);
            //print("ใส่ของจาก h2 : $con");
          }
          listH2.removeAt(0);
          indexH2.removeAt(0);
        }
      }
    }

    return content;
  }

  String? getSrcInImg(String taget) {
    var html = html_parser.parse(taget);
    var img = html.querySelector('img');
    if (img != null) {
      return img.attributes['src'];
    } else {}
    return null;
  }
}
