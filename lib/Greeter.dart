import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Chat/ChatList.dart';
import 'MessageSender.dart';

class Greeter extends StatelessWidget {
  static const String routeName = "/Greeter";
  late final TextEditingController _emailController = TextEditingController();

  Greeter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ChatService.ownEMailAsync(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasError ||
              (snapshot.hasData && (snapshot.data == null))) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Registrierung"),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        "Geben Sie Ihre E-Mail Addresse ein um sich anzumelden/zu registrieren:"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Legal Notice"),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                              onPressed: () => _submitEmail(context),
                              child: Text("Anmelden/Registrieren")))),
                ],
              ),
            );
          } else {
            // already registered account/this device
            return ChatList();
          }
        });
  }

  _submitEmail(BuildContext context) async {
    ChatService.writeOwn(email: _emailController.text);
    Navigator.popAndPushNamed(context, ChatList.routeName);
  }
}
