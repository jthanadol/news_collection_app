import 'package:flutter/material.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/api_response/news_response.dart';
import 'package:news_app/app_page/read_new_page.dart';

class WorldPage extends StatefulWidget {
  static const routeName = "/world_page"; //ชื่อที่ใช้อ้างถึงหน้านี้
  const WorldPage({super.key});

  @override
  State<WorldPage> createState() => _WorldPageState();
}

class _WorldPageState extends State<WorldPage> {
  NewsResponse? _newsResponse; //เก็บข่าวที่จะใช้แสดงบนหน้าจอ
  NewsResponse? _newsRaw; //เก็บข่าวที่ดึงจาก api
  NewsResponse? _newTranslate; //เก็บข่าวที่ถูกแปล
  bool _isLoading = false; //สถานะการโหลดข้อมูลข่าวใหม่
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  bool _fillData = false; //สถานะการเติมข้อมูลข่าว
  bool _isTranslate = true; //สถานะว่าจะแสดงแบบแปลภาษาหรือไม่

  String? _country = 'สหรัฐอเมริกา';
  String? _language = "en";
  String _category = 'ธุรกิจ';
  Map<String, String> mapCategory = {
    'ธุรกิจ': 'business',
    'อาชญากรรม': 'crime',
    'ภายในประเทศ': 'domestic',
    'การศึกษา': 'education',
    'บันเทิง': 'entertainment',
    'สิ่งแวดล้อม': 'environment',
    'อาหาร': 'food',
    'สุขภาพ': 'health',
    'ไลฟ์สไตล์': 'lifestyle',
    'อื่นๆ': 'other',
    'การเมือง': 'politics',
    'วิทยาศาสตร์': 'science',
    'กีฬา': 'sports',
    'เทคโนโลยี': 'technology',
    'ยอดนิยม': 'top',
    'การท่องเที่ยว': 'tourism',
    'โลก': 'world',
  };

