import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pink_fluffy_unicorns/QueryService.dart';

import 'Chat/ChatList.dart';
import 'ChatService.dart';

/// Root class for Registration/Login UI
class Greeter extends StatelessWidget {
  static const String routeName = "/Greeter";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: Text("StudConnect"),
              bottom: TabBar(tabs: [
                Tab(
                  text: "Registrierung",
                ),
                Tab(
                  text: "Login",
                )
              ]),
            ),
            body: TabBarView(
              children: [Registration(), Login()],
            )));
  }
}

class Registration extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  Registration({Key? key}) : super(key: key);

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

            return Column(children: [
              Table(columnWidths: <int, TableColumnWidth>{
                0: MaxColumnWidth(IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
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
                      child: Column(children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Text(
                            "Es muss eine offizielle DHBW-E-Mail verwendet werden.",
                            textScaleFactor: 0.8)
                      ])),
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
                          onPressed: () => _submit(context),
                          child: Text("Weiter")))),
            ]);
          } else
            return ChatList();
        });
  }

  // thou shalt not touch this cursed function, for suffering will come upon thy soul if thou doeth not heed my warning
  _submit(BuildContext context) async {
    var studentEmailValidator = RegExp(r"s\d*@(student\.)?dhbw\-mannheim\.de");
    var dozentEmailValidator = RegExp(r"d\d*@(dozent\.)?dhbw\-mannheim\.de");
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordConfirmationController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      if (_passwordController.text == _passwordConfirmationController.text) {
        if (studentEmailValidator.hasMatch(_emailController.text)) {
          var loginResult = await QueryService.register(
              _emailController.text,
              _passwordController.text,
              _firstNameController.text,
              _lastNameController.text);
          if (loginResult != null) {
            ChatService.writeOwn(
                email: loginResult.email,
                password: _passwordController.text,
                accountType: loginResult.accountType);
            ChatService.writeAppStatus(AppStatus.RegistrationPending);
            Navigator.popAndPushNamed(context, StudentRegistration.routeName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Registrierung ist fehlgeschlagen.")));
          }
        } else if (dozentEmailValidator.hasMatch(_emailController.text)) {
          var loginResult = await QueryService.register(
              _emailController.text,
              _passwordController.text,
              _firstNameController.text,
              _lastNameController.text);
          if (loginResult != null) {
            ChatService.writeOwn(
                email: loginResult.email,
                password: _passwordController.text,
                accountType: loginResult.accountType);
            ChatService.writeAppStatus(AppStatus.RegistrationPending);
            Navigator.popAndPushNamed(context, DozentRegistration.routeName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Registrierung ist fehlgeschlagen.")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Sie müssen eine offizielle DHBW-E-Mail angeben.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Die Passwörter stimmen nicht überein.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Bitte füllen Sie alle mit * markierten Felder aus.")));
    }
  }
}

class Login extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Table(columnWidths: <int, TableColumnWidth>{
        0: MaxColumnWidth(IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
        1: FlexColumnWidth(4.0)
      }, children: <TableRow>[
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
      ]),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  onPressed: () => _submit(context), child: Text("Anmelden")))),
    ]);
  }

  _submit(BuildContext context) async {
    if (_passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      var loginResult = await QueryService.validateLogin(
          _emailController.text, _passwordController.text);
      if (loginResult != null) {
        ChatService.writeOwn(
            email: loginResult.email,
            password: _passwordController.text,
            accountType: loginResult.accountType);
        ChatService.writeAppStatus(AppStatus.Operational);
        Navigator.popAndPushNamed(context, ChatList.routeName);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Falsche Anmeldedaten.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Bitte füllen Sie alle mit * markierten Felder aus.")));
    }
  }
}

class StudentRegistration extends StatelessWidget {
  static const String routeName = "/StudentRegistration";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class DozentRegistration extends StatelessWidget {
  static const String routeName = "/DozentRegistration";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
