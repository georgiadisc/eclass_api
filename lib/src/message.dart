import 'package:eclass_api/src/course.dart';

class Message {
  const Message({
    required this.id,
    required this.subject,
    required this.course,
    required this.from,
    required this.date,
    required this.body,
  });

  final String id;
  final String subject;
  final Course course;
  final String from;
  final String date;
  final String body;

  @override
  String toString() {
    return """
Id: $id
Subject: $subject
Course: ${course.title}
From: $from
Date: $date
Body: $body\n""";
  }
}

class MessageResponse {
  const MessageResponse({
    required this.id,
    required this.subject,
    required this.course,
    required this.from,
    required this.date,
  });

  final String id;
  final String subject;
  final String course;
  final String from;
  final String date;

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['DT_RowId'],
      subject: json['0'],
      course: json['1'],
      from: json['2'],
      date: json['3'],
    );
  }
  @override
  String toString() {
    return """
Id: $id
Subject: $subject
Course: $course
Date: $date
From: $from\n""";
  }
}
