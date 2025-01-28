import 'package:flutter/material.dart';

class EditBusPage extends StatefulWidget {
  final Map<String, String> busDetails;

  EditBusPage({required this.busDetails});

  @override
  _EditBusPageState createState() => _EditBusPageState();
}

class _EditBusPageState extends State<EditBusPage> {
  late TextEditingController busNumberController;
  late TextEditingController busSeatsController;
  late TextEditingController busRouteController;
  late TextEditingController driverNameController;
  late TextEditingController driverPhoneController;
  late TextEditingController registrationPlateController;
  String selectedStatus = 'Activate';
  String selectedShift = 'Shift 1';
  String selectedTime = 'Morning';

  @override
  void initState() {
    super.initState();
    busNumberController = TextEditingController(text: widget.busDetails['busNumber']);
    busSeatsController = TextEditingController(text: widget.busDetails['busSeats']);
    busRouteController = TextEditingController(text: widget.busDetails['busRoute']);
    driverNameController = TextEditingController(text: widget.busDetails['driverName']);
    driverPhoneController = TextEditingController(text: widget.busDetails['driverPhone']);
    registrationPlateController = TextEditingController(text: widget.busDetails['registrationPlate']);
    selectedStatus = widget.busDetails['status']!;
    selectedShift = widget.busDetails['shift']!;
    selectedTime = widget.busDetails['time']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bus Details'),
        backgroundColor: Color(0xFF03B0C1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: busNumberController,
              decoration: InputDecoration(labelText: 'Bus Number'),
            ),
            TextField(
              controller: busSeatsController,
              decoration: InputDecoration(labelText: 'Bus Seats'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: busRouteController,
              decoration: InputDecoration(labelText: 'Bus Route'),
            ),
            TextField(
              controller: driverNameController,
              decoration: InputDecoration(labelText: 'Driver Name'),
            ),
            TextField(
              controller: driverPhoneController,
              decoration: InputDecoration(labelText: 'Driver Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: registrationPlateController,
              decoration: InputDecoration(labelText: 'Registration Plate'),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>['Activate', 'Deactivate']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedShift,
              onChanged: (String? newValue) {
                setState(() {
                  selectedShift = newValue!;
                });
              },
              items: <String>['Shift 1', 'Shift 2', 'Shift 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedTime,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTime = newValue!;
                });
              },
              items: <String>['Morning', 'Afternoon', 'Evening']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedBus = {
                  'busNumber': busNumberController.text,
                  'busSeats': busSeatsController.text,
                  'busRoute': busRouteController.text,
                  'driverName': driverNameController.text,
                  'driverPhone': driverPhoneController.text,
                  'registrationPlate': registrationPlateController.text,
                  'status': selectedStatus,
                  'shift': selectedShift,
                  'time': selectedTime,
                };
                Navigator.pop(context, updatedBus);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03B0C1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
