import 'package:flutter/material.dart';
import 'package:pink_fluffy_unicorns/MessageSender.dart';

import 'Chat/ChatList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ChatService.writeOwn(email: "s123456@student.dhbw-mannheim.de");

    return MaterialApp(
        title: 'StudConnect',
        theme: ThemeData.dark(),
        /*ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),*/
        //home: Chat(User("s200297@student.dhbw-mannheim.de", "Jonas Lauschke", 0),
        //MessageSender()),
        initialRoute: ChatList.routeName,
        routes: {
          ChatList.routeName: (ctx) => ChatList(),
          ExtractArgumentsChatListScreen.routeName: (ctx) =>
              ExtractArgumentsChatListScreen()
        });
  }
}