  Map<String, String> countryCodes = {
    'อัฟกานิสถาน': 'af',
    'แอลเบเนีย': 'al',
    'แอลจีเรีย': 'dz',
    'อันดอร์รา': 'ad',
    'แองโกลา': 'ao',
    'อาร์เจนตินา': 'ar',
    'อาร์เมเนีย': 'am',
    'ออสเตรเลีย': 'au',
    'ออสเตรีย': 'at',
    'อาเซอร์ไบจาน': 'az',
    'บาฮามาส': 'bs',
    'บาห์เรน': 'bh',
    'บังกลาเทศ': 'bd',
    'บาร์เบโดส': 'bb',
    'เบลารุส': 'by',
    'เบลเยียม': 'be',
    'เบลีซ': 'bz',
    'เบนิน': 'bj',
    'เบอร์มิวดา': 'bm',
    'ภูฏาน': 'bt',
    'โบลิเวีย': 'bo',
    'บอสเนียและเฮอร์เซโกวีนา': 'ba',
    'บอตสวานา': 'bw',
    'บราซิล': 'br',
    'บรูไน': 'bn',
    'บัลแกเรีย': 'bg',
    'บูร์กินาฟาโซ': 'bf',
    'บุรุนดี': 'bi',
    'กัมพูชา': 'kh',
    'แคเมอรูน': 'cm',
    'แคนาดา': 'ca',
    'เคปเวิร์ด': 'cv',
    'หมู่เกาะเคย์แมน': 'ky',
    'สาธารณรัฐแอฟริกากลาง': 'cf',
    'ชาด': 'td',
    'ชิลี': 'cl',
    'จีน': 'cn',
    'โคลอมเบีย': 'co',
    'คอโมรอส': 'km',
    'คองโก': 'cg',
    'หมู่เกาะคุก': 'ck',
    'คอสตาริกา': 'cr',
    'โครเอเชีย': 'hr',
    'คิวบา': 'cu',
    'คูราเซา': 'cw',
    'ไซปรัส': 'cy',
    'สาธารณรัฐเช็ก': 'cz',
    'เดนมาร์ก': 'dk',
    'จิบูตี': 'dj',
    'โดมินิกา': 'dm',
    'สาธารณรัฐโดมินิกัน': 'do',
    'สาธารณรัฐประชาธิปไตยคองโก': 'cd',
    'เอกวาดอร์': 'ec',
    'อียิปต์': 'eg',
    'เอลซัลวาดอร์': 'sv',
    'อิเควทอเรียลกินี': 'gq',
    'เอริเทรีย': 'er',
    'เอสโตเนีย': 'ee',
    'สวาซิแลนด์': 'sz',
    'เอธิโอเปีย': 'et',
    'ฟิจิ': 'fj',
    'ฟินแลนด์': 'fi',
    'ฝรั่งเศส': 'fr',
    'เฟรนช์โพลินีเซีย': 'pf',
    'กาบอง': 'ga',
    'กัมเบีย': 'gm',
    'จอร์เจีย': 'ge',
    'เยอรมนี': 'de',
    'กานา': 'gh',
    'ยิบรอลตาร์': 'gi',
    'กรีซ': 'gr',
    'เกรเนดา': 'gd',
    'กัวเตมาลา': 'gt',
    'กินี': 'gn',
    'กายอานา': 'gy',
    'เฮติ': 'ht',
    'ฮอนดูรัส': 'hn',
    'ฮ่องกง': 'hk',
    'ฮังการี': 'hu',
    'ไอซ์แลนด์': 'is',
    'อินเดีย': 'in',
    'อินโดนีเซีย': 'id',
    'อิหร่าน': 'ir',
    'อิรัก': 'iq',
    'ไอร์แลนด์': 'ie',
    'อิสราเอล': 'il',
    'อิตาลี': 'it',
    'ไอวอรีโคสต์': 'ci',
    'จาไมกา': 'jm',
    'ญี่ปุ่น': 'jp',
    'เจอร์ซีย์': 'je',
    'จอร์แดน': 'jo',
    'คาซัคสถาน': 'kz',
    'เคนยา': 'ke',
    'คิริบาส': 'ki',
    'โคโซโว': 'xk',
    'คูเวต': 'kw',
    'คีร์กีซสถาน': 'kg',
    'ลาว': 'la',
    'ลัตเวีย': 'lv',
    'เลบานอน': 'lb',
    'เลโซโท': 'ls',
    'ไลบีเรีย': 'lr',
    'ลิเบีย': 'ly',
    'ลิกเตนสไตน์': 'li',
    'ลิธัวเนีย': 'lt',
    'ลักเซมเบิร์ก': 'lu',
    'มาเก๊า': 'mo',
    'มาซิโดเนีย': 'mk',
    'มาดากัสการ์': 'mg',
    'มาลาวี': 'mw',
    'มาเลเซีย': 'my',
    'มัลดีฟส์': 'mv',
    'มาลี': 'ml',
    'มอลตา': 'mt',
    'หมู่เกาะมาร์แชล': 'mh',
    'มอริเตเนีย': 'mr',
    'มอริเชียส': 'mu',
    'เม็กซิโก': 'mx',
    'ไมโครนีเซีย': 'fm',
    'มอลโดวา': 'md',
    'โมนาโก': 'mc',
    'มองโกเลีย': 'mn',
    'มอนเตเนโกร': 'me',
    'โมร็อกโก': 'ma',
    'โมซัมบิก': 'mz',
    'เมียนมาร์': 'mm',
    'นามิเบีย': 'na',
    'นาอูรู': 'nr',
    'เนปาล': 'np',
    'เนเธอร์แลนด์': 'nl',
    'นิวแคลิโดเนีย': 'nc',
    'นิวซีแลนด์': 'nz',
    'นิการากัว': 'ni',
    'ไนจีเรีย': 'ne',
    'ไนจีเรีย': 'ng',
    'เกาหลีเหนือ': 'kp',
    'นอร์เวย์': 'no',
    'โอมาน': 'om',
    'ปากีสถาน': 'pk',
    'ปาเลา': 'pw',
    'ปาเลสไตน์': 'ps',
    'ปานามา': 'pa',
    'ปาปัวนิวกินี': 'pg',
    'ปารากวัย': 'py',
    'เปรู': 'pe',
    'ฟิลิปปินส์': 'ph',
    'โปแลนด์': 'pl',
    'โปรตุเกส': 'pt',
    'เปอร์โตริโก': 'pr',
    'กาตาร์': 'qa',
    'โรมาเนีย': 'ro',
    'รัสเซีย': 'ru',
    'รวันดา': 'rw',
    'เซนต์ลูเซีย': 'lc',
    'เซนต์มาร์ติน (ดัตช์)': 'sx',
    'ซามัว': 'ws',
    'ซานมาริโน': 'sm',
    'เซาตูเมและปรินซิเป': 'st',
    'ซาอุดีอาระเบีย': 'sa',
    'เซเนกัล': 'sn',
    'เซอร์เบีย': 'rs',
    'เซเชลส์': 'sc',
    'เซียร์ราลีโอน': 'sl',
    'สิงคโปร์': 'sg',
    'สโลวะเกีย': 'sk',
    'สโลวีเนีย': 'si',
    'หมู่เกาะโซโลมอน': 'sb',
    'โซมาเลีย': 'so',
    'แอฟริกาใต้': 'za',
    'เกาหลีใต้': 'kr',
    'สเปน': 'es',
    'ศรีลังกา': 'lk',
    'ซูดาน': 'sd',
    'ซูรินาเม': 'sr',
    'สวีเดน': 'se',
    'สวิตเซอร์แลนด์': 'ch',
    'ซีเรีย': 'sy',
    'ไต้หวัน': 'tw',
    'ทาจิกิสถาน': 'tj',
    'แทนซาเนีย': 'tz',
    'ไทย': 'th',
    'ติมอร์ตะวันออก': 'tl',
    'โตโก': 'tg',
    'ตองกา': 'to',
    'ตรินิแดดและโตเบโก': 'tt',
    'ตูนิเซีย': 'tn',
    'ตุรกี': 'tr',
    'เติร์กเมนิสถาน': 'tm',
    'ตูวาลู': 'tv',
    'ยูกันดา': 'ug',
    'ยูเครน': 'ua',
    'สหรัฐอาหรับเอมิเรตส์': 'ae',
    'สหราชอาณาจักร': 'gb',
    'สหรัฐอเมริกา': 'us',
    'อุรุกวัย': 'uy',
    'อุซเบกิสถาน': 'uz',
    'วานูอาตู': 'vu',
    'วาติกัน': 'va',
    'เวเนซุเอลา': 've',
    'เวียดนาม': 'vi',
    'หมู่เกาะบริติชเวอร์จิน': 'vg',
    'โลก': 'wo',
    'เยเมน': 'ye',
    'แซมเบีย': 'zm',
    'ซิมบับเว': 'zw',
  };

