import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a Pet model to represent the pet's profile
class Pet {
  String name;
  String type;
  int age;
  double weight; // Weight in pounds
  List<String> illnesses; // List of illnesses (optional)

  Pet({
    required this.name,
    required this.type,
    required this.age,
    required this.weight,
    required this.illnesses,
  });

  // Convert a Pet object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'age': age,
      'weight': weight,
      'illnesses': illnesses,
    };
  }

  // Convert a Map to a Pet object
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'],
      type: map['type'],
      age: map['age'],
      weight: map['weight'],
      illnesses: List<String>.from(map['illnesses']),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List to store multiple pet profiles
  List<Pet> pets = [];

  // Define the baby blue color
  final Color babyBlue = Color(0xFF89CFF0); // Baby Blue Color

  @override
  void initState() {
    super.initState();
    _loadPets(); // Load pets when the page is first created
  }

  // Load the pet data from SharedPreferences
  _loadPets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? petsJson = prefs.getString('pets');
    if (petsJson != null) {
      List<dynamic> petsList = json.decode(petsJson);
      setState(() {
        pets = petsList.map((pet) => Pet.fromMap(pet)).toList();
      });
    }
  }

  // Save the pet data to SharedPreferences
  _savePets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String petsJson = json.encode(pets.map((pet) => pet.toMap()).toList());
    prefs.setString('pets', petsJson);
  }

  // Function to show a dialog to add or edit a pet
  void _showPetDialog({Pet? pet}) {
    String? petName = pet?.name;
    String? petType = pet?.type;
    int? petAge = pet?.age;
    double? petWeight = pet?.weight;
    List<String> petIllnesses = pet?.illnesses ?? [];

    // Show dialog for adding or editing a pet
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pet == null ? 'Add Pet' : 'Edit Pet',
          style: TextStyle(color: Colors.blueGrey),),
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input for pet's name
              TextField(
                onChanged: (value) {
                  petName = value;
                },
                controller: TextEditingController(text: petName),
                decoration: InputDecoration(hintText: 'Enter pet name'),
              ),
              SizedBox(height: 10),
              // Input for pet's type
              TextField(
                onChanged: (value) {
                  petType = value;
                },
                controller: TextEditingController(text: petType),
                decoration: InputDecoration(hintText: 'Enter pet type (e.g., Dog, Cat)'),
              ),
              SizedBox(height: 10),
              // Input for pet's age
              TextField(
                onChanged: (value) {
                  petAge = int.tryParse(value);
                },
                controller: TextEditingController(text: petAge?.toString() ?? ''),
                decoration: InputDecoration(hintText: 'Enter pet age (years)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Input for pet's weight (in pounds)
              TextField(
                onChanged: (value) {
                  petWeight = double.tryParse(value);
                },
                controller: TextEditingController(text: petWeight?.toString() ?? ''),
                decoration: InputDecoration(hintText: 'Enter pet weight (lbs)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 10),
              // Input for pet's illnesses (optional)
              TextField(
                onChanged: (value) {
                  petIllnesses = value.split(',').map((e) => e.trim()).toList();
                },
                controller: TextEditingController(text: petIllnesses.join(', ')),
                decoration: InputDecoration(hintText: 'Enter pet illnesses (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (petName != null &&
                    petType != null &&
                    petAge != null &&
                    petWeight != null) {
                  setState(() {
                    // If editing an existing pet, update the details
                    if (pet == null) {
                      // Add new pet
                      pets.add(Pet(
                        name: petName!,
                        type: petType!,
                        age: petAge!,
                        weight: petWeight!,
                        illnesses: petIllnesses,
                      ));
                    } else {
                      // Update existing pet
                      pet.name = petName!;
                      pet.type = petType!;
                      pet.age = petAge!;
                      pet.weight = petWeight!;
                      pet.illnesses = petIllnesses;
                    }
                  });
                  _savePets(); // Save the pets list to SharedPreferences
                  Navigator.pop(context); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in all fields.'),
                  ));
                }
              },
              child: Text(pet == null ? 'Add Pet' : 'Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Function to display the list of pets
  Widget _buildPetList() {
    if (pets.isEmpty) {
      return Center(
        child: Text('No pets added yet! Please add a pet.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: pets.length,
      itemBuilder: (context, index) {
        Pet pet = pets[index];
        return Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              '${pet.name} (${pet.type})',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age: ${pet.age} years', style: TextStyle(fontSize: 18)),
                Text('Weight: ${pet.weight} lbs', style: TextStyle(fontSize: 18)),
                Text(
                  'Illnesses: ${pet.illnesses.isEmpty ? 'None' : pet.illnesses.join(', ')}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            onTap: () {
              _showPetDialog(pet: pet); // Show the edit dialog when tapping on the pet
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: babyBlue, // Set baby blue color for the AppBar
        actions: [
          // Position the "Add Pet" button in the top middle with soft grey color
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(Icons.add),
                color: Colors.grey[600], // Set soft grey color for visibility
                onPressed: () {
                  _showPetDialog(); // Show the add pet dialog when pressed
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pets.isEmpty
            ? Center(
                child: Text(
                  'No pets added yet! Please add a pet.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Expanded(child: _buildPetList()), // Display pet profiles
      ),
    );
  }
}
