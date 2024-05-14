import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../service/SecureStorageService.dart';

class CredentialsCollectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CredentialsCollectorPage(),
    );
  }
}


class CredentialsCollectorPage extends StatefulWidget {
  @override
  _CredentialsCollectorPageState createState() => _CredentialsCollectorPageState();
}

class _CredentialsCollectorPageState extends State<CredentialsCollectorPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Redis Credentials"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCredentialsAndLaunchApp,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCredentialsAndLaunchApp() async {
    final secureStorage = SecureStorageService();
    await secureStorage.saveCredentials(_usernameController.text, _passwordController.text);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MultiProviderApp()));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}