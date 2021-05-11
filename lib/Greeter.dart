import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pink_fluffy_unicorns/QueryService.dart';
import 'package:pink_fluffy_unicorns/User.dart';

import 'Chat/ChatList.dart';
import 'ChatService.dart';

/// Root class for Registration/Login UI. Wraps login/registered check
class Greeter extends StatelessWidget {
  static const String routeName = "/Greeter";
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ChatService.startupCheck(),
        builder: (context, AsyncSnapshot<StartupCheckData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.none) {
            if (snapshot.data!.appStatus == AppStatus.Operational)
              return ChatList();
            else if (snapshot.data!.appStatus ==
                AppStatus.RegistrationPending) {
              if (snapshot.data!.accountType == AccountType.Student)
                return StudentRegistration();
              else
                return DozentRegistration();
            } else {
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
          } else
            return ChatList();
        });
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
    return Column(children: [
      Table(columnWidths: <int, TableColumnWidth>{
        0: MaxColumnWidth(IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
        1: FlexColumnWidth(4.0)
      }, children: <TableRow>[
        TableRow(children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*Vorname:"),
            ),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*Nachname:"),
            ),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*E-Mail:"),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                Text("Es muss eine offizielle DHBW-E-Mail verwendet werden.",
                    textScaleFactor: 0.8)
              ])),
        ]),
        TableRow(children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*Passwort:"),
            ),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*Passwort \nwiederholen:"),
            ),
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
                  onPressed: () => _submit(context), child: Text("Weiter")))),
    ]);
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*E-Mail:"),
            ),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("*Passwort:"),
            ),
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
  DateTime? immatriculationDate;
  DateTime? exmatriculationDate;
  TextEditingController partnerController = TextEditingController();
  TextEditingController biographyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("StudConnect - Profil"),
        ),
        body: Column(children: [
          Table(columnWidths: <int, TableColumnWidth>{
            0: MaxColumnWidth(IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
            1: FlexColumnWidth(4.0)
          }, children: <TableRow>[
            TableRow(children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text("*Studienstart:"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: DateTimeField(
                  format: DateFormat("dd.MM.yyyy"),
                  initialValue:
                      null, //DateTime(DateTime.now().year - 1, 10, 1),
                  enabled: true,
                  decoration: InputDecoration(
                      labelText: 'Immatrikulationsdatum',
                      floatingLabelBehavior: FloatingLabelBehavior.never),
                  onChanged: (dt) {
                    immatriculationDate = dt;
                  },
                  onShowPicker: (BuildContext context, DateTime? currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 4),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now());
                  },
                ),
              ),
            ]),
            TableRow(children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text("*Vorr. Ende:"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: DateTimeField(
                  format: DateFormat("dd.MM.yyyy"),
                  initialValue:
                      null, //DateTime(DateTime.now().year - 1, 10, 1),
                  enabled: true,
                  decoration: InputDecoration(
                      labelText: 'Vorrausichtliches Exmatrikulationsdatum',
                      floatingLabelBehavior: FloatingLabelBehavior.never),
                  onChanged: (dt) {
                    exmatriculationDate = dt;
                  },
                  onShowPicker: (BuildContext context, DateTime? currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 4),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 4)));
                  },
                ),
              ),
            ]),
            TableRow(children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text("Dualer Partner:"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: TextField(
                  controller: partnerController,
                ),
              ),
            ]),
            TableRow(children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text("Biographie:"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: biographyController,
                ),
              ),
            ]),
          ]),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () => _submit(context),
                      child: Text("Übernehmen")))),
        ]));
  }

  _submit(BuildContext ctx) async {
    if (immatriculationDate != null && exmatriculationDate != null) {
      ChatService.writeProfile(
          biography: biographyController.text,
          partner: partnerController.text,
          immatriculation: immatriculationDate!,
          exmatriculation: exmatriculationDate!);
      ChatService.writeAppStatus(AppStatus.Operational);
      Navigator.popAndPushNamed(ctx, ChatList.routeName);
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text("Bitte füllen Sie alle mit * markierten Felder aus.")));
    }
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
