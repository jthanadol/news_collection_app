class ServerConfig {
  static final serverConfig = ServerConfig();
  final urlServer = "https://web-api-news-hqdndegnhkdfeafm.malaysiawest-01.azurewebsites.net"; //domainname server
  final endPointNews = "/news?"; //endpoint ของการขอข้อมูลข่าว
  final endPointSearch = "/search?"; //endpoint ของการค้นหาข่าว
  final endPointFactCheck = "/factcheck?"; //endpoint ของการค้นการตัวสอบข้อเท็จจริง
  final endPointContent = "/content?"; //endpoint ขอเนื้อหาข่าว
  final endPointAudio = '/audio?'; //endpoint ขอรายการไฟล์เสียง
  final endPointLogin = '/login'; //endpoint เข้าสู่ระบบ
  final endPointRegister = '/register'; //endpoint สมัครสมาชิก
  final endPointOTP = '/OTP'; //endpoint ขอ OTP
  final endPointForgot = '/forgot'; // endpoint เปลี่ยนรหัสผ่าน
  final endPointGoogleLogin = '/googleLogin'; //endpoint เข้าสู่ระบบด้วย google
  final endPointPopularSearch = '/popularSearch'; //คำยอดนิยมในการค้นหา
  final endPointSearchHistory = '/searchHistory'; //ประวัติการค้นหา
  final endPointDeleteSearchHistory = '/deleteSearchHistory?'; //ลบประวัติการค้นหา

  final category = {
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

  final country = {
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
    'ไนเจอร์': 'ne',
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

  ServerConfig();
}
