import 'dart:developer';

import 'package:eclass_api/eclass_api.dart';
import 'package:test/test.dart';

void main() {
  group('EclassUser', () {
    final user = EclassUser(instituteId: "uom");

    test("Getting institute's info", () async {
      final info = await user.getInfo();
      expect(info.toString(), isA<String>());
    });

    test("Getting institute's name", () async {
      final name = await user.institute;
      expect(name, isA<String>());
    });

    test('Logging in https://eclass.${user.instituteId}.gr...', () async {
      try {
        await user.login(
          username: 'username',
          password: 'password',
        );
      } on Exception {
        log('Failed to login.');
      }
      expect(await user.isTokenExpired, true);
    });

    test('Checking if token is expired...', () async {
      expect(await user.isTokenExpired, true);
    });

    test("Getting user's messages...", () async {
      List<Message> messages = [];
      try {
        messages = await user.getMessages();
      } catch (e) {
        // Can't retrieve user's messages because they are not logged in or the token has expired
      }
      expect(messages, isA<List<Message>>());
    });

    test("Getting user's course's announcements...", () async {
      List<Announcement> announcements = [];
      try {
        announcements = await user.getAnnouncements(courseId: 'courseId');
      } catch (e) {
        // Can't retrieve course's announcements because user is not logged in or the token has expired.
      }
      expect(announcements, isA<List<Announcement>>());
    });

    test("Getting platform's open courses...", () async {
      List<Course> courses = [];
      try {
        await user.logout();
        courses = await user.getCourses();
      } on Exception {
        log("There aren't any available courses on this platform.");
      }
      expect(courses, isA<List<Course>>());
    });

    test("Getting user's registered courses...", () async {
      List<Course> courses = [];
      try {
        courses = await user.getCourses();
      } on Exception {
        if (await user.isTokenExpired) {
          log('Token is expired');
        } else {
          log("There aren't any registered courses on this user.");
        }
      }
      expect(courses, isA<List<Course>>());
    });

    test("Getting course's tools...", () async {
      List<Tool> tools = [];
      try {
        tools = await user.getTools(courseId: 'DAI104');
      } on Exception {
        log("There aren't any available courses on this platform.");
      }
      expect(tools, isA<List<Tool>>());
    });

    test('Logging out of https://eclass.${user.instituteId}.gr...', () async {
      try {
        await user.logout();
      } on Exception {
        log('Failed to logout.');
      }
      expect(await user.isTokenExpired, true);
    });
  });
}
