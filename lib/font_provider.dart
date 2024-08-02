import 'package:flutter/cupertino.dart';

class FontProvider extends ChangeNotifier {
  String _selectedFont = 'RobotoRegular';

  String get selectedFont => _selectedFont;

  void updateFont(String newFont) {
    _selectedFont = newFont;
    notifyListeners();
  }
}
