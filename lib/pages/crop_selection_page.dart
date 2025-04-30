import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:shm/constants.dart';
import 'package:shm/fertilizer_rules.dart';
import 'package:shm/soil_parameter.dart';
import 'home_page.dart';

class CropSelectionPage extends StatefulWidget {
  const CropSelectionPage({super.key});

  @override
  _CropSelectionPageState createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage> {
  String? selectedCrop;
  late List<List<dynamic>> cropData = [];
  String fertilizerRecommendation = '';
  String fertilizerAmount = '';
  bool isDataLoaded = false;
  int _selectedIndex = 1;

  Future<void> loadCropData() async {
    try {
      final cropDataString =
          await rootBundle.loadString('asset/fertilizers.csv');
      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(cropDataString);
      setState(() {
        cropData = csvData;
        isDataLoaded = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading crop data: $e");
      }
      // Optionally show an error message to the user
    }
  }

  void getFertilizerRecommendation() async {
    if (selectedCrop != null) {
      try {
        final cropParams = getCropData(selectedCrop!);
        final recommendation = FertilizerRule.getRecommendation(cropParams);
        final amount = FertilizerRule.calculateFertilizerAmount(
          cropParams['nitrogen'],
          cropParams['phosphorus'],
          cropParams['potassium'],
        );
        String fertilizerName = cropParams['fertilizerName'] ??
            'Fertilizer'; // Get fertilizer name or default
        setState(() {
          fertilizerRecommendation =
              'Recommendation:\nFertilizer - $fertilizerName'; // Include Fertilizer Name
          fertilizerAmount = 'Amount - ${amount.toStringAsFixed(2)} kg/ha ';
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
        setState(() {
          fertilizerRecommendation = '❌ Error fetching recommendation.';
          fertilizerAmount = '';
        });
      }
    } else {
      setState(() {
        fertilizerRecommendation = '⚠️ Please select a crop.';
        fertilizerAmount = '';
      });
    }
  }

  Map<String, dynamic> getCropData(String crop) {
    final cropIndex = cropData.indexWhere((row) =>
        row[4].toString().trim().toLowerCase() == crop.trim().toLowerCase());

    if (cropIndex == -1) {
      throw Exception("Crop not found in CSV data");
    }

    final cropParams = cropData[cropIndex];
    return {
      'temperature': cropParams[0].toDouble(),
      'humidity': cropParams[1].toDouble(),
      'moisture': cropParams[2].toDouble(),
      'soilType': cropParams[3].toString().trim(),
      'cropType': cropParams[4].toString().trim(),
      'nitrogen': cropParams[5].toDouble(),
      'potassium': cropParams[6].toDouble(),
      'phosphorus': cropParams[7].toDouble(),
      'fertilizerName': cropParams[8].toString(), // Get the fertilizer name.
    };
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadCropData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('🌱 Crop Selection 🌱'),
        centerTitle: true, // Center the title
        titleTextStyle: const TextStyle(fontSize: 24), // Make the title larger
        backgroundColor: Colors.green[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🌾 Select a Crop',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCrop,
                hint: const Text(
                  '🌱 Choose a crop',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                dropdownColor: Colors.lightGreen[100],
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                underline: Container(),
                items: selectCrop.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop.trim(),
                    child:
                        Text(crop.trim(), style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCrop = value;
                    fertilizerRecommendation = '';
                    fertilizerAmount = '';
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: getFertilizerRecommendation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3,
              ),
              child: const Text(
                '🌿 Fertilizer Recommendation 🌿',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            if (fertilizerRecommendation.isNotEmpty ||
                fertilizerAmount.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Recommendation Text
                      '${fertilizerRecommendation.split(':')[0]}:',
                      style: const TextStyle(
                        color: Colors.green, // Tan color
                        fontWeight: FontWeight.bold,
                        fontSize: 30, // Larger size
                      ),
                    ),
                    const SizedBox(height: 8), // Increased spacing
                    Text(
                      // Fertilizer Name
                      fertilizerRecommendation.split(':')[1],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8), // Increased spacing
                    Text(
                      // Amount
                      fertilizerAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.green[400],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Crop',
          ),
        ],
      ),
    );
  }
}
