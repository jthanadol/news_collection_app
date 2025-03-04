import 'fact_check_tools_response.dart';

class NewsResponse {
  List<News>? news;

  NewsResponse({
    required this.news,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    List<News> n = [];
    for (var item in json['results']) {
      n.add(News.fromJson(item));
    }
    return NewsResponse(news: n);
  }

  Map<String, dynamic> toJson() {
    return {'results': news?.map((e) => e.toJson()).toList()};
  }
}

class News {
  int? newId;
  String? title;
  String? description;
  String? imgUrl;
  String? newUrl;
  String? pubDate;
  String? sourceName;
  String? sourceIcon;
  String? titleTh;
  String? descriptionTh;
  FactCheckResponse? factCheck;
  FactCheckResponse? factCheckTh;
  String? content;
  String? contentTh;
  List<String>? audioTh = [];
  List<String>? audioEn = [];

  News({
    this.newId,
    this.title,
    this.description,
    this.imgUrl,
    this.newUrl,
    this.pubDate,
    this.sourceName,
    this.sourceIcon,
    this.titleTh,
    this.descriptionTh,
    this.factCheck,
    this.factCheckTh,
    this.content,
    this.contentTh,
    this.audioTh,
    this.audioEn,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newId: json['new_id'],
      title: json['title'],
      description: json['description'],
      imgUrl: json['img_url'],
      newUrl: json['new_url'],
      pubDate: json['pub_date'],
      sourceName: json['source_name'],
      sourceIcon: json['source_icon'],
      titleTh: json['title_th'],
      descriptionTh: json['description_th'],
      factCheck: FactCheckResponse.fromJson(json['fact_check']),
      factCheckTh: FactCheckResponse.fromJson(json['fact_check_th']),
      content: json['content'],
      contentTh: json['content_th'],
      audioEn: (json['audioEn'] == null) ? [] : json['audioEn'],
      audioTh: (json['audioTh'] == null) ? [] : json['audioTh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_id': newId,
      'title': title,
      'description': description,
      'img_url': imgUrl,
      'new_url': newUrl,
      'pub_date': pubDate,
      'source_name': sourceName,
      'source_icon': sourceIcon,
      'title_th': titleTh,
      'description_th': descriptionTh,
      'fact_check': factCheck?.toJson(),
      'fact_check_th': factCheckTh?.toJson(),
      'content': content,
      'content_th': contentTh,
      'audio_th': audioTh,
      'audio_en': audioEn,
    };
  }
}
