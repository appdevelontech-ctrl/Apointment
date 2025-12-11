class HomeLayoutModel {
  String topBar;
  String sliderImg;
  List<TrendingBanner> trendingBanner;
  List<LatestProductBanner> latestProductBanner;

  HomeLayoutModel({
    required this.topBar,
    required this.sliderImg,
    required this.trendingBanner,
    required this.latestProductBanner,
  });

  factory HomeLayoutModel.fromJson(Map<String, dynamic> json) {
    return HomeLayoutModel(
      topBar: json["top_bar"] ?? "",
      sliderImg: json["slider_img"] ?? "",
      trendingBanner: (json["trending_product_banner"] as List)
          .map((e) => TrendingBanner.fromJson(e))
          .toList(),
      latestProductBanner: (json["latest_product_banner"] as List)
          .map((e) => LatestProductBanner.fromJson(e))
          .toList(),
    );
  }
}

class TrendingBanner {
  String image;
  String url;
  String title;

  TrendingBanner({
    required this.image,
    required this.url,
    required this.title,
  });

  factory TrendingBanner.fromJson(Map<String, dynamic> json) {
    return TrendingBanner(
      image: json["imageInput"] ?? "",
      url: json["imageUrlInput"] ?? "",
      title: json["imageTITInput"] ?? "",
    );
  }
}

class LatestProductBanner {
  String image;
  String url;
  String title;
  String subtitle;

  LatestProductBanner({
    required this.image,
    required this.url,
    required this.title,
    required this.subtitle,
  });

  factory LatestProductBanner.fromJson(Map<String, dynamic> json) {
    return LatestProductBanner(
      image: json["imageInput"] ?? "",
      url: json["imageUrlInput"] ?? "",
      title: json["imageTITInput"] ?? "",
      subtitle: json["imageParaInput"] ?? "",
    );
  }
}
