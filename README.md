# eclass_api

This is a client for the Open eClass Platform mobile API written in Dart inspired by https://github.com/amoraitis/EclassMobileApi

## Features

- Retrieve information about the institute, such as the name and the url.
- Get user's registered courses.
- Get the available courses in the platform (opencourses).
- Get the course's tools.
- Get user's portfolio courses and tools.
- Get course's announcements.
- Retrieve user's messages.

## Installation

```console
> dart pub add eclass_api
```


## Getting started

Create an instance of EclassUser:

```dart
import 'package:eclass_api/eclass_api.dart' as eclass;

Future<void> main() async {
  final user = eclass.User(instituteId: 'uom');
}
```

## Examples

Get institute's info:
```dart
final info = await user.getInfo();
print(info.toString());
```

Get institute's name: 
```dart
final name = await user.institute;
print(name);
```

Log in (e.g https://eclass.uom.gr):
```dart
// Logging in https://eclass.${user.instituteId}.gr...
await user.login(username: 'username', password: 'password');
```

Check if token is expired:
```dart
if (await user.isTokenExpired) {
  // Token is expired
} else {
  // Token is valid
}
```

Get user's messages:
```dart
final messages = await user.getMessages();
```

Get user's course's announcements:
```dart
final announcements = await user.getAnnouncements(courseId: 'courseId');
```

Get user's registered courses:
```dart
final courses = await user.getCourses();
```

Get course's tools:
```dart
final tools = await user.getTools(courseId: 'courseId');
```

Get user's portfolio courses and tools:
```dart
final portfolio = await user.getPortfolio();
```


Log out of (e.g https://eclass.uom.gr):
```dart
// Logging out of https://eclass.${user.instituteId}.gr...
await user.logout();
```

## Additional information

For a more complete example look in the example folder.

