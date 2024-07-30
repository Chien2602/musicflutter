import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'UI/Login.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Login UI',
    theme: ThemeData(
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: LoginPage(),
  ));
}