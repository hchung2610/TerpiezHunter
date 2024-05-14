import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/TerpiezCounterProvider.dart';
import '../service/PreferencesService.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    _soundEnabled = await PreferencesService().getSoundEnabled();
    setState(() {});
  }

  void _toggleSound(bool value) {
    setState(() {
      _soundEnabled = value;
      PreferencesService().setSoundEnabled(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Preferences')),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text('Play Sounds'),
              value: _soundEnabled,
              onChanged: _toggleSound,
              secondary: const Icon(Icons.volume_up),
            ),
            ListTile(
              title: const Text(
                'Reset User',
                style: TextStyle(
                    color: Colors.red
                ),
              ),
              onTap: () => _showResetDialog(context),
            ),
          ],
        )
    );
  }
  void _showResetDialog(BuildContext context) {
    bool isDialogOpen = true;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Clear User Data?'),
          content: Text(
            'This is a destructive action, and will delete all of your progress. Do you really want to proceed?',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('No, cancel and keep my data'),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                isDialogOpen = false;
              },
            ),
            ElevatedButton(
              child: Text('Yes, really clear'),
              onPressed: () async {
                final preferencesService = PreferencesService();
                await preferencesService.clearSharedPreferences();
                await preferencesService.resetLocationData(dialogContext);

                if (isDialogOpen && Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                  isDialogOpen = false;
                }
                if (context.mounted) {
                  Provider.of<TerpiezCounterProvider>(context, listen: false).resetTerpiezCount();
                }
              },
            ),
          ],
        );
      },
    );
  }

}
