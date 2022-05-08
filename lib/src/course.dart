class Course {
  const Course({
    required this.code,
    required this.title,
    required this.description,
  });

  final String code;
  final String title;
  final String description;

  @override
  String toString() {
    return """
Code: $code
Title: $title
Description: $description\n""";
  }
}
