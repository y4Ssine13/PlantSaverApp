import "package:flutter/material.dart";
import "dart:convert";
import "package:http/http.dart" as http;
import "plant.dart";
// import "dart:typed_data";

class PlantTypePage extends StatefulWidget{
  const PlantTypePage({super.key});

  @override
  PlantTypePageState createState() => PlantTypePageState();
}

class PlantTypePageState extends State<PlantTypePage>{
  final String apiUrl = "/api/v3/kb/plants/name_search";
  var headers = {
    'Api-Key': "fH36TGywxfSPmSSpA6HGsWkB5VhW0oJghMRHaB7y5941k9QnBw",
    'Content-Type': 'application/json'
  };

  List<Plant> plants = [];

  bool isLoading = false;
  int currentPage = 1;
  String query = "";

  //final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    fetchPlantTypes("");
    //_scrollController.addListener(_scrollListener);
  }

  Future<void> fetchPlantTypes(String query) async {
    if(isLoading) return;
    setState(() {
      isLoading = true;
    });
  
    try{
      final http.StreamedResponse response;
      var queryParams = {
        'q': query,
        // 'page': currentPage.toString(),
        'limit': "20",
        'thumbnails': 'true',
      };

      var request = http.Request('GET', Uri.https("plant.id", apiUrl, queryParams));
      request.headers.addAll(headers);
      response = await request.send();

      if(response.statusCode == 200) {
        print("successful\n");
        String responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        if(jsonData is Map && jsonData.containsKey("entities")){
          List<dynamic> entities = jsonData['entities'];
          setState(() {
            plants = entities.map((entity) => Plant.withoutName(entity['thumbnail'], entity['entity_name'] as String, entity['access_token'])).toList();
            sortList(query);
          });

          if(entities.length < 10) {
            currentPage = 0;
          } else {
            currentPage++;
          }
        }
        else{
          print("No plant names found in the response !!!!!!!");
        }
        // if(page == 1){
        //   setState(() {
        //     commonNames = plant.map((plant) => plant['common_name'] as String?).whereType<String>().toList();
        //     scientificNames = plant.map((plant) => plant['scientific_name'] as String?).whereType<String>().toList();            
        //   });
        // }
        // else if(page > 1){
        //   setState(() {
        //     commonNames += plant.map((plant) => plant['common_name'] as String?).whereType<String>().toList();
        //     scientificNames += plant.map((plant) => plant['scientific_name'] as String?).whereType<String>().toList();            
        //   });

        // }

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

  // void _scrollListener() {
  //   if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
  //     if(currentPage > 0){
  //       fetchPlantTypes(query);
  //     }
  //   }
  // }

  @override
  void dispose(){
    //_scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void sortList(String query){
    List<Plant> priorityList = plants.where((item) => item.type.toLowerCase().startsWith(query.toLowerCase())).toList();
    List<Plant> secondaryList = plants.where((item) => item.type.toLowerCase().contains(query.toLowerCase())).toList();
    secondaryList.removeWhere((item) => priorityList.contains(item));
    priorityList.sort((plant1, plant2) => plant1.type.compareTo(plant2.type));
    secondaryList.sort((plant1, plant2) => plant1.type.compareTo(plant2.type));
    setState(() {
      plants = priorityList + secondaryList;    
    });

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Types"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  )
                ),
                onChanged: (value) {
                  setState(() {
                    currentPage = 1;
                    query = value;
                    plants.clear();
                  });
                  fetchPlantTypes(value);
                }
              ),
            ),
            Expanded(
              child: ListView.builder(
                //controller: _scrollController,
                itemCount: plants.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index){
                  if(index == plants.length && isLoading){
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children:[ 
                      ListTile(
                        title: Text(plants[index].type),
                        leading: Image.memory(
                          base64Decode(plants[index].thumbnail),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.pop(context, plants[index]);
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
