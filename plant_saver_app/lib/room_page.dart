import "dart:async";

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
  String apikey = "0I7HI6BMDAQX4CTG";

  Map<Plant, Map<String, dynamic>> dataList = {};
  Map<Plant, bool> isLoading = {};

  Timer? _timer;

  Future<void> fetchLiveData() async {
    Map<Plant, Map<String, dynamic>> tempDataList = {};
    Map<Plant, bool> tempIsLoading = {};
    for(var plant in widget.room.plants){
      await plant.fetchLiveData(apikey);
      tempDataList[plant] = plant.data;
      tempIsLoading[plant] = false;
    }
    setState(() {
      dataList = tempDataList;
      isLoading = tempIsLoading;
    });
  }

  void startPeriodicTask(){
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchLiveData();
      // fetchLiveData();
    });
  }

  @override
  void initState(){
    super.initState();
    isLoading = { for (var plant in widget.room.plants) plant : true };
    fetchLiveData(); 
    startPeriodicTask();   
  }

  Widget buildLiveDataWidget(String variable, int? data, {maxValue = 800, int minValue = 0, required ColorScheme scheme}){
    int value = data ?? 0;
    double normalizedValue = (value / maxValue).clamp(0.0, 1.0);
    double hue = 240.0 - (normalizedValue * 240.0); // Blue (240°) → Green (120°) → Red (0°)
    return Card(
      elevation: 10,
      color: Color.alphaBlend(HSVColor.fromAHSV(1.0, hue, 1, 0.7).toColor().withOpacity(0.6), scheme.primary),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top : 5, bottom: 5),
          child: Text(
            variable,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15),
          ),
        ),
      ),
    );
  }

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
                  isLoading[plant] = true;
                  fetchLiveData();
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

  Widget _buildPlantUI(Plant plant) {
    final scheme = Theme.of(context).colorScheme;
    bool loading = isLoading[plant] ?? true;
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
          color: scheme.inversePrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
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
                color: scheme.primary.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child : Text(
                      plant.name,
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
                    onPressed: () => _showRemovePlantDialog(plant), 
                    icon: Icon(Icons.remove, color: scheme.onPrimary,),
                  ),
                ],
              ),
            ),
            loading
            ? const Expanded(child: Center(child : CircularProgressIndicator()))
            : Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding : const EdgeInsets.only(top: 5, bottom : 10),
                    child : Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: scheme.surface.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical : 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              child : Text(
                                plant.type,
                                textAlign: TextAlign.center,
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
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildLiveDataWidget("Temperature", dataList[plant]?["field1"] == null ? null : int.tryParse(dataList[plant]?["field1"]), maxValue: 50, minValue: 0, scheme : scheme),
                      buildLiveDataWidget("Soil Moisture", dataList[plant]?["field2"] == null ? null : (int.tryParse(dataList[plant]?["field2"])), maxValue: 200, minValue: 0, scheme : scheme),
                      buildLiveDataWidget("Light", dataList[plant]?["field3"] == null ? null : (int.tryParse(dataList[plant]?["field3"])), maxValue : 200, minValue: 0, scheme : scheme),
                    ],
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
                children: widget.room.plants.map((item){
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
  void dispose(){
    super.dispose();
    _timer?.cancel();
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