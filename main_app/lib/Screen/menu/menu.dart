import 'package:flutter/material.dart';
import '../../Settings.dart' as Settings;
import 'menu_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../voice/sound_player.dart';
import '../../voice/socket_tts.dart';
import '../../voice/flutter_tts.dart';


class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}
class _MenuScreenState extends State<MenuScreen> {
  final player = SoundPlayer();

  @override
  void initState(){
    super.initState();
    player.init();
  }
  @override
  void dispose(){
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var card1 = new SizedBox(
      height:300.0,
      width: 410.0,
      child: new IconButton(
        icon:Image.asset('assets/images/search.png', height: 300,),
        iconSize: 280,
        onPressed: () async {
          // await Text2Speech().connect(play, '查詢', "female");
          await Text2SpeechFlutter().speak('查詢');
          print('call');
          Navigator.pushNamed(context, '/search');
        },
      ),
    );
    var card2 = new SizedBox(
      height:300.0,
      width: 410.0,
      child: new IconButton(
        icon:Image.asset('assets/images/telephone.png', height: 300,),
        iconSize: 280,
        onPressed: () async {
        await Text2SpeechFlutter().speak('打電話給計程車');
          _launchUrl();
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("${Settings.userName}，您好~",style: TextStyle(fontSize: 25,color:Colors.white),),
        backgroundColor:Colors.black54,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: Image(image: AssetImage('assets/images/hospital.png')),
            ),
            ListTile(
              title: const Text('提醒家屬',style: TextStyle(fontSize: 25,color:Colors.black)),
              onTap: () async{
                await Text2SpeechFlutter().speak('提醒家屬');
                await Settings.web_module.remind_families(Settings.userID);
              },
            ),
            ListTile(
              title: const Text('登出',style: TextStyle(fontSize: 25,color:Colors.black)),
              onTap: () async{
                await Text2SpeechFlutter().speak('登出帳號');
                Settings.isLogin = false;
                Settings.setLocalData("isLogin", false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: new Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [card1,card2],
        ),
      ),
    );
  }

  Future play(String p) async {
    print('in play');
    await player.play(p);
    setState((){
      player.init();
      player.isPlaying;
    });
  }

  _launchUrl() async {
      const url = 'tel:55688';
      await launch(url);
  }
}