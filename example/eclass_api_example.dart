import 'package:eclass_api/eclass_api.dart';

Future<void> main() async {
  // Creating an instance of: EclassUser...
  final user = EclassUser(instituteId: "instituteId");
  // Institute: ${await user.institute}.

  // Getting institute's info
  final info = await user.getInfo();
  print(info.toString());

  // Logging in https://eclass.${user.instituteId}.gr...
  try {
    await user.login(username: 'username', password: 'password');
  } on Exception {
    // Handle failed login request
  }

  // Checking if token is expired...
  if (await user.isTokenExpired) {
    // Token is expired
  } else {
    // Token is valid
  }

  // Getting user's messages...
  final messages = await user.getMessages();
  // Messages:
  for (var message in messages) {
    print(message.toString());
  }

  // Getting user's course's announcements...
  final announcements = await user.getAnnouncements(courseId: 'courseId');
  // Announcements:
  for (final announcement in announcements) {
    print(announcement.toString());
  }

  // Getting user's portfolio courses and tools...
  final portfolio = await user.getPortfolio();
  // Portfolio Courses:
  for (var course in portfolio.courses) {
    print(course.toString());
  }
  // Portfolio Tools:
  for (var tool in portfolio.tools) {
    print(tool.toString());
  }
  // Portfolio Tools:
  for (var profileTool in portfolio.profileTools) {
    print(profileTool.toString());
  }

  // Getting user's registered courses...
  final courses = await user.getCourses();
  // Courses:
  for (var course in courses) {
    print(course.toString());
  }

  // Getting course's tools...
  final tools = await user.getTools(courseId: 'courseId');
  // Tools:
  for (var tool in tools) {
    print(tool.toString());
  }

  // Logging out of https://eclass.${user.instituteId}.gr...
  try {
    await user.logout();
    // Logged out
  } on Exception {
    // Handle failed logout request
  }
}
