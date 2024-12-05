import "dart:convert";

import "package:flutter/material.dart";
import "plant_details_page.dart";
import "plant_type_page.dart";
import "plant.dart";
import "room.dart";
import "package:reorderables/reorderables.dart";
import "add_device_page.dart";

class RoomPage extends StatefulWidget{
  final Room room;
  final Function() onUpdated;
  const RoomPage({super.key, required this.room, required this.onUpdated});

  @override
  RoomPageState createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage>{

  void _showAddPlantDialog() {
    final TextEditingController controller1 = TextEditingController();
    final TextEditingController controller2 = TextEditingController();
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        String plantName = "";
        String deviceId = "";
        Plant plant = Plant(plantName);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Add New Plant"),
          content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Enter plant name"),
                    onChanged: (value) {
                      setState(() {    
                        plantName = value;   
                        plant.name = plantName;                 
                      });
                    },
                  ),
                  TextField(
                    controller: controller1,
                    readOnly: true,
                    decoration: const InputDecoration(hintText: "Select type of plant"),
                    onTap: () async {
                      Plant? selectedPlant = await Navigator.push<Plant>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlantTypePage(),
                        ),
                      );
                      
                      if(selectedPlant != null){
                        setState(() {
                          plant = selectedPlant;
                          plant.name = plantName;
                          plant.deviceId = deviceId;
                          controller1.text = plant.type;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: controller2,
                    readOnly: true,
                    decoration: const InputDecoration(hintText: "Connect the plant to a device"),
                    onTap: () async {
                      String? selectedDevice = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDevicePage(),
                        ),
                      );
                      
                      if(selectedDevice != null){
                        print(selectedDevice);
                        setState(() {
                          deviceId = selectedDevice;
                          plant.deviceId = deviceId;
                          controller2.text = deviceId;
                        });
                        print(plant.deviceId);
                      }
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: "Enter Pot Diameter in cm"),
                    onChanged: (value) {
                      setState(() {
                        plant.potDiam = double.tryParse(value) ?? 0;                      
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: "Enter Pot Depth in cm"),
                    onChanged: (value) {
                      setState(() {
                        plant.potDepth = double.tryParse(value) ?? 0;                      
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
                if(plant.name.isNotEmpty && plant.type.isNotEmpty && plant.potDiam != 0 && plant.potDepth != 0)
                {
                  setState(() {
                    widget.room.plants.add(plant);
                    widget.onUpdated();
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

  void _showRemovePlantDialog(Plant plant){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Are you sure?"),
          content: Text("Are you sure you want to remove your plant ${plant.name} ?"),
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
                  widget.room.plants.remove(plant);
                  widget.onUpdated();
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

  Widget _buildPlantUI(Plant plant){
    return GestureDetector(
      onTap:() {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(plant: plant),
          )
        ); 
      },
      child: Container(
        height: 250,
        width: (MediaQuery.of(context).size.width - 50) / 2,
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
                      plant.name,
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
                    onPressed: () => _showRemovePlantDialog(plant), 
                    icon: const Icon(Icons.remove, color: Colors.white,),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      "${plant.name} is a ${plant.type}",
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  Image.memory(
                    base64Decode(plant.thumbnail),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
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
            widget.room.plants.isEmpty ? const Center(
              child: Text("You currently have no plants"),
            )
            : ReorderableWrap(
                spacing: 15.0, // Space between items in the same row
                runSpacing: 15.0, // Space between rows
                padding: const EdgeInsets.all(7.0),
                alignment: WrapAlignment.start,
                children: widget.room.plants.map((item) {
                  return _buildPlantUI(item);
                }).toList(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final item = widget.room.plants.removeAt(oldIndex);
                    widget.room.plants.insert(newIndex, item);
                  });
                },buildDraggableFeedback: (context, index, child){
                  return Material(
                    type: MaterialType.transparency,
                    child: child,
                  );
                },
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
              onPressed: _showAddPlantDialog,
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
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scheme.primary,
        title : Text(widget.room.name, 
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