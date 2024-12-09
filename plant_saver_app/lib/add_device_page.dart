import "package:flutter/material.dart";
import "dart:convert";
import "package:http/http.dart" as http;

class AddDevicePage extends StatefulWidget{
  const AddDevicePage({super.key});

  @override
  AddDevicePageState createState() => AddDevicePageState();
}

class AddDevicePageState extends State<AddDevicePage>{
  List<String> deviceIDs = [];

  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    if(isLoading) return;
    setState(() {
      isLoading = true;
    });
  
    try{
      final response = await http.get(Uri.parse("https://api.thingspeak.com/users/mwa0000031727595/channels.json"));

      if(response.statusCode == 200) {
        String responseBody = response.body;
        var jsonData = jsonDecode(responseBody);
        if(jsonData is Map && jsonData.containsKey("channels")){
          List<dynamic> channles = jsonData['channels'];
          setState(() {
            deviceIDs = channles.map((channel) => channel["id"].toString()).toList();
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
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device IDs"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                //controller: _scrollController,
                itemCount: deviceIDs.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index){
                  if(index == deviceIDs.length && isLoading){
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children:[ 
                      ListTile(
                        title: Text(deviceIDs[index]),
                        onTap: () {
                          Navigator.pop(context, deviceIDs[index]);
                        },
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
