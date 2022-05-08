class Announcement {
  const Announcement({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    required this.guid,
  });

  final String title;
  final String link;
  final String description;
  final String pubDate;
  final String guid;

  @override
  String toString() {
    return """
Title: $title
Link: $link
Description: $description
PubDate: $pubDate
Guid: $guid\n""";
  }
}
