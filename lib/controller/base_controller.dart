import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectedIndexNotifier with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int newIndex) {
    _selectedIndex = newIndex;
    notifyListeners();
  }
}
