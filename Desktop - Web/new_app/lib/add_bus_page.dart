import 'package:flutter/material.dart';

class AddBusPage extends StatefulWidget {
  @override
  _AddBusPageState createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final _formKey = GlobalKey<FormState>();

  final _busSeatsController = TextEditingController();
  final _registrationPlateController = TextEditingController();

  String _busNumber = 'Bus 1';
  String _busRoute = 'Route 1';
  String _status = 'Activate';
  String _shift = 'Shift 1';
  String _time = 'Morning';

  List<String> busNumbers = ['Bus 1', 'Bus 2', 'Bus 3'];
  List<String> busRoutes = ['Route 1', 'Route 2', 'Route 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bus'),
        backgroundColor: Color(0xFF03B0C1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(children: [
                      _buildDropdown(_busNumber, 'Bus Number', busNumbers, (newValue) {
                        setState(() {
                          _busNumber = newValue!;
                        });
                      }),
                      _buildTextField(_busSeatsController, 'Bus Seats', Icons.event_seat),
                    ]),
                    TableRow(children: [
                      _buildDropdown(_busRoute, 'Bus Route', busRoutes, (newValue) {
                        setState(() {
                          _busRoute = newValue!;
                        });
                      }),
                      _buildTextField(_registrationPlateController, 'Registration Plate', Icons.credit_card),
                    ]),
                    TableRow(children: [
                      _buildDropdown(_status, 'Status', ['Activate', 'Deactivate'], (newValue) {
                        setState(() {
                          _status = newValue!;
                        });
                      }),
                      _buildDropdown(_shift, 'Shift', ['Shift 1', 'Shift 2', 'Shift 3'], (newValue) {
                        setState(() {
                          _shift = newValue!;
                        });
                      }),
                    ]),
                    TableRow(children: [
                      _buildDropdown(_time, 'Time', ['Morning', 'Afternoon', 'Evening'], (newValue) {
                        setState(() {
                          _time = newValue!;
                        });
                      }),
                      Column(
                        children: [
                          SizedBox(), // Empty cell for alignment
                          SizedBox(height: 16.0), // Add space between dropdown and buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final newBus = {
                                      'busNumber': _busNumber,
                                      'busSeats': _busSeatsController.text,
                                      'busRoute': _busRoute,
                                      'registrationPlate': _registrationPlateController.text,
                                      'status': _status,
                                      'shift': _shift,
                                      'time': _time,
                                    };
                                    Navigator.pop(context, newBus);
                                  }
                                },
                                child: Text(
                                  'Add Bus',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03B0C1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03B0C1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Color(0xFF03B0C1)),
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF03B0C1)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${labelText.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String value, String labelText, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF03B0C1)),
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF03B0C1)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
