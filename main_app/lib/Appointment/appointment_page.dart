import 'dart:ui';
import 'package:flutter/material.dart';

import '../Settings.dart';
import 'appointment_list_view.dart';
import 'appointment_data.dart';
import 'appointment_theme.dart';
import '../../voice/sound_player.dart';
import '../../voice/socket_tts.dart';
import '../../voice/flutter_tts.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentState  createState() => _AppointmentState ();
}

class _AppointmentState extends State<AppointmentPage> with TickerProviderStateMixin {

  AnimationController? animationController;
  final ScrollController _scrollController = ScrollController();

  final player = SoundPlayer();

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    AppointmentDataModel.generate();
    super.initState();
    player.init();
  }

  @override
  void dispose(){
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Theme(
      data: AppointmentTheme.buildLightTheme(),
      child: Container(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: <Widget>[
                    getAppBarUI(),
                    Expanded(
                      child: NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    return Column(
                                    );
                                  }, childCount: 1),
                            ),
                          ];
                        },
                        body: Container(
                          color:
                          AppointmentTheme.buildLightTheme().backgroundColor,
                          child: AppointmentDataModel.appointments.length == 0 ? get_null_view() : get_list_view()
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container get_null_view(){
    return Container(
      color: AppointmentTheme.buildLightTheme().backgroundColor,
      child: const Center(child: Text('查無回診資訊', style: TextStyle(fontSize: 30),),)
    );
  }

  ListView get_list_view(){
    return ListView.builder(
      itemCount: AppointmentDataModel.appointments.length,
      padding: const EdgeInsets.only(top: 8),
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final int count =
        AppointmentDataModel.appointments.length > 10 ? 10 : AppointmentDataModel.appointments.length;
        final Animation<double> animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: animationController!,
                curve: Interval(
                    (1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        animationController?.forward();
        return AppointmentListView(
          appointmentData: AppointmentDataModel.appointments[index],
          animation: animation,
          animationController: animationController!,
        );
      },
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppointmentTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '回診時間查詢結果',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Container(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

