import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ManageFile {
  static final ManageFile manageFile = ManageFile();

  ManageFile();

  Future<bool> checkFileExists({required String fileName}) async {
    return await File(fileName).exists();
  }

  Future<void> writeFileJson({required String fileName, required var data}) async {
    var file = File(fileName);
    String jsonString = jsonEncode(data);
    // print(jsonString);
    await file.writeAsString(jsonString);
    print('writeFileJson สำเร็จ : $fileName');
  }

  Future<void> writeFileBytes({required String fileName, required Uint8List bytes}) async {
    File file = File(fileName);
    await file.writeAsBytes(bytes);
    print('writeFileBytes สำเร็จ : $fileName');
  }

  dynamic readFileJson({required String fileName}) async {
    var file = File(fileName);
    String jsonString = await file.readAsString();
    // print(jsonString);
    var data = jsonDecode(jsonString);
    print('readFileJson สำเร็จ : $fileName');
    return data;
  }

  Future<Uint8List> readFileBytes({required String fileName}) async {
    var file = File(fileName);
    var bytes = await file.readAsBytes();
    print('readFileBytes สำเร็จ : $fileName');
    return bytes;
  }

  Future<void> deleteAllFilesInDir({required String pathDir}) async {
    var files = Directory(pathDir).listSync();
    // ลบไฟล์ทีละไฟล์
    for (var file in files) {
      if (file is File) {
        await file.delete();
        print('Deleted: ${file.path}');
      }
    }
  }

  Future<void> deleteOneFile({required String fileName}) async {
    var file = File(fileName);
    if (await checkFileExists(fileName: fileName)) {
      await file.delete();
      print('Deleted: ${file.path}');
    }
  }

  Future<void> createDir({required String dirPath}) async {
    Directory dir = Directory(dirPath);
    if (!(await dir.exists())) {
      //ถ้าไม่มี dir
      await dir.create(recursive: true);
      print('สร้าง dir : $dirPath เรียบร้อย');
    } else {
      print('มี dir : $dirPath อยู่แล้ว');
    }
  }

  Future<bool> copyFile({required String sourcePath, required String copyPath}) async {
    if (await checkFileExists(fileName: sourcePath)) {
      await File(sourcePath).copy(copyPath);
      return true;
    } else {
      return false;
    }
  }
}