  @override
  void initState() {
    super.initState();
    getNewsFromNewsData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      getNewsFromNewsDataNextPage();
    }
  }

  Future<void> getNewsFromNewsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _newTranslate = null;
      });

      _newsRaw = await ApiAction().getNewsDataApi(
        category: mapCategory[_category],
        country: countryCodes[_country],
        language: _language,
      );
      _newsResponse = _newsRaw;

      getTranslate();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getNewsFromNewsDataNextPage() async {
    try {
      setState(() {
        _errorMessage = null;
        _fillData = true;
      });
      var newsNext = await ApiAction().getNewsDataApi(
        category: mapCategory[_category],
        country: countryCodes[_country],
        language: _language,
        page: _newsResponse!.nextPage,
      );
      NewsResponse n = NewsResponse.copy(newsNext);
      _newsRaw!.news!.addAll(n.news!);
      _newsRaw!.nextPage = n.nextPage;

      for (var i = 0; i < newsNext.news!.length; i++) {
        newsNext.news![i].title = await ApiAction().translateText(taget: newsNext.news![i].title!, to: "th");
        if (newsNext.news![i].description != null) {
          newsNext.news![i].description = await ApiAction().translateText(taget: newsNext.news![i].description!, to: "th");
        }
      }

      _newTranslate!.news!.addAll(newsNext.news!);
      _newTranslate!.nextPage = newsNext.nextPage;

      swapNews();
      setState(() {
        _fillData = false;
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> getTranslate() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      _newTranslate = NewsResponse.copy(_newsRaw!);
      for (var i = 0; i < _newsResponse!.news!.length; i++) {
        _newTranslate!.news![i].title = await ApiAction().translateText(taget: _newTranslate!.news![i].title!, to: "th");
        if (_newTranslate!.news![i].description != null) {
          _newTranslate!.news![i].description = await ApiAction().translateText(taget: _newTranslate!.news![i].description!, to: "th");
        }
      }
      swapNews();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void swapNews() {
    if (_isTranslate) {
      setState(() {
        _newsResponse = _newTranslate;
      });
    } else {
      setState(() {
        _newsResponse = _newsRaw!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    buildPage() => Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _newsResponse!.news!.length,
                itemBuilder: (context, index) {
                  Image? image;
                  if (_newsResponse!.news![index].image_url != null) {
                    image = Image.network(_newsResponse!.news![index].image_url!, errorBuilder: (context, error, stackTrace) => SizedBox.shrink());
                  } else {
                    image = null;
                  }
                  return ListTile(
                    leading: image,
                    title: Text(
                      _newsResponse!.news![index].title!,
                      softWrap: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_newsResponse!.news![index].description != null)
                          Text(
                            _newsResponse!.news![index].description!,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(_newsResponse!.news![index].pubDate!),
                        if (_newsResponse!.news![index].factCheckResponse!.claims!.isEmpty)
                          const Text("ไม่พบการตรวจสอบ")
                        else
                          Text("พบการตรวจสอบทั้งหมด : ${_newsResponse!.news![index].factCheckResponse!.claims!.length} รายการ"),
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(context, ReadNewPage.routeName, arguments: _newsResponse!.news![index]),
                  );
                },
                controller: _scrollController,
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
            if (_fillData) const Text("กำลังโหลดข้อมูลเพิ่มเติม . . ."),
          ],
        );

    buildLoadingOverlay() => Container(color: Colors.black.withOpacity(0.2), child: const Center(child: CircularProgressIndicator()));

    buildErrorPage() => Center(
          child: Text(_errorMessage!),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("World"),
        backgroundColor: Colors.black12,
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isTranslate,
                        onChanged: (value) {
                          setState(() {
                            _isTranslate = value!;
                          });
                          swapNews();
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text("แปลภาษา"),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text("หมวด"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: DropdownButton<String>(
                          onChanged: (String? newValue) {
                            setState(() {
                              _category = newValue!;
                            });
                            getNewsFromNewsData();
                          },
                          items: mapCategory.keys.toList().map<DropdownMenuItem<String>>((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                              ),
                            );
                          }).toList(),
                          value: _category,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text("ประเทศ"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: DropdownButton<String>(
                          onChanged: (String? newValue) {
                            setState(() {
                              _country = newValue!;
                            });
                            getNewsFromNewsData();
                          },
                          items: countryCodes.keys.toList().map<DropdownMenuItem<String>>((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(
                                country,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          value: _country,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_isLoading && _newsResponse != null) buildPage(),
                if (!_isLoading && _newsResponse!.news!.isEmpty)
                  const Center(
                    child: Text("ไม่มีข่าว"),
                  ),
                if (_errorMessage != null) buildErrorPage(),
                if (_isLoading) buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
