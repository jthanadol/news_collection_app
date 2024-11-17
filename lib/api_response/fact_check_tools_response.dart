class FactCheckResponse {
  List<Claim>? claims;
  String? nextPageToken;

  FactCheckResponse({required this.claims, required this.nextPageToken});

  factory FactCheckResponse.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return FactCheckResponse(claims: [], nextPageToken: null);
    } else {
      List<Claim> c = [];
      for (var item in json['claims']) {
        c.add(Claim.fromJson(item));
      }

      return FactCheckResponse(
        claims: c,
        nextPageToken: json['nextPageToken'],
      );
    }
  }
}

class Claim {
  String text;
  String claimant;
  String claimDate;
  List<ClaimReview> claimReview;

  Claim({
    required this.text,
    required this.claimant,
    required this.claimDate,
    required this.claimReview,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    List<ClaimReview> c = [];
    for (var item in json['claimReview']) {
      c.add(ClaimReview.fromJson(item));
    }

    return Claim(
      text: json['text'],
      claimant: json['claimant'],
      claimDate: json['claimDate'],
      claimReview: c,
    );
  }
}

class ClaimReview {
  Publisher publisher;
  String url;
  String title;
  String reviewDate;
  String textualRating;
  String languageCode;

  ClaimReview({
    required this.publisher,
    required this.url,
    required this.title,
    required this.reviewDate,
    required this.textualRating,
    required this.languageCode,
  });

  factory ClaimReview.fromJson(Map<String, dynamic> json) {
    return ClaimReview(
      publisher: Publisher.fromJson(json['publisher']),
      url: json['url'],
      title: json['title'],
      reviewDate: json['reviewDate'],
      textualRating: json['textualRating'],
      languageCode: json['languageCode'],
    );
  }
}

class Publisher {
  String name;
  String site;

  Publisher({
    required this.name,
    required this.site,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      name: json['name'],
      site: json['site'],
    );
  }
}
