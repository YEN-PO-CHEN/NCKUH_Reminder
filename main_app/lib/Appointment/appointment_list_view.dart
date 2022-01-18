import 'package:flutter/material.dart';
import 'appointment_data.dart';
import '../../voice/sound_player.dart';
import '../../voice/socket_tts.dart';
import '../../voice/flutter_tts.dart';


class AppointmentListView extends StatelessWidget {
  const AppointmentListView (
      {Key? key,
        this.appointmentData,
        this.animationController,
        this.animation,})
      : super(key: key);

  final AppointmentData? appointmentData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext context, Widget? child){
      return FadeTransition(
        opacity: animation!,
        child: Transform(
          transform: Matrix4.translationValues(
              0.0, 50 * (1.0 - animation!.value), 0.0),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 10),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () async {
                String s = "日期 " + appointmentData!.date;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 4));
                s = "時段 " + appointmentData!.interval;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 2));
                s = "時間 " + appointmentData!.time_range;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 5));
                s = "科別 " + appointmentData!.type_name;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 3));
                s = "醫生 "+ appointmentData!.doctor_name;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 2));
                s = "看診號碼 "+ appointmentData!.number;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 2));
                s = "地點 "+ appointmentData!.location;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 3));
                s = "診療室"+ appointmentData!.room;
                await Text2SpeechFlutter().speak(s);
                await Future.delayed(Duration(seconds: 4));


              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  color: Color.fromARGB(128, 218, 255, 239),
                  border: Border.all(color: Color.fromARGB(128, 100, 182, 172), width: 5)
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
                    child: get_container(),
                  )
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Container get_container(){
    return Container(
      child: Column(
        children: <Widget> [
          get_row("日期", appointmentData!.date),
          get_row("時段", appointmentData!.interval),
          get_row("時間", appointmentData!.time_range),
          get_row("科別", appointmentData!.type_name),
          get_row("醫生", appointmentData!.doctor_name),
          get_row("號碼", appointmentData!.number),
          get_row("地點", appointmentData!.location),
          get_row("診療室", appointmentData!.room),

          if(appointmentData!.comment.length != 0)
            get_row("備註", appointmentData!.comment),
        ],
      ),
    );
  }

  Row get_row(String left, String right){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [get_text(left), get_text(right)],
    );
  }

  Text get_text(String str, {double size = 25}){
    return Text(
      str,
      style: TextStyle(fontSize: size)
    );
  }
}