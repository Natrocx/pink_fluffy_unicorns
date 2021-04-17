import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Greeter extends StatelessWidget {
  static const String routeName = "/Greeter";
  late final TextEditingController _emailController;

  Greeter({Key? key}) : super(key: key) {
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrierung"),
      ),
      body: Expanded(
        child: Column(
          children: [
            Text(
                "Geben Sie Ihre E-Mail Addresse ein um sich anzumelden/zu registrieren:"),
            Expanded(
                child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            )),
            Text("Legal Notice"),
            ElevatedButton(
                onPressed: _submitEmail, child: Text("Anmelden/Registrieren"))
          ],
        ),
      ),
    );
  }

  _submitEmail() {}
}
