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
    await widget.plant.fetchLiveData(apikey);
    setState(() {
      data = widget.plant.data;
      isLoading = false;
    });
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

  void startPeriodicTask(){
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchLiveData();
      // fetchLiveData();
    });
  }

  @override
  initState(){
    super.initState();
    fetchLiveData();
    // fetchLiveData();
    //fetchInfo();
    startPeriodicTask();
  }

  Widget buildRetractableWidget(String title, {double height = 150, required Widget child, required ColorScheme scheme}){
    bool isExpanded = expansionStates[title] ?? false;
    double width = MediaQuery.of(context).size.width - 20;
    return Container(
      width: width ,
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
                color: scheme.primary.withOpacity(0.7),
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
                    style: TextStyle(
                      color: scheme.onPrimary,
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
                      color: scheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            decoration: BoxDecoration(
              color: scheme.inversePrimary.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.zero,
                bottom: Radius.circular(20),
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? height : 0,
            width: width,
            child: isExpanded 
              ? SingleChildScrollView(
                child: child,
              )
              :null,
          ),
        ], 
      ),
    );
  }

  Widget buildLiveDataWidget(String variable, int? data, {maxValue = 800, int minValue = 0, String unity = "%", required ColorScheme scheme}){
    int value = data ?? 0;
    double normalizedValue = (value / maxValue).clamp(0.0, 1.0);
    double hue = 240.0 - (normalizedValue * 240.0); // Blue (240°) → Green (120°) → Red (0°)
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
      color: Color.alphaBlend(HSVColor.fromAHSV(1.0, hue, 1, 0.7).toColor().withOpacity(0.6), scheme.primary),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top : 40, bottom: 40),
          child: Text(
            data != null ? "$variable : $data$unity" : "$variable : No Data",
            style: TextStyle(
              color: Colors.white,
              fontSize: data == null ? 20 : 40),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(String dataName, String data, ColorScheme scheme){
    return Container(
      width : double.infinity,
      margin: const EdgeInsets.all(10),
      child : Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: scheme.surface.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical : 4.0),
          child : RichText(
            text : TextSpan(
              text : "$dataName : ",
              style: TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              children : [
                TextSpan(
                  text : data,
                  style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
              ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget buildBody(){
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(10),  
      children: [
        buildRetractableWidget(
          "infos", 
          height: 350,
          child: Column(
            children: [
              buildInfoCard("Connected Device Id", widget.plant.deviceId, scheme),
              buildInfoCard("Plant Type", widget.plant.type, scheme),
              // buildInfoCard("Plant Type", widget.plant.type, scheme),
            ],
          ),
          scheme : scheme,
        ),
        SizedBox(
          height : 500,
          child : isLoading
          ? const Center(child :CircularProgressIndicator())
          : Column(
            children : [
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Temperature", data["field1"] == null ? null : int.tryParse(data["field1"]), maxValue: 50, minValue: 0, unity : "°C", scheme : scheme),
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Soil Moisture", data["field2"] == null ? null : (int.tryParse(data["field2"])), maxValue: 200, minValue: 0, scheme : scheme),
              const Divider(color: Colors.transparent),
              buildLiveDataWidget("Light", data["field3"] == null ? null : (int.tryParse(data["field3"])), maxValue : 200, minValue: 0, scheme : scheme),
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