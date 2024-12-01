import "package:flutter/material.dart";
import "home_page.dart";
// import "package:hive_flutter/hive_flutter.dart";
// import "room.dart";
// import "plant.dart";

void main() async
{
  // WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();

  // await Hive.openBox<Room>("roomBox");

  // Hive.registerAdapter(RoomAdapter());
  // Hive.registerAdapter(PlantAdapter());
    
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
