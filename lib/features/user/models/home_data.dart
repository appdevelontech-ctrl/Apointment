class HomeModel {
  final String metaLogo;
  final String footerCredit;
  final List<MenuItem> header;
  final List<MenuItem> footer;

  HomeModel({
    required this.metaLogo,
    required this.footerCredit,
    required this.header,
    required this.footer,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      metaLogo: json["meta_logo"] ?? "",
      footerCredit: json["footer_credit"] ?? "",
      header: (json["header"] as List)
          .map((e) => MenuItem.fromJson(e))
          .toList(),
      footer: (json["footer"] as List)
          .map((e) => MenuItem.fromJson(e))
          .toList(),
    );
  }
}

class MenuItem {
  final int id;
  final String text;
  final String link;
  final String target;

  MenuItem({
    required this.id,
    required this.text,
    required this.link,
    required this.target,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json["id"],
      text: json["text"] ?? "",
      link: json["link"] ?? "",
      target: json["target"] ?? "_self",
    );
  }
}
