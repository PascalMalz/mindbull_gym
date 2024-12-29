//todo show only fields that exist in the backend (deleted entries but rated so existing in hive will still appear)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:provider/provider.dart';
import 'package:self_code/Services/entry.dart';

import '../api/api_characteristics_service.dart';
import '../models/personal_growth_characteristic.dart';
import '../provider/characteristics_provider.dart';

class RatingTable extends StatefulWidget {
  @override
  _RatingTableState createState() => _RatingTableState();
}

class _RatingTableState extends State<RatingTable> {
  Map<String, List<PersonalGrowthCharacteristic>> categorizedEntries = {};
  bool isLoading = true; // To indicate loading state
  late List<bool> isExpandedList;
  CharacteristicsProvider? _provider;
  late enc.Encrypter? encrypter;
  final iv = enc.IV.fromLength(16);
  final TextEditingController encryptionKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateLocalStateFromProvider(); // Initialize local state from provider
    // Save a reference to the provider.
    print('RatingTable loading');
    _provider = Provider.of<CharacteristicsProvider>(context, listen: false);
    _provider!.addListener(updateLocalStateFromProvider);
  }

  void updateLocalStateFromProvider() {
    var provider = Provider.of<CharacteristicsProvider>(context, listen: false);
    setState(() {
      categorizedEntries = provider.categorizedEntries;
      print('categorizedEntries: $categorizedEntries');
      isLoading = false; // Ensure to set isLoading to false once the data is loaded
      isExpandedList = List<bool>.filled(categorizedEntries.length, true);
    });
  }

  @override
  void dispose() {
    // Use the saved reference to remove the listener
    _provider?.removeListener(updateLocalStateFromProvider);
    super.dispose();
  }


  void _setRating(String category, PersonalGrowthCharacteristic characteristic,
      int value) {
    Provider.of<CharacteristicsProvider>(context, listen: false)
        .updateRating(category, characteristic, value);
    print('try to called UpdateRating');
    setState(() {}); // Trigger a rebuild to update the UI
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categorizedEntries.length,
        itemBuilder: (context, index) {
          String category = categorizedEntries.keys.elementAt(index);
          return Column(
            children: [
              ExpansionTile(
                iconColor: Colors.deepPurple,
                collapsedIconColor: Colors.deepPurple,
                initiallyExpanded: isExpandedList[index],
                // Set initially expanded based on the state
                title: Text(category, style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20),),
                children: categorizedEntries[category]!
                    .map((characteristic) =>
                    Column(
                      children: [
                        Divider(color: Colors.deepPurple,thickness:0.1,indent: 15,endIndent: 15,),
                        ListTile(
                          title: Text(characteristic.name ?? 'Unnamed Characteristic',style: TextStyle(color: Colors.deepPurple, fontSize: 18),),
                          subtitle: Text(
                              characteristic.description ?? 'No description provided',style: TextStyle(color: Colors.black),),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (starIndex) {
                              return IconButton(
                                icon: Icon(
                                  starIndex < characteristic.rating.value
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  _setRating(category, characteristic, starIndex + 1);
                                },
                              );
                            }),
                          ),
                        ),
                      ],
                    ))
                    .toList(),
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    isExpandedList[index] = expanded;
                  });
                },
              ),
              Divider(color: Colors.white,thickness:2,indent: 0,endIndent: 0,),
            ],
          );
        },
      ),
    );
  }
}



