/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:self_code/Services/entry.dart';

class RatingTable extends StatefulWidget {
  @override
  _RatingTableState createState() => _RatingTableState();
}

class _RatingTableState extends State<RatingTable> {
  List<Entry> entries = [
    Entry('Entry 1', [Rating(0)]),
    Entry('Entry 2', [Rating(0)]),
    Entry('Entry 3', [Rating(0)]),
  ];

  late enc.Encrypter? encrypter;
  final iv = enc.IV.fromLength(16);
  final TextEditingController encryptionKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRatingsFromJson();
  }

  @override
  void dispose() {
    encryptionKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Rating Table')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(entries[index].name),
                  subtitle: Row(
                    children: List.generate(5, (i) {
                      int ratingValue = entries[index].ratings[0].value;
                      return IconButton(
                        icon: Icon(
                            ratingValue > i ? Icons.star : Icons.star_border),
                        onPressed: () {
                          setState(() {
                            entries[index].ratings[0].value = i + 1;
                            _saveRatingsToJson();
                          });
                        },
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showEncryptionKeyDialog();
            },
            tooltip: 'Set Encryption Key',
            child: Icon(Icons.vpn_key),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _exportRatingsToJson,
            tooltip: 'Export Data',
            child: Icon(Icons.file_download),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _importRatingsFromJson,
            tooltip: 'Import Data',
            child: Icon(Icons.file_upload),
          ),
        ],
      ),
    );
  }

  void _showEncryptionKeyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Encryption Key'),
          content: TextField(
            controller: encryptionKeyController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Enter Encryption Key'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveRatingsToJson();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveRatingsToJson() async {
    final key = enc.Key.fromUtf8(encryptionKeyController.text);
    encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    List<Map<String, dynamic>> jsonList =
    entries.map((entry) => entry.toJson()).toList();

    String jsonString = jsonEncode(jsonList);
    final encryptedJsonString = encrypter!.encrypt(jsonString, iv: iv);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/private/ratings.json');
    await file.create(recursive: true);
    await file.writeAsString(encryptedJsonString.base64);
  }

  void _loadRatingsFromJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/private/ratings.json');

    if (await file.exists()) {
      final encryptedJsonString = await file.readAsString();

      if (encryptionKeyController.text.isEmpty) {
        print("Encryption key is empty. Cannot load data.");
        return;
      }

      final key = enc.Key.fromUtf8(encryptionKeyController.text);
      encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final decryptedJsonString =
      encrypter!.decrypt64(encryptedJsonString, iv: iv);

      List<dynamic> jsonList = jsonDecode(decryptedJsonString);
      entries = jsonList
          .map((jsonEntry) => Entry.fromJson(jsonEntry))
          .toList()
          .cast<Entry>();

      setState(() {});
    }
  }

  void _exportRatingsToJson() async {
    if (encrypter == null) {
      print("Encryption key is not set. Cannot export data.");
      return;
    }

    List<Map<String, dynamic>> jsonList =
    entries.map((entry) => entry.toJson()).toList();

    String jsonString = jsonEncode(jsonList);
    final encryptedJsonString = encrypter!.encrypt(jsonString, iv: iv);

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/ratings_export.json');
    await file.writeAsString(encryptedJsonString.base64);

    print("Data exported successfully.");
  }

  void _importRatingsFromJson() async {
    if (encrypter == null) {
      print("Encryption key is not set. Cannot import data.");
      return;
    }

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/ratings_export.json');

    if (await file.exists()) {
      final encryptedJsonString = await file.readAsString();

      final decryptedJsonString =
      encrypter!.decrypt64(encryptedJsonString, iv: iv);

      List<dynamic> jsonList = jsonDecode(decryptedJsonString);
      entries = jsonList
          .map((jsonEntry) => Entry.fromJson(jsonEntry))
          .toList()
          .cast<Entry>();

      print("Data imported successfully.");
      setState(() {});
    } else {
      print("No data found for import.");
    }
  }
}
*/
