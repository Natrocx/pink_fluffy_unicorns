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
        future: ChatService.initialize()
            .then((value) => ChatService.startupCheck()),
        builder: (context, AsyncSnapshot<StartupCheckData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            //ChatService.clearAllData();
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

class Registration extends StatefulWidget {
  Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  final TextEditingController _emailVerificationController =
      TextEditingController();
  bool _emailVerificationActive = false;

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
        ]),
        TableRow(children: [
          Center(
              child: Padding(
                  child: Text("Verifizierungscode:"),
                  padding: EdgeInsets.all(4.0))),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _emailVerificationController,
                  enabled: _emailVerificationActive))
        ]),
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
          if (_emailVerificationActive == false) {
            setState(() => _emailVerificationActive = true);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Eine E-Mail mit einem Verifizierungscode wurde an Sie versendet.")));

            return;
          } else if (await QueryService.submitEmailVerificationCode(
              _emailVerificationController.text)) {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Der E-Mail-Verifizierungscode ist nicht korrekt.")));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Registrierung ist fehlgeschlagen.")));
          }
        } else if (dozentEmailValidator.hasMatch(_emailController.text)) {
          if (_emailVerificationActive == false) {
            setState(() => _emailVerificationActive = true);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Eine E-Mail mit einem Verifizierungscode wurde an Sie versendet.")));
            return;
          } else if (await QueryService.submitEmailVerificationCode(
              _emailVerificationController.text)) {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Der E-Mail-Verifizierungscode ist nicht korrekt.")));
            }
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

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, PasswordResetView.routeName);
          },
          child: Text("Passwort zurücksetzen"),
        ),
      ),
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

class PasswordResetView extends StatefulWidget {
  static const String routeName = "/passwordReset";

  @override
  State<StatefulWidget> createState() {
    return _PasswordResetViewState();
  }
}

class _PasswordResetViewState extends State<PasswordResetView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmationCodeController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  bool emailSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Password zurücksetzen"),
        ),
        body: Column(children: [
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
                ),
              )
            ]),
            emailSubmitted
                ? TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("*Verifizierungscode:"),
                    ),
                    Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _confirmationCodeController,
                        )),
                  ])
                : TableRow(children: [SizedBox.shrink(), SizedBox.shrink()]),
            emailSubmitted
                ? TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("*Neues Passwort:"),
                    ),
                    Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        )),
                  ])
                : TableRow(children: [SizedBox.shrink(), SizedBox.shrink()]),
            emailSubmitted
                ? TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("*Neues Passwort wiederholen:"),
                    ),
                    Padding(
                        padding: EdgeInsets.all(4.0),
                        child: TextField(
                          controller: _passwordConfirmationController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        )),
                  ])
                : TableRow(children: [SizedBox.shrink(), SizedBox.shrink()]),
          ]),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () => _continue(context),
                      child: Text("Weiter")))),
        ]));
  }

  _continue(BuildContext context) async {
    if (!emailSubmitted) {
      if (await QueryService.sendPasswordResetVerificationCode()) {
        setState(() => emailSubmitted = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Die E-Mail existiert nicht im System.")));
      }
    } else {
      if (_passwordController.text == _passwordConfirmationController.text &&
          _confirmationCodeController.text.isNotEmpty &&
          _passwordConfirmationController.text.isNotEmpty) {
        if (!await QueryService.submitPasswortReset(
            _confirmationCodeController.text, _passwordController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Bitte überprüfen Sie den eingegebenen Verifizierungscode.")));
        } else {
          // passwordreset successful
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Ihr Passwort wurde erfolgreich zurück gesetzt"),
          ));
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bitte überprüfen Sie Ihre Eingabe.")));
      }
    }
  }
}

class StudentRegistration extends StatefulWidget {
  static const String routeName = "/StudentRegistration";

  @override
  State<StatefulWidget> createState() {
    return _StudentRegistrationState();
  }
}

class _StudentRegistrationState extends State<StudentRegistration> {
  DateTime? immatriculationDate;
  DateTime? exmatriculationDate;
  TextEditingController partnerController = TextEditingController();
  TextEditingController biographyController = TextEditingController();

  String? majorCourse;
  String? minorCourse;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: QueryService.getCourseInfo(),
      builder: (context, AsyncSnapshot<Map<String, List<String>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        else
          return Scaffold(
              appBar: AppBar(
                title: Text("StudConnect - Profil"),
              ),
              body: Column(children: [
                Table(columnWidths: <int, TableColumnWidth>{
                  0: MaxColumnWidth(
                      IntrinsicColumnWidth(), FlexColumnWidth(1.0)),
                  1: FlexColumnWidth(4.0)
                }, children: <TableRow>[
                  TableRow(children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Studiengang:"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: DropdownButton(
                        items: snapshot.data!.keys
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (String? val) {
                          setState(() => majorCourse = val);
                        },
                        value: majorCourse,
                        isExpanded: true,
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("*Kurs:"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: DropdownButton(
                        items: majorCourse == null
                            ? null
                            : snapshot.data![majorCourse]!
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                        onChanged: (String? val) {
                          setState(() => minorCourse = val);
                        },
                        value: minorCourse,
                        isExpanded: true,
                      ),
                    ),
                  ]),
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
                        onShowPicker:
                            (BuildContext context, DateTime? currentValue) {
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
                            labelText:
                                'Vorrausichtliches Exmatrikulationsdatum',
                            floatingLabelBehavior: FloatingLabelBehavior.never),
                        onChanged: (dt) {
                          exmatriculationDate = dt;
                        },
                        onShowPicker:
                            (BuildContext context, DateTime? currentValue) {
                          return showDatePicker(
                              context: context,
                              firstDate: DateTime(DateTime.now().year - 4),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate:
                                  DateTime.now().add(Duration(days: 365 * 4)));
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
      },
    );
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
