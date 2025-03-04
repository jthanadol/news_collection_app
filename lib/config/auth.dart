import 'package:news_app/config/path_file.dart';
import 'package:news_app/manage_file.dart';

class Auth {
  static Auth auth = Auth();

  String email = '';
  int accountId = -1;
  String accountType = '';
  bool isLogin = false;

  String _fileName = '';

  Auth();

  Future<void> login({required String email, required int accountId, required String accountType}) async {
    this.email = email;
    this.accountId = accountId;
    this.accountType = accountType;
    isLogin = true;
    if (!(await ManageFile.manageFile.checkFileExists(fileName: _fileName))) {
      Map<String, dynamic> data = {'email': this.email, 'accountId': accountId, 'accountType': accountType};
      await ManageFile.manageFile.writeFileJson(fileName: _fileName, data: data);
    }
  }

  Future<void> logout() async {
    email = '';
    accountId = -1;
    accountType = '';
    isLogin = false;
    await ManageFile.manageFile.deleteOneFile(fileName: _fileName);
  }

  Future<void> readLoginFile() async {
    _fileName = (await PathFile.pathFile.getDocPath()) + '/auth';
    await ManageFile.manageFile.createDir(dirPath: _fileName);
    _fileName += '/auth_login.json';
    if (await ManageFile.manageFile.checkFileExists(fileName: _fileName)) {
      Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: _fileName);
      login(email: data['email'], accountId: data['accountId'], accountType: data['accountType']);
    }
  }
}
