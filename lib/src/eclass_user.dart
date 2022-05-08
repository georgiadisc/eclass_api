import 'dart:core';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'identity/administrator.dart';
import 'identity/identity.dart';
import 'identity/institute.dart';
import 'identity/platform.dart';
import 'announcements.dart';
import 'course.dart';
import 'message.dart';
import 'portfolio.dart';
import 'tool.dart';

typedef InstituteIdentifier = String;

class EclassUser {
  EclassUser({required this.instituteId});

  final InstituteIdentifier instituteId;
  String? _token;
  String? _uid;

  late final _client = http.Client();

  Future<String> get institute async {
    final Identity identity = await getInfo();
    return identity.institute.name;
  }

  Future<bool> get isTokenExpired async {
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mlogin.php',
      ),
      body: {
        'token': _token ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login.');
    }
    return response.body == 'EXPIRED';
  }

  Future<Identity> getInfo() async {
    Iterable<XmlElement> nodes;
    XmlElement node;
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/midentity.php',
      ),
      body: {
        'token': _token ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get info.');
    }
    final decodedResponse = XmlDocument.parse(response.body);
    nodes = decodedResponse.findAllElements('institute');
    node = nodes.first;
    final institute = Institute(
      name: node.attributes[0].value,
      url: node.attributes[1].value,
    );
    nodes = decodedResponse.findAllElements('platform');
    node = nodes.first;
    final platform = Platform(
      name: node.attributes[0].value,
      version: node.attributes[1].value,
    );
    nodes = decodedResponse.findAllElements('administrator');
    node = nodes.first;
    final administrator = Administrator(
      name: node.attributes[0].value,
    );
    return Identity(
      institute: institute,
      platform: platform,
      administrator: administrator,
    );
  }

  Future<void> login(
      {required String username, required String password}) async {
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mlogin.php',
      ),
      body: {
        'uname': username,
        'pass': password,
      },
    );
    if (response.statusCode != 200 || response.body == 'FAILED') {
      throw Exception('Failed to login.');
    }
    _token = response.body;
  }

  Future<void> _getUid() async {
    final response = await _client.get(
      Uri.https(
        'eclass.$instituteId.gr',
        '/main/portfolio.php',
      ),
      headers: {
        'Cookie': 'PHPSESSID=$_token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get uid.');
    }
    final decodedResponse = parse(response.body);
    _uid = decodedResponse
        .getElementsByTagName('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => e.attributes['href'])
        .where((e) => e!.contains('uid'))
        .first
        ?.split('&')
        .last
        .split('=')
        .last;
  }

  Future<String> _getMessageBody({String? messageId}) async {
    final response = await _client.get(
      Uri.https(
        'openeclass.$instituteId.gr',
        '/modules/message/inbox.php',
        {'mid': '$messageId'},
      ),
      headers: {
        'Cookie': 'PHPSESSID=$_token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to get message's body");
    }
    final decodedResponse = parse(response.body);
    final body = decodedResponse.getElementsByClassName('col-xs-12').first;
    return body.innerHtml.toString().trim();
  }

  String _extractSubject({required String subjectResponse}) {
    final decodedResponse = parse(subjectResponse);
    final extractedSubject =
        decodedResponse.getElementsByTagName('a').first.innerHtml;
    return extractedSubject;
  }

  Course _extractCourse({required String courseResponse}) {
    final decodedResponse = parse(courseResponse).getElementsByTagName('a');
    final code = decodedResponse
        .map((e) => e.attributes['href'])
        .first
        ?.split('?')
        .last
        .split('=')
        .last;
    final title = decodedResponse.first.innerHtml;
    final extractedSubject =
        Course(code: code ?? '', title: title, description: '');
    return extractedSubject;
  }

  String _extractSender({required String senderResponse}) {
    final decodedResponse = parse(senderResponse);
    final extractedSender =
        decodedResponse.getElementsByTagName('a').first.innerHtml;
    return extractedSender;
  }

  Future<List<Message>> getMessages() async {
    List<Message> messages = [];
    dynamic jsonDecodedResponse;
    final response = await _client.get(
      Uri.https(
        'openeclass.$instituteId.gr',
        '/modules/message/ajax_handler.php',
        {'mbox_type': 'inbox'},
      ),
      headers: {
        'Cookie': 'PHPSESSID=$_token',
        'iDisplayLength': '-1',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get messages.');
    }
    try {
      jsonDecodedResponse = jsonDecode(response.body);
    } on FormatException {
      throw ("Can't retrieve user's messages because they are not logged in or the token has expired.");
    }
    final document = jsonDecodedResponse["aaData"];
    for (var element in document) {
      var messageResponse = MessageResponse.fromJson(element);
      final body = await _getMessageBody(
        messageId: messageResponse.id,
      );
      final subject = _extractSubject(subjectResponse: messageResponse.subject);
      final course = _extractCourse(courseResponse: messageResponse.course);
      final from = _extractSender(senderResponse: messageResponse.from);
      messages.add(
        Message(
          id: messageResponse.id,
          subject: subject,
          course: course,
          from: from,
          date: messageResponse.date,
          body: body,
        ),
      );
    }
    return messages;
  }

  Future<List<Announcement>> getAnnouncements({String? courseId}) async {
    List<Announcement> announcements = [];
    Announcement announcement;
    XmlDocument xmlDecodedResponse;
    await _getUid();
    var response = await _client.get(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/announcements/',
        {'course': courseId},
      ),
      headers: {'Cookie': 'PHPSESSID=$_token'},
    );
    if (response.statusCode != 200 ||
        response.statusCode == 403 ||
        response.statusCode == 404) {
      throw ("Failed to get course's announcements");
    }
    final htmlDecodedResponse = parse(response.body);
    final link = htmlDecodedResponse
        .getElementsByTagName('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => e.attributes['href'])
        .where((e) => e!.contains('rss'))
        .first
        ?.split('&')
        .last
        .split('=')
        .last;

    if (link != null) {
      response = await _client.get(
        Uri.https(
          'eclass.$instituteId.gr',
          '/modules/announcements/rss.php',
          {
            'c': courseId,
            'uid': _uid,
            'token': link,
          },
        ),
        headers: {'Cookie': 'PHPSESSID=$_token'},
      );
    }
    if (response.statusCode != 200) {
      throw Exception("Failed to get course's announcements.");
    }
    try {
      xmlDecodedResponse =
          XmlDocument.parse(Utf8Codec().decode(response.bodyBytes));
    } on Exception {
      throw ("Can't retrieve course's announcements because user is not logged in or the token has expired.");
    }
    final nodes = xmlDecodedResponse.findAllElements('item');
    for (final node in nodes) {
      announcement = Announcement(
        title: node.children[0].text,
        link: node.children[1].text,
        description: node.children[2].text,
        pubDate: node.children[3].text,
        guid: node.children[4].text,
      );
      announcements.add(announcement);
    }
    return announcements;
  }

  Future<Portfolio> getPortfolio() async {
    List<Course> courses = [];
    List<Tool> tools = [];
    List<Tool> profileTools = [];
    Course course;
    Tool tool;
    Iterable<XmlElement> nodes;
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mportfolio.php',
      ),
      body: {
        'token': _token ?? '',
      },
    );
    if (response.statusCode != 200 || response.body == 'EXPIRED') {
      throw Exception("Failed to get portfolio's courses and tools.");
    }
    final decodedResponse = XmlDocument.parse(response.body);
    nodes = decodedResponse.findAllElements('course');
    for (final node in nodes) {
      course = Course(
        code: node.attributes[0].value,
        title: node.attributes[1].value,
        description: node.attributes[2].value,
      );
      courses.add(course);
    }
    nodes = decodedResponse.findAllElements('tool');
    for (final node in nodes) {
      tool = Tool(
        name: node.attributes[0].value,
        link: node.attributes[1].value,
        redirect: node.attributes[2].value,
        type: node.attributes[3].value,
        active: node.attributes[4].value,
      );
      if (node.attributes[3].value == "coursesubscribe") {
        tools.add(tool);
      } else {
        profileTools.add(tool);
      }
    }
    return Portfolio(
      courses: courses,
      tools: tools,
      profileTools: profileTools,
    );
  }

  Future<List<Tool>> getTools({String? courseId}) async {
    List<Tool> tools = [];
    Tool tool;
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mtools.php',
      ),
      body: {
        'token': _token ?? '',
        'course': courseId,
      },
    );
    if (response.statusCode != 200 ||
        response.body == 'EXPIRED' ||
        response.body == 'FAILED') {
      throw Exception("Failed to get course's tools.");
    }
    final decodedResponse = XmlDocument.parse(response.body);
    final nodes = decodedResponse.findAllElements('tool');
    for (final node in nodes) {
      tool = Tool(
        name: node.attributes[0].value,
        link: node.attributes[1].value,
        redirect: node.attributes[2].value,
        type: node.attributes[3].value,
        active: node.attributes[4].value,
      );
      tools.add(tool);
    }
    return tools;
  }

  Future<List<Course>> getCourses() async {
    List<Course> courses = [];
    Course course;
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mcourses.php',
      ),
      body: {
        'token': _token ?? '',
        'registered': '',
      },
    );
    if (response.statusCode != 200 ||
        response.body == 'EXPIRED' ||
        response.body == 'FAILED') {
      throw Exception("Failed to get user's registered courses.");
    }
    final decodedResponse = XmlDocument.parse(response.body);
    final nodes = decodedResponse.findAllElements('course');
    for (final node in nodes) {
      course = Course(
        code: node.attributes[0].value,
        title: node.attributes[1].value,
        description: node.attributes[2].value,
      );
      courses.add(course);
    }
    return courses;
  }

  Future<void> logout() async {
    final response = await _client.post(
      Uri.https(
        'eclass.$instituteId.gr',
        '/modules/mobile/mlogin.php',
      ),
      body: {
        'token': _token ?? '',
        'logout': '',
      },
    );
    if (response.statusCode != 200 || response.body != 'OK') {
      throw Exception('Failed to logout.');
    }
    _client.close();
  }
}
