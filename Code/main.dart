import "package:flutter/material.dart";
import "home_page.dart";
import 'package:updraft_sdk_flutter/updraft_sdk.dart';
// import 'package:updraft_sdk_flutter/updraft_sdk_flutter_method_channel.dart';
// import 'package:updraft_sdk_flutter/updraft_sdk_flutter_platform_interface.dart';
import 'package:updraft_sdk_flutter/updraft_settings.dart';

void main () async
{
  await UpdraftSdk.init(
    UpdraftSettings("78760392ee364cea809f40d4d0237b2c", "801db18e627144dfa4646402e115bdfe"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 27, 184, 58)
        )
      ),
      home: HomePage(),
    );
  }
}
