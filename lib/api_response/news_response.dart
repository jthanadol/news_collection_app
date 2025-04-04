import 'fact_check_tools_response.dart';

class NewsResponse {
  List<News>? news;

  NewsResponse({
    required this.news,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    List<News> n = [];
    if (json['results'] != null) {
      for (var item in json['results']) {
        n.add(News.fromJson(item));
      }
    }

    return NewsResponse(news: n);
  }

  Map<String, dynamic> toJson() {
    return {'results': news?.map((e) => e.toJson()).toList()};
  }
}

class News {
  int? newsId;
  String? title;
  String? description;
  String? imgUrl;
  String? newsUrl;
  String? pubDate;
  String? sourceName;
  String? sourceIcon;
  String? titleTh;
  String? descriptionTh;
  FactCheckResponse? factCheck;
  FactCheckResponse? factCheckTh;
  String? content;
  String? contentTh;
  String? audioTH;
  String? audioEN;

  News({
    this.newsId,
    this.title,
    this.description,
    this.imgUrl,
    this.newsUrl,
    this.pubDate,
    this.sourceName,
    this.sourceIcon,
    this.titleTh,
    this.descriptionTh,
    this.factCheck,
    this.factCheckTh,
    this.content,
    this.contentTh,
    this.audioTH,
    this.audioEN,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['news_id'],
      title: json['title'],
      description: json['description'],
      imgUrl: json['img_url'],
      newsUrl: json['news_url'],
      pubDate: json['pub_date'],
      sourceName: json['source_name'],
      sourceIcon: json['source_icon'],
      titleTh: json['title_th'],
      descriptionTh: json['description_th'],
      factCheck: FactCheckResponse.fromJson(json['fact_check']),
      factCheckTh: FactCheckResponse.fromJson(json['fact_check_th']),
      content: json['content'],
      contentTh: json['content_th'],
      audioEN: json['audio_en'],
      audioTH: json['audio_th'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'news_id': newsId,
      'title': title,
      'description': description,
      'img_url': imgUrl,
      'news_url': newsUrl,
      'pub_date': pubDate,
      'source_name': sourceName,
      'source_icon': sourceIcon,
      'title_th': titleTh,
      'description_th': descriptionTh,
      'fact_check': factCheck?.toJson(),
      'fact_check_th': factCheckTh?.toJson(),
      'content': content,
      'content_th': contentTh,
      'audio_th': audioTH,
      'audio_en': audioEN,
    };
  }
}
