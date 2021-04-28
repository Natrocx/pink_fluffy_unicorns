import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Chat/ChatList.dart';
import 'MessageSender.dart';

class Greeter extends StatelessWidget {
  static const String routeName = "/Greeter";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  Greeter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ChatService.ownEMailAsync(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.none) {
            if (snapshot.data != null) return ChatList();

            return Scaffold(
                extendBody: true,
                appBar: AppBar(
                  title: Text("StudConnect - Registrierung"),
                ),
                body: Column(children: [
                  Table(columnWidths: <int, TableColumnWidth>{
                    0: MaxColumnWidth(
                        IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
                    1: FlexColumnWidth(4.0)
                  }, children: <TableRow>[
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Vorname:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _firstNameController,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Nachname:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _lastNameController,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*E-Mail:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Passwort:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Passwort \nwiederholen:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _passwordConfirmationController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                      ),
                    ])
                  ]),
                  Expanded(child: Text("Rechtliche Hinweise")),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                              onPressed: () => _submitEmail(context),
                              child: Text("Anmelden/Registrieren")))),
                ]));
          } else
            return ChatList();
        });
  }

  _submitEmail(BuildContext context) async {
    ChatService.writeOwn(email: _emailController.text);
    Navigator.popAndPushNamed(context, ChatList.routeName);
  }
}
