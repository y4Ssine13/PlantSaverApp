import "package:flutter/material.dart";
// import "package:http/http.dart";
import "room_page.dart";
import "room.dart";
// import "package:hive/hive.dart";

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  List<Room> roomList = [];

  // @override
  // void initState(){
  //   super.initState;
  //   setState(() {
  //     final box = Hive.box<Room>("roomBox");
  //     roomList = box.values.toList().cast<Room>();
  //   });
  // }

  // void addRoom(Room room) async{
  //   final box = Hive.box<Room>("roomBox");
  //   await box.put(room.name, room);  
  // }  

  // void deleteRoom(Room room) async{
  //   final box = Hive.box<Room>("roomBox");
  //   await box.delete(room.name);
  // }

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
                    // addRoom(room);
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
          content: Text("Are you sure you want to remove your ${room.name} ?"),
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
                  // deleteRoom(room);
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
    return GestureDetector(
      onTap:() {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => RoomPage(room: room),
          )
        ); 
      },
      child: Container(
        height: 250,
        width: 180,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 161, 231, 163),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child : Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showRemoveRoomDialog(room), 
                    icon: const Icon(Icons.remove, color: Colors.white,),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      "Click here to access your Plants",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
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
            :GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 5 / 4,
              ),
              itemBuilder: (context, index) => _buildRoomUI(roomList[index]),
              itemCount: roomList.length,
            ),
        ),
        Positioned(
          top: 720,
          left: 320,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scheme.primary,
        title : Text("Plant Saver", 
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          )
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: (){
        //       setState(() {
        //         plantList.add("debug plant $plantList.length + 1");
        //       });
        //     }),
        //   IconButton(
        //     icon: const Icon(Icons.remove),
        //     onPressed: (){
        //       if(plantList.isNotEmpty){
        //         setState(() {
        //           plantList.removeLast();
        //         });
        //       }
        //     })
        // ],
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