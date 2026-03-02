import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/common/custom_colors.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerPage({
    super.key,
    required this.initialLocation,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng selectedLocation;
  GoogleMapController? mapController;

  final TextEditingController searchController = TextEditingController();

  List<dynamic> predictions = [];

  
  static const String apiKey = "AIzaSyADcKpq2a7NQTRrMxSsD2w6SEeHQcdxahs";

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
  }

 
  Future<void> getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() => predictions = []);
      return;
    }

 final url = Uri.parse(
  "https://maps.googleapis.com/maps/api/place/autocomplete/json"
  "?input=${Uri.encodeComponent(input)}"
  "&types=geocode"
  "&key=$apiKey",
);


    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        predictions = data['predictions'];
      });
    }
  }

  /// 📍 Get Place Details
  Future<void> selectPlace(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeId&key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];

      final double lat = location['lat'];
      final double lng = location['lng'];

      final newLatLng = LatLng(lat, lng);

      setState(() {
        selectedLocation = newLatLng;
        predictions = [];
        searchController.clear();
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLatLng, 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          /// 🗺 Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: (LatLng position) {
              setState(() {
                selectedLocation = position;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: selectedLocation,
              )
            },
          ),

          /// 🔎 Search Field
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search location...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.search),
                    ),
                    onChanged: getPlacePredictions,
                  ),
                ),

                /// 📋 Autocomplete Dropdown
                if (predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = predictions[index];

                        return ListTile(
                          title: Text(prediction['description']),
                          onTap: () =>
                              selectPlace(prediction['place_id']),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          /// ✅ Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3C88),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
