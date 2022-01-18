import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'web_module.dart';

var web_module = WebModule();

bool isLogin = false;
String userID = "";   // 身分證字號
String userName = ""; // 名字

String server_url = 'http://172.20.10.4:4000/';

void getLocalData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLogin = prefs.getBool('isLogin') ?? false;
  if(isLogin == true) {
    userID = prefs.getString('userID') ?? "查無此人";
    userName = prefs.getString('userName') ?? "查無此人";
  }
}

void setLocalData(String name,var index) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (name=='isLogin')
    await prefs.setBool('isLogin', index);
  else if(name == 'userID')
    await prefs.setString('userID', index);
  else if(name == 'userName')
    await prefs.setString('userName', index);
}

Future<Map<String, dynamic>> get_and_check_web(String ID_number, String birth, String? name, bool is_login) async
{
  // webmodule => fetch json
  // var Web = get_and_check(name,birth,is_birth); //A list requesr from web_module
  // if(Web["status"]==false)
  //   return false;
  // userID = Web["id"];
  // userName = Web["name"];

  // is_login == true,  return true, true ==> user is exist,  return true, false ==> user is not found
  // is_login == flase, return true, false ==> not exist, save successfully, return true, true ==> exist, go to login,  return false, false ==> error
  if(is_login == true){
    var exist = await web_module.check_user_by_ID_number(ID_number);
    if(exist == true){
      var profile = await web_module.get_user_profile_by_ID_number(ID_number);
      userID = profile['id'];
      userName = profile['name'];
      isLogin = true;
      print('1');
      return {"status":true, "exist": true};
    }
    else {
      isLogin = false;
      print('2');
      return {"status":true, "exist": false};
    }
  }
  else{
    String _name = name == null ? "" : name;
    var profile = {"name": _name, "ID_number": ID_number, "birth": birth};
    var result = await web_module.save_user_data(profile);
    if(result['status'] == true){
      if(result['save ok'] == true){
        var profile = await web_module.get_user_profile_by_ID_number(ID_number);
        userID = profile['id'];
        userName = profile['name'];
        isLogin = true;
        print('3');
        return {"status":true, "exist": false};
      }
      else{
        isLogin = false;
        print('4');
        return {"status":true, "exist": true};
      }
    }
    else{
      isLogin = false;
      print('5');
      return {"status":false, "exist": false};
    }
  }
}


class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}