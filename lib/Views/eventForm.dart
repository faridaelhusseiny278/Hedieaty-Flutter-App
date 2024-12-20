import 'package:flutter/material.dart';
import '../Models/Event.dart';
import 'package:intl/intl.dart';


class EventForm extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;

  EventForm({this.event, required this.onSave});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  String? nameError;
  String? locationError;
  String? _selectedCategory; // To store the selected category
  bool isFormValid = false;

  // Validate the form and update the state
  void _validateForm() {
    setState(() {
      nameError = _nameController.text.isEmpty
          ? 'Event name cannot be empty'
          : !RegExp(r"^[a-zA-Z\s]{3,50}$").hasMatch(_nameController.text)
          ? 'Enter a valid name (3-50 alphabetic characters)'
          : null;

      locationError = _locationController.text.isEmpty
          ? 'Event location cannot be empty'
          : !RegExp(r"^[a-zA-Z0-9\s]{3,50}$").hasMatch(_locationController.text)
          ? 'Enter a valid location (3-50 alphanumeric characters)'
          : null;

      isFormValid = nameError == null &&
          locationError == null &&
          _selectedDate != null &&
          _statusController.text.isNotEmpty &&
          _selectedCategory != null &&
          _nameController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    });
  }
  // Validate event name
  void _validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        nameError = 'Name cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z0-9\s'\-]{3,50}$").hasMatch(name)) {
        nameError = 'Enter a valid name (3-50 characters, can include numbers, spaces, apostrophes, or dashes)';
      } else {
        nameError = null;
      }
    });
  }


  // Validate event location
  void _validateLocation(String location) {
    setState(() {
      if (location.isEmpty) {
        locationError = 'Location cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z0-9\s]{3,50}$").hasMatch(location)) {
        locationError = 'Enter a valid location (3-50 alphanumeric characters)';
      } else {
        locationError = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _selectedCategory = widget.event!.category;
      _statusController.text = widget.event!.status;
      _locationController.text = widget.event!.location;
      _selectedDate = widget.event!.date;
    }
    else{
      _selectedCategory = 'Birthday';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: Key('eventNameField'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  errorText: nameError,
                ),
                onChanged: _validateName,
              ),
              DropdownButtonFormField<String>(
                key: Key('eventCategoryField'),
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: ['Birthday', 'Wedding', 'Anniversary', 'Other']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                key: Key('eventStatusField'),
                value: _statusController.text.isNotEmpty
                    ? _statusController.text
                    : null,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Upcoming', 'Current', 'past']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  _statusController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: Key('eventLocationField'),
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  errorText: locationError,
                ),
                onChanged: _validateLocation,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'
                        : 'No date selected',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(), // Disable selecting past dates (date before today)
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Select Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: Text(widget.event == null ? 'Add Event' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (nameError == null &&
                      locationError == null &&
                      _selectedDate != null &&
                      _statusController.text.isNotEmpty &&
                      _selectedCategory != null &&
                      _nameController.text.isNotEmpty &&
                      _locationController.text.isNotEmpty)
                      ? Colors.deepPurple
                      : Colors.grey, // Disabled button color
                  foregroundColor: (nameError == null &&
                      locationError == null &&
                      _selectedDate != null &&
                      _statusController.text.isNotEmpty &&
                      _selectedCategory != null &&
                      _nameController.text.isNotEmpty &&
                      _locationController.text.isNotEmpty)
                      ? Colors.white
                      : Colors.black38, // Dimmed text color when disabled
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: (nameError == null &&
                    locationError == null &&
                    _selectedDate != null &&
                    _statusController.text.isNotEmpty &&
                    _selectedCategory != null &&
                    _nameController.text.isNotEmpty &&
                    _locationController.text.isNotEmpty)
                    ? () {
                  if (_formKey.currentState!.validate()) {
                    final newEvent = Event(
                      id: widget.event?.id,
                      name: _nameController.text,
                      category: _selectedCategory!,
                      status: _statusController.text,
                      date: _selectedDate!,
                      location: _locationController.text,
                      description: '',
                    );
                    widget.onSave(newEvent);
                  }
                }
                    : () {
                  String errorMessage = '';
                  if (_selectedCategory == null || _selectedCategory!.isEmpty || _statusController.text.isEmpty
                      || _selectedDate == null || _locationController.text.isEmpty || _nameController.text.isEmpty) {
                    errorMessage += 'Please Fill all fields\n';
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invalid Input'),
                      content: Text(errorMessage.trim()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}
