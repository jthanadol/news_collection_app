import 'fact_check_tools_response.dart';

class NewsResponse {
  List<News>? news;
  String? nextPage;

  NewsResponse({
    required this.news,
    this.nextPage,
  });

  NewsResponse.copy(NewsResponse taget) {
    news = taget.news!.map((n) => News.copy(n)).toList();
  }

  factory NewsResponse.fromJsonNewsData(Map<String, dynamic> json) {
    List<News> n = [];
    for (var item in json['results']) {
      n.add(News.fromNewsData(item));
    }
    return NewsResponse(news: n, nextPage: json['nextPage']);
  }

  factory NewsResponse.fromJsonBingNewsSearch(Map<String, dynamic> json) {
    List<News> n = [];
    for (var item in json['value']) {
      n.add(News.fromNewsData(item));
    }
    return NewsResponse(news: n);
  }
}

class News {
  String? title;
  String? linkNews;
  String? description;
  List<String>? content = [];
  String? pubDate;
  String? image_url;
  String? source_id;
  String? source_icon;
  FactCheckResponse? factCheckResponse;

  News({
    required this.title,
    required this.linkNews,
    required this.description,
    required this.pubDate,
    required this.image_url,
    required this.source_id,
    required this.source_icon,
  });

  News.copy(News taget) {
    title = taget.title;
    linkNews = taget.linkNews;
    description = taget.description;
    content!.addAll(taget.content!);
    pubDate = taget.pubDate;
    image_url = taget.image_url;
    source_icon = taget.source_icon;
    source_id = taget.source_id;
    factCheckResponse = FactCheckResponse.copy(taget.factCheckResponse!);
  }

  factory News.fromNewsData(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      linkNews: json['link'],
      description: json['description'],
      pubDate: json['pubDate'],
      image_url: json['image_url'],
      source_id: json['source_id'],
      source_icon: json['source_icon'],
    );
  }

  factory News.fromBingNewsSearch(Map<String, dynamic> json) {
    return News(
      title: json['name'],
      linkNews: json['url'],
      description: json['description'],
      pubDate: json['datePublished'],
      image_url: json['image']['thumbnail']['contentUrl'],
      source_id: json['provider'][0]['name'],
      source_icon: json['provider'][0]['image']['thumbnail']['contentUrl'],
    );
  }
}
