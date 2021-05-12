import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pink_fluffy_unicorns/Greeter.dart';

import 'Chat/ChatList.dart';
import 'ChatService.dart';

void main() {
  runApp(PinkFluffyUnicornsApp());
}

class PinkFluffyUnicornsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // for testing
    //ChatService.clearAllData();

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
