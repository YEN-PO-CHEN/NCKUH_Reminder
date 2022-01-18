import '../Settings.dart';
import 'dart:convert';
import 'dart:async';

class AppointmentData{
  AppointmentData(Map<String, dynamic> data){
    date = data['date'];
    interval = data['interval'];
    type_id = data['type id'];
    type_name = data['type name'];
    doctor_name = data['doctor_name'];
    number = data['number'];
    time_range = data['time range'];
    location = data['location'];
    room = data['room'];
    comment = data['else'];
  }

  String date = "";
  String interval = "";
  String type_id = "";
  String type_name = "";
  String doctor_name = "";
  String number = "";
  String time_range = "";
  String location = "";
  String room = "";
  String comment = "";
}

class AppointmentDataModel{
  static List<AppointmentData> appointments = [];

  static Future<void> generate() async {
    print('userid = ' + userID);
    var lt = await web_module.get_return_appointment_list(userID);
    appointments.clear();
    for(int i=0;i<lt.length;i+=1){
      print(jsonEncode(lt[i]) + '\n');
      appointments.add(AppointmentData(lt[i]));
    }
  }
}