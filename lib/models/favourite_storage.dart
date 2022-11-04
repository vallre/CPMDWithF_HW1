import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favourites extends ChangeNotifier {
  // map is for work within the app
  // SharedPreferences is for persistence
  final Map<String, String> _favouriteItems = {};
  final _prefs = SharedPreferences.getInstance();

  Favourites() {
    // Read the data from the the storage
    loadData();
  }

  void loadData() async {
    SharedPreferences prefs = await _prefs;
    // all keys start with the prefix `favKey_`
    Iterable<String> keys =
        prefs.getKeys().where((key) => key.startsWith('favKey_'));

    for (String key in keys) {
      _favouriteItems[key] = prefs.getString(key) ?? '';
    }
  }

  int length() {
    // return number of elements in the map
    return _favouriteItems.length;
  }

  bool isNotEmpty() {
    return _favouriteItems.isNotEmpty;
  }

  // return Iterable<String> with `favKey_` removed from the beginning
  // `favKey_` should be hidden from user
  Iterable<String> get keys =>
      _favouriteItems.keys.map((key) => key.substring(7));

  // get the element from the map with a given key
  String? get(String itemID) {
    return _favouriteItems['favKey_$itemID'];
  }

  // add element to the map and async save it to the storage with SharedPreferences
  void add(String itemID, String item) async {
    _favouriteItems['favKey_$itemID'] = item;

    SharedPreferences prefs = await _prefs;
    prefs.setString('favKey_$itemID', item);

    notifyListeners();
  }

  // remove element from the map and async remove it from the storage with SharedPreferences
  void remove(String itemID) async {
    _favouriteItems.remove('favKey_$itemID');

    SharedPreferences prefs = await _prefs;
    prefs.remove('favKey_$itemID');

    notifyListeners();
  }

  // check whether the provided key is present
  // since map is in sync with the SharedPreferences through `add` and `remove` function, checking the map is sufficient
  bool containsKey(String itemID) {
    return _favouriteItems.containsKey('favKey_$itemID');
  }
}
