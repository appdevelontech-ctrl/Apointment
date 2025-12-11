import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  String address = "Tap to fetch current location...";
  bool loading = false;

  Future<void> getCurrentLocation() async {
    setState(() => loading = true);

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => address = "Permission denied!");
      loading = false;
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(pos.latitude, pos.longitude);

    Placemark p = placemarks.first;

    String fullAddress =
        "${p.street}, ${p.subLocality}, ${p.locality} ";

    setState(() {
      address = fullAddress;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: const Color(0xFF137C76),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Show address box
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(address),
            ),

            const SizedBox(height: 20),

            // Button to fetch current location
            ElevatedButton(
              onPressed: loading ? null : getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137C76),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Use Current Location",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const Spacer(),

            // Save button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, address); // return address
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137C76),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Save Location",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
