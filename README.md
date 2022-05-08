# eclass_api

This is a client for the Open eClass Platform mobile API written in Dart inspired by https://github.com/amoraitis/EclassMobileApi

## Installation

```console
> dart pub add eclass_api
```

## Features

- **login({required String username, required String password})**: Get's user's token and saves it as a parameter inside the class instance for later use.

- **getInfo()**: Returns information about the institute such as its name and its url.

- **getCourses()**: If user is logged in, it returns the list of user's registered courses, otherwise, it returns a list of available courses in platform (opencourses).

- **getTools({required String courseId})**: Returns the course tools for a specific course (ie the left menu). It works in the same way as the regular menu, ie if the user logged in is an instructor it returns 2 additional groups of tools (inactive and management).

- **getPortfolio()**: Returns the list of user's registered courses along with their profile tools.

- **getAnnouncements({required String courseId})**: Returns the list of course's announcements. Requires that a user is logged in.

- **getMessages()**: Returns the list of user's messages.

- **logout()**: Session destruction and logout.

## Getting started

Create an instance of EclassUser:

```dart
import 'package:eclass_api/eclass_api.dart';

Future<void> main() async {
  final user = EclassUser(instituteId: 'uom');
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
