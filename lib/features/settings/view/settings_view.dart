import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:live_fish_ai/models/fish_catch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedRegion = 'Lake Tanganyika';
  String _selectedLanguage = 'English';
  bool _offlineMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRegion = prefs.getString('region') ?? 'Lake Tanganyika';
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _offlineMode = prefs.getBool('offlineMode') ?? true;
    });
  }

  Future<void> _updateRegion(String? newRegion) async {
    if (newRegion == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('region', newRegion);
    setState(() {
      _selectedRegion = newRegion;
    });
  }

  Future<void> _updateLanguage(String? newLanguage) async {
    if (newLanguage == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  Future<void> _updateOfflineMode(bool newOfflineMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offlineMode', newOfflineMode);
    setState(() {
      _offlineMode = newOfflineMode;
    });
  }

  Future<void> _clearData() async {
    final box = Hive.box<FishCatch>('fish_catches');
    await box.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All catch data has been cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Region'),
            trailing: DropdownButton<String>(
              value: _selectedRegion,
              onChanged: _updateRegion,
              items: <String>['Lake Tanganyika', 'Ocean', 'River']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: _updateLanguage,
              items: <String>['English', 'Swahili', 'Kirundi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: const Text('Offline Mode'),
            value: _offlineMode,
            onChanged: _updateOfflineMode,
          ),
          const Divider(),
          ListTile(
            title: const Text('Download Model Pack'),
            subtitle: const Text('Download models for offline use'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // Placeholder for model download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Model download not implemented yet.')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear All Catch Data'),
            subtitle: const Text('This action cannot be undone.'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Clear Data'),
                    content: const Text('Are you sure you want to delete all catch data?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _clearData();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
