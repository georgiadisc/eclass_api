import 'package:eclass_api/src/identity/administrator.dart';
import 'package:eclass_api/src/identity/institute.dart';
import 'package:eclass_api/src/identity/platform.dart';

class Identity {
  const Identity({
    required this.institute,
    required this.platform,
    required this.administrator,
  });
  final Institute institute;
  final Platform platform;
  final Administrator administrator;

  @override
  String toString() {
    return """
Institute:
  Name: ${institute.name}
  Url: ${institute.url}
Platform:
  Name: ${platform.name}
  Version: ${platform.version}
Administrator:
  Name: ${administrator.name}\n""";
  }
}
