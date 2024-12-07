import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Dog API URL and API Key
const String dogBreedListApiUrl = 'https://api.thedogapi.com/v1/breeds';
const String dogApiKey = 'live_SnXnkOuqtgeKNTBMAlK5Cge5n1cTfQlPOBbyy5LmPgLIpT9HtgAh8DDmuH8M7BSm'; // Replace with your Dog API Key

// Cat API URL and API Key
const String catBreedListApiUrl = 'https://api.thecatapi.com/v1/breeds';
const String catApiKey = 'live_DDAro5gcGday5hZceAExnFjuKuvuWTvQMb8zD5SAwzXHpI0MVjxZcMWPiQiyYLhB'; // Replace with your Cat API Key

// OpenAI API URL and API Key
const String openAiApiUrl = 'https://api.openai.com/v1/completions';
const String openAiApiKey = 'AIzaSyAAfNvmuAw5pckrpufZIRbWZG4rz1ojVr4'; // Replace with your OpenAI API Key

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<dynamic> dogBreedList = [];
  List<dynamic> filteredDogBreedList = [];
  List<dynamic> catBreedList = [];
  List<dynamic> filteredCatBreedList = [];
  TextEditingController _askController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String _aiResponse = 'Ask me anything about pets!';

  // Fetch Dog Breeds from the Dog API
  Future<void> fetchDogBreedList() async {
    final response = await http.get(
      Uri.parse(dogBreedListApiUrl),
      headers: {'x-api-key': dogApiKey},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        dogBreedList = data;
        filteredDogBreedList = dogBreedList; // Initialize filtered list
      });
    } else {
      throw Exception('Failed to load dog breed list');
    }
  }

  // Fetch Cat Breeds from the Cat API
  Future<void> fetchCatBreedList() async {
    final response = await http.get(
      Uri.parse(catBreedListApiUrl),
      headers: {'x-api-key': catApiKey},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        catBreedList = data;
        filteredCatBreedList = catBreedList; // Initialize filtered list
      });
    } else {
      throw Exception('Failed to load cat breed list');
    }
  }

  // Fetch AI Response from OpenAI API
  Future<void> fetchAiResponse(String query) async {
    final response = await http.post(
      Uri.parse(openAiApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      },
      body: json.encode({
        "model": "text-davinci-003",
        "prompt": query,
        "max_tokens": 100,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _aiResponse = data['choices'][0]['text'].trim();
      });
    } else {
      setState(() {
        _aiResponse = 'Failed to fetch AI response. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDogBreedList();
    fetchCatBreedList();
    _searchController.addListener(_filterBreeds); // Add listener for search bar
  }

  // Filter breed lists based on search input
  void _filterBreeds() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDogBreedList = dogBreedList
          .where((breed) => breed['name'].toLowerCase().contains(query))
          .toList();
      filteredCatBreedList = catBreedList
          .where((breed) => breed['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Care Help'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          // AI Ask Bar
          Container(
            color: Colors.blue.shade50,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _askController,
                    decoration: InputDecoration(
                      hintText: 'Ask AI a question...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final query = _askController.text.trim();
                    if (query.isNotEmpty) {
                      fetchAiResponse(query);
                      _askController.clear();
                    }
                  },
                  child: Text('Ask'),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.blue.shade100,
            padding: EdgeInsets.all(10),
            child: Text(
              _aiResponse,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          // Search Bar
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search breeds...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Breeds'),
                      Tab(text: 'Breed Information'),
                    ],
                    indicatorColor: Colors.white,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Breeds Tab
                        ListView(
                          padding: EdgeInsets.all(16.0),
                          children: [
                            Text(
                              'Dog Breeds:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ...filteredDogBreedList.map((breed) => ListTile(
                                  title: Text(breed['name']),
                                )),
                            Divider(),
                            Text(
                              'Cat Breeds:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ...filteredCatBreedList.map((breed) => ListTile(
                                  title: Text(breed['name']),
                                )),
                          ],
                        ),
                        // Care Tips Tab
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dog Care Tips
                                ...filteredDogBreedList.map((breed) => Card(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text('${breed['name']} - ${breed['temperament'] ?? 'N/A'}'),
                                      ),
                                    )),
                                Divider(),
                                // Cat Care Tips
                                ...filteredCatBreedList.map((breed) => Card(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text('${breed['name']} - ${breed['temperament'] ?? 'N/A'}'),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
