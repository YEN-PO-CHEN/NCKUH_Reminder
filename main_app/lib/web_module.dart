import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'Settings.dart' as Setting;
class WebModule{
  String server_url = Setting.server_url;

  Future<List<Map<String, dynamic>>> get_return_appointment_list(String id) async {
    var response = await http.get(Uri.parse(server_url + 'get_return_list/' + id));
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Map<String, dynamic>> lt = [];
      for(int i=0;i<data["appointments"].length;i+=1) {
        lt.add(data["appointments"][i]);
      }
      return lt;
    }
    else{
      return [];
    }
  }

  Future<bool> remind_families(String ID_number) async {
    var response = await http.get(Uri.parse(server_url + 'remind_families/' + ID_number));
    print(response.body);
    return parseBool(response.body);
  }

  Future<bool> check_user_by_ID_number(String ID_number) async {
    var response = await http.get(Uri.parse(server_url + 'check_user_by_ID_number/' + ID_number));
    print(response.body);
    return parseBool(response.body);
  }

  Future<Map<String, dynamic>> get_user_profile_by_ID_number(String ID_number) async {
    var response = await http.get(Uri.parse(server_url + 'get_user_profile_by_ID_number/' + ID_number));
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      return {};
    }
  }

  Future<Map<String, dynamic>> save_user_data(var profile) async {
    var response = await http.get(Uri.parse(server_url + 'save_user_data/' + jsonEncode(profile)));
    if(response.statusCode == 200) {
      bool save_ok = parseBool(response.body);
      return {"status":true, "save ok":save_ok};
    }
    else{
      return {"status":false, "save ok":false};
    }
  }

  bool parseBool(String s) {
    return s.toLowerCase() == 'true';
  }
}