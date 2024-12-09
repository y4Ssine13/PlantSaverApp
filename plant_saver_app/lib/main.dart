import "package:flutter/material.dart";
import "home_page.dart";
void main () async
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 27, 180, 73)      
        ),
      ),
      home: HomePage(),
    );
  }
}
