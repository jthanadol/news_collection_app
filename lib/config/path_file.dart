import 'package:path_provider/path_provider.dart';

class PathFile {
  String? appDocPath; //ที่อยู่ dir doc ของ app
  String? appCachePath; //ที่อยู่ dir ที่เก็บ cache ของ app

  static PathFile pathFile = PathFile();

  PathFile();

  getDocPath() async {
    if (appDocPath == null) {
      final dir = await getApplicationDocumentsDirectory();
      appDocPath = dir.path;
    }
    return appDocPath;
  }

  getCachePath() async {
    if (appCachePath == null) {
      final dir = await getApplicationCacheDirectory();
      appCachePath = dir.path;
    }
    return appCachePath;
  }
}
