import "package:flutter/material.dart";
import "room_page.dart";
import "room.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  List<Room> roomList = [];

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('room_list');
    setState((){
      jsonStringList != null ? roomList = jsonStringList.map((jsonString) => Room.fromJson(jsonDecode(jsonString))).toList() : [];
    });
  }

  Future<void> updateData() async {
    setState((){});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = roomList.map((room) => jsonEncode(room.toJson())).toList();
    await prefs.setStringList("room_list", jsonStringList);
  }

  @override
  void initState(){
    super.initState();
    loadData();
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        String roomName = "";
        Room room = Room(roomName);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Add New Room"),
          content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Enter room name"),
                    onChanged: (value) {
                      setState(() {    
                        roomName = value;   
                        room.name = roomName;                 
                      });
                    },
                  ),
                ],
              ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: (){
                if(room.name.isNotEmpty)
                {
                  setState(() {
                    roomList.add(room);
                    updateData();
                  });
                  Navigator.of(context).pop();
                }
              }, 
              child: const Text("Add"),
            ),
          ],
        );
      }
    );
  }

  void _showRemoveRoomDialog(Room room){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Are you sure?"),
          content: Text("Are you sure you want to remove your ${room.name} ? All the plants inside will also be deleted."),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  roomList.remove(room);
                  updateData();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Remove"),
            ),
          ],
        );
      }
      );
  }

  Widget _buildRoomUI(Room room){
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap:() {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => RoomPage(room: room, onUpdated: updateData),
          )
        ); 
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 133,
        ),
        width: 180,
        decoration: BoxDecoration(
          color: scheme.inversePrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.7) ,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child : Text(
                      room.name,
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showRemoveRoomDialog(room), 
                    icon: Icon(Icons.remove, color: scheme.onPrimary,),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: room.plants.isNotEmpty 
                ? Column(
                  children: [
                    ...room.plants
                      .take(5)
                        .map(
                          (plant) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: scheme.surface.withOpacity(0.9),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical : 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child : Text(
                                      plant.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Text(
                                    ":     ",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      plant.type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ),
                    if(room.plants.length > 5)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Open room to view more plants",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: scheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                : Center(
                  child: Text(
                    "This room has no plants.\nOpen to add plants",
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: scheme.onPrimary,
                      ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildBody(){
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child : 
            roomList.isEmpty ? const Center(
              child: Text("You currently have no rooms"),
            )
            : ListView(
              children : [
                ...roomList.map((room) => Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: _buildRoomUI(room))),
              ],
            ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child : Padding(
            padding: const EdgeInsets.all(2.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: scheme.onSecondary,
                backgroundColor: scheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), 
                ),
                padding: EdgeInsets.zero,
                fixedSize: const Size(60, 60)
              ),
              onPressed: _showAddRoomDialog,
              child: const Icon(
                Icons.add,
                size: 40,
              )
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child : Image.asset("images/app_logo.png"),
        ),
        centerTitle: true,
        backgroundColor: scheme.primary,
        title : Text("Plant Saver", 
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
      body: Container(
        color: scheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _buildBody(),
        )
      )
    );
  }
}