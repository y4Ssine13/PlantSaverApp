import "package:flutter/material.dart";
import "plant.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "dart:async";

class PlantDetailsPage extends StatefulWidget {
  final Plant plant;
  const PlantDetailsPage({super.key, required this.plant});
  @override
  PlantDetailsPageState createState() => PlantDetailsPageState();
}

class PlantDetailsPageState extends State<PlantDetailsPage>{
  Map<String, bool> expansionStates = {"infos" : false, "Soil Moisture" : true, "Temperature" : true, "Light" : true };
  final String apiUrl = "/channels/";
  var headers = {
    'Api-Key': "0I7HI6BMDAQX4CTG",
  };
  String apikey = "0I7HI6BMDAQX4CTG";
  Map<String, dynamic> data = {};

  Timer? _timer;

  Future<void> fetchData() async {
    try{
      print(widget.plant.deviceId != "" ? widget.plant.deviceId : "nothing");
      print(widget.plant.potDepth != 0 ? widget.plant.potDepth : "zero");
      final response = await http.get(Uri.parse("https://api.thingspeak.com/channels/${widget.plant.deviceId}/feeds.json?api_key=$apikey&results=1"));

      if(response.statusCode == 200) {
        String responseBody = response.body;
        var jsonData = jsonDecode(responseBody);
        if(jsonData is Map && jsonData.containsKey("feeds")){
          print(jsonData["feeds"][0]);
          setState(() {
            data = jsonData["feeds"][0];
          });
        }
        else{
          print("No plant names found in the response !!!!!!!");
        }
      }else{
        print("Failed to load plants: ${response.statusCode} - ${response.reasonPhrase}");
      }
    }
    catch(error){
      print("Error fetching plant: $error");
    }
  }

  void startPeriodicTask() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchData();
    });
  }

  @override
  initState(){
    super.initState();
    fetchData();
    startPeriodicTask();
  }

  Widget buildRetractableWidget(String title, {double height = 150, String data = "test"}){
    bool isExpanded = expansionStates[title] ?? false;
    double width = MediaQuery.of(context).size.width - 20;
    return Container(
      width: width ,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 161, 231, 163),
        borderRadius: BorderRadius.circular(20),
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
          GestureDetector(
            onTap : () {
              setState(() {
                expansionStates[title] = !isExpanded;
                isExpanded = expansionStates[title] ?? false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children:[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 161, 231, 163),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? height : 0,
            width: width,
            child: isExpanded 
              ? Center(child: Text(data))
              :null,
          ),
        ], 
      ),
    );
  }

  Widget buildBody(){
    return ListView(
      padding: const EdgeInsets.all(10),  
      children: [
        buildRetractableWidget("infos", height: 350),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Temperature", data : data["field1"]?.toString() ?? "no data"),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Soil Moisture", data : data["field2"]?.toString() ?? "no data"),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Light", data : data["field3"]?.toString() ?? "no data"),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build (BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scheme.primary,
        title : Text(widget.plant.name, 
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: buildBody(),
    );
  }
}