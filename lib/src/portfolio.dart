import 'course.dart';
import 'tool.dart';

class Portfolio {
  const Portfolio({
    required this.courses,
    required this.tools,
    required this.profileTools,
  });

  final List<Course> courses;
  final List<Tool> tools;
  final List<Tool> profileTools;
}
