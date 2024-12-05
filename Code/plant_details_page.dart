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
  final String apiUrl = "/api/v3/kb/plants/name_search";
  var headers = {
    'Api-Key': "fH36TGywxfSPmSSpA6HGsWkB5VhW0oJghMRHaB7y5941k9QnBw",
    'Content-Type': 'application/json'
  };
  String apikey = "0I7HI6BMDAQX4CTG";
  Map<String, dynamic> data = {};
  Map<String, dynamic> infos = {};

  bool isLoading = true;

  Timer? _timer;

  Future<void> fetchLiveData() async {
    try{
      final response = await http.get(Uri.parse("https://api.thingspeak.com/channels/${widget.plant.deviceId}/feeds.json?api_key=$apikey&results=1"));

      if(response.statusCode == 200) {
        String responseBody = response.body;
        var jsonData = jsonDecode(responseBody);
        if(jsonData is Map && jsonData.containsKey("feeds")){
          setState(() {
            data = jsonData["feeds"][0];
            isLoading = false;
          });
        }
        else{
          //print("No plant names found in the response !!!!!!!");
        }
      }else{
        //print("Failed to load plants: ${response.statusCode} - ${response.reasonPhrase}");
      }
    }
    catch(error){
      //print("Error fetching plant: $error");
    }
  }

  Future<void> fetchInfo() async {
    try{
      var request = http.Request('GET', Uri.parse("https://plant.id/api/v3/kb/plants/${widget.plant.accessToken}?details=common_names,url,image,watering"));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200){
        String responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        print(responseBody);
        if(jsonData is Map && jsonData.containsKey("watering")){
          setState( (){
            infos = jsonData["watering"] ?? {"max": "no information", "min": "no infomation"};
          });
        }else{
          print("No infos found in the response !!!!!!!");
        }
      }else{
        print("Failed to load plants: ${response.statusCode} - ${response.reasonPhrase}");
      }
    }catch(error){
      print("Error fetching infos: $error");
    }
  }

  void startPeriodicTask() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchLiveData();
    });
  }

  @override
  initState(){
    super.initState();
    fetchLiveData();
    //fetchInfo();
    startPeriodicTask();
  }

  Widget buildRetractableWidget(String title, {double height = 150, required Widget child}){
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
              ? child
              :null,
          ),
        ], 
      ),
    );
  }

  Widget buildLiveDataWidget(String variable, int? data, {maxValue = 800, int minValue = 0}){
    int value = data ?? 0;
    double normalizedValue = (value / maxValue).clamp(0.0, 1.0);
    double hue = 240.0 - (normalizedValue * 240.0); // Blue (240°) → Green (120°) → Red (0°)
    return Card(
      elevation: 10,
      color: HSVColor.fromAHSV(1.0, hue, 1, 0.7).toColor(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top : 40, bottom: 40),
          child: Text(
            data != null ? "$variable : $data" : "$variable : No Data",
            style: TextStyle(
              color: Colors.white,
              fontSize: data == null ? 20 : 40),
          ),
        ),
      ),
    );
  }

  Widget buildBody(){
    return ListView(
      padding: const EdgeInsets.all(10),  
      children: [
        buildRetractableWidget(
          "infos", 
          height: 350,
          // child : Expanded(
          //   child: Column(
          //     children: [
          //       Text("watering max: ${infos["max"]}"),
          //       Text("watering min: ${infos["min"]}"),
          //     ],
          //   ),
          // ),
          child : Center(child: Text("watering  : max -> ${infos["max"]} | min -> ${infos["min"]}")),
        ),
        SizedBox(
          height : 500,
          child : isLoading
          ? const Center(child :CircularProgressIndicator())
          : Column(
            children : [
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Temperature", data["field1"] == null ? null : int.tryParse(data["field1"]), maxValue: 800, minValue: 50),
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Soil Moisture", data["field2"] == null ? null : (int.tryParse(data["field2"])), maxValue: 1000, minValue: 100),
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Light", data["field3"] == null ? null : (int.tryParse(data["field3"])), maxValue : 700, minValue: 300),
            ],
          ),
        ),
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