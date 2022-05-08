class Tool {
  const Tool({
    required this.name,
    required this.link,
    required this.redirect,
    required this.type,
    required this.active,
  });

  final String name;
  final String link;
  final String redirect;
  final String type;
  final String active;

  @override
  String toString() {
    return """
Name: $name
Link: $link
Redirect: $redirect
Type: $type
Active: $active\n""";
  }
}
