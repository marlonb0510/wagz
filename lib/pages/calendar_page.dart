import'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, String>>> _events = {}; // Events stored as a map with time

  // Dropdown list for predefined vet visit reasons
  List<String> vetVisitReasons = ['Check-up', 'Vaccination', 'Sick Visit', 'Other'];
  String selectedReason = 'Check-up'; // Default to Check-up

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Soft baby blue background for the page
      body: Column(
        children: [
          // Calendar View
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue, // Highlight today's date with a blue circle
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange, // Selected date highlighted with orange
                shape: BoxShape.circle,
              ),
              outsideTextStyle: TextStyle(color: Colors.blue.shade400), // Outside dates in lighter color
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Hide the format button
              titleTextStyle: TextStyle(color: Colors.blue.shade700, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Selected Date Display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _selectedDay != null
                  ? 'Selected Date: ${_selectedDay.toString().split(' ')[0]}'
                  : 'No date selected',
              style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
            ),
          ),

          // Events/Reminders for the Selected Date
          Expanded(
            child: ListView(
              children: _events[_selectedDay] != null
                  ? _events[_selectedDay]!.map((event) {
                      return ListTile(
                        title: Text('${event['title']}'),
                        subtitle: Text('Time: ${event['time']}'),
                        leading: Icon(Icons.event),
                      );
                    }).toList()
                  : [Text('No reminders for this date.')],
            ),
          ),
        ],
      ),

      // Add Event and Vet Visit Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _addEventDialog();
            },
            heroTag: 'addEvent',
            child: Icon(Icons.add),
            backgroundColor: Colors.blue.shade300, // Baby blue button color
            tooltip: 'Add Event',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _addVetVisit();
            },
            heroTag: 'addVetVisit',
            child: Icon(Icons.local_hospital),
            backgroundColor: Colors.blue.shade300, // Baby blue button color
            tooltip: 'Set Vet Visit',
          ),
        ],
      ),
    );
  }

  // Function to Add a Custom Event
  void _addEventDialog() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a date first.'),
      ));
      return;
    }

    String? eventTitle;
    TimeOfDay? eventTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event', style: TextStyle(color: Colors.blue.shade700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input for event title
              TextField(
                onChanged: (value) {
                  eventTitle = value;
                },
                decoration: InputDecoration(hintText: 'Enter event title'),
              ),
              SizedBox(height: 20),
              // Time Picker button
              ElevatedButton(
                onPressed: () async {
                  eventTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: Text(
                    eventTime == null
                        ? 'Pick Time'
                        : 'Selected Time: ${eventTime!.format(context)}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (eventTitle != null && eventTitle!.isNotEmpty && eventTime != null) {
                  setState(() {
                    _events[_selectedDay!] = _events[_selectedDay] ?? [];
                    _events[_selectedDay]!.add({
                      'title': eventTitle!,
                      'time': eventTime!.format(context),
                    });
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in both the title and time.'),
                  ));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to Add a Vet Visit Event (with adjustable time and reason)
  void _addVetVisit() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a date first.'),
      ));
      return;
    }

    String customReason = '';
    String vetVisitTime = '10:00 AM'; // Default vet visit time

    // Open Time Picker to allow time adjustment
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    ).then((selectedTime) {
      if (selectedTime != null) {
        vetVisitTime = selectedTime.format(context);

        // Show a dialog to select reason for the vet visit
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Select Reason for Vet Visit', style: TextStyle(color: Colors.blue.shade700)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dropdown for predefined vet visit reasons
                      DropdownButton<String>(
                        value: selectedReason,
                        items: vetVisitReasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (newReason) {
                          setState(() {
                            selectedReason = newReason!;
                          });
                        },
                      ),
                      // If "Other" is selected, allow user to input a custom reason
                      if (selectedReason == 'Other')
                        TextField(
                          onChanged: (value) {
                            customReason = value;
                          },
                          decoration: InputDecoration(hintText: 'Type here...'),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        String reasonToAdd = selectedReason == 'Other' && customReason.isNotEmpty
                            ? customReason
                            : selectedReason;

                        setState(() {
                          _events[_selectedDay!] = _events[_selectedDay] ?? [];
                          _events[_selectedDay]!.add({
                            'title': 'Vet Visit - $reasonToAdd',
                            'time': vetVisitTime,
                          });
                        });

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Vet visit scheduled for $reasonToAdd at $vetVisitTime!'),
                        ));
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    });
  }
}