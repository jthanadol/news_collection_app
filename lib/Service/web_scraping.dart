import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class WebScraping {
  Future<List<String>> scrapingThisWeb(String url) async {
    var resposen = await http.get(Uri.parse(url));
    String html_string = resposen.body;
    var html = html_parser.parse(html_string);
    //debugPrint(html_string);

    var listH2 = html.querySelectorAll('h2');
    var listP = html.querySelectorAll('p');

    List<String> content = [];

    List<int> indexH2 = [];
    List<int> indexP = [];
    for (var i = 0; i < listH2.length; i++) {
      if (indexH2.length == 0) {
        indexH2.add(html_string.indexOf("</h2>"));
      } else {
        indexH2.add(html_string.indexOf("</h2>", indexH2[i - 1] + 1));
      }
    }

    for (var i = 0; i < listP.length; i++) {
      if (indexP.length == 0) {
        indexP.add(html_string.indexOf("</p>"));
      } else {
        indexP.add(html_string.indexOf("</p>", indexP[i - 1] + 1));
      }
    }

    String con;
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
        print("ตำแหน่ง p : ${indexP[0]} || ตำแหน่ง h2 : ${indexH2[0]}");

        if (indexP[0] < indexH2[0]) {
          con = listP[0].text.trim();
          content.add(con); // .text คือเขาข้อมูลภายใน tag ส่วน .trim ใช้ลบช่องว่างหน้าหลังออก
          listP.removeAt(0);
          indexP.removeAt(0);
          print("ใส่ของจาก p : $con");
        } else {
          con = listH2[0].text.trim();
          content.add(con);
          listH2.removeAt(0);
          indexH2.removeAt(0);
          print("ใส่ของจาก h2 : $con");
        }
      }
    }
    print("จบ loop");

    return content;
  }
}
