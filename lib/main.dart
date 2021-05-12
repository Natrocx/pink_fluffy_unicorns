import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pink_fluffy_unicorns/Greeter.dart';

import 'Chat/ChatList.dart';
import 'ChatService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ChatService.writeOwn(email: "s123456@student.dhbw-mannheim.de");
    ChatService.clearAllData();

    return MaterialApp(
        title: 'StudConnect',
        theme: ThemeData.dark(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          //const Locale('en', ''), // TBD?
          const Locale('de', ''),
        ],
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
        initialRoute: Greeter.routeName,
        routes: {
          ChatList.routeName: (ctx) => ChatList(),
          Greeter.routeName: (ctx) => Greeter(),
          ExtractArgumentsChatScreen.routeName: (ctx) =>
              ExtractArgumentsChatScreen(),
          StudentRegistration.routeName: (ctx) => StudentRegistration(),
          DozentRegistration.routeName: (ctx) => DozentRegistration(),
        });
  }
}
