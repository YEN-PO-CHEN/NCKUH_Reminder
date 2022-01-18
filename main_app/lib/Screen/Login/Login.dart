import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../../Settings.dart' as Settings;
import '../menu/menu.dart';


class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);
  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {

      var ID_number  = data.name.substring(0, 10);
      var result = await Settings.get_and_check_web(ID_number, data.password, "這是名字的位置",  true);

      if(result['exist'] == true){
        Settings.setLocalData('userID', Settings.userID);
        Settings.setLocalData('userName', Settings.userName);
        Settings.setLocalData('isLogin', true);
        return null;
      }
      else
        return "查無此帳號";
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {

      var ID_number = data.name.toString().substring(0, 10);
      var user_name = data.name.toString().substring(10);
      var result = await Settings.get_and_check_web(ID_number, data.password.toString(), user_name, false);

      if(result['status'] == true)
        if(result['exist'] == false){
          Settings.setLocalData('userID', Settings.userID);
          Settings.setLocalData('userName', Settings.userName);
          Settings.setLocalData('isLogin', true);
          return null;
        }
      return "帳號已存在";
    });
  }
  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  static String? User_Validator(value) {
    if (value!.isEmpty) {
      return '請輸入正確的身分證字號!';
    }
    return null;
  }
  static String? Password_Validator(value) {
    if (value!.isEmpty || value.length != 8) {
      return '請輸入正確的生日!';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlutterLogin(
        title: '成大醫院就診查詢',
        logo: AssetImage("assets/images/megaphone.png"),
        onLogin: _authUser,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MenuScreen(),
          ));
        },
        theme: LoginTheme(
          beforeHeroFontSize: 30,

        ),
        // userType: LoginUserType.name,
        messages: LoginMessages(
          userHint: '身分證字號 + 姓名 (A123456789王曉明)',
          passwordHint: '出生年月日(19990801)',
          confirmPasswordHint: '請再次確認您的生日',
          loginButton: '登入',
          signupButton: '建立帳號',
        ),
        userValidator: User_Validator,
        passwordValidator: Password_Validator,
        hideForgotPasswordButton: true,
        onRecoverPassword: (name) {
          debugPrint('Recover password info');
          debugPrint('Name: $name');
          return _recoverPassword(name);
        },
      ),
    );
  }
}