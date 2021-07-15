import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const API_BASE_URL = 'https://issmittyworking.com/api';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat timeFormatter = DateFormat('jms');
  final DateFormat labelFormatter = DateFormat.yMd().add_jm();

  bool _loading = true;
  bool? _isWorking;
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch([DateTime? date]) async {
    setState(() {
      _loading = true;
    });

    final url = date != null
        ? "$API_BASE_URL/schedule/?timestamp=${date.millisecondsSinceEpoch / 1000}"
        : "$API_BASE_URL/schedule/";
    print(url);

    try {
      final response = await Dio().get(url);

      setState(() {
        _isWorking = response.data['is_working'] == true;
        _loading = false;
        _dateTime = date;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _isWorking = null;
        _dateTime = null;
      });
    }
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime(2038, 01, 18),
      firstDate: DateTime(2021, 01, 01),
      confirmText: "NEXT",
    );

    if (date == null) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) {
      return;
    }

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    _fetch(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Is Smitty Working?'),
        leading: IconButton(
          icon: Icon(Icons.replay_outlined),
          onPressed: () {
            _fetch();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          )
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isWorking != null
              ? Stack(
                  children: [
                    Container(
                      color: _isWorking!
                          ? Color.fromRGBO(0, 128, 0, 1)
                          : Color.fromRGBO(255, 0, 0, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                _isWorking! ? "YES" : "NO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_dateTime != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _fetch();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            icon: Icon(
                              Icons.clear,
                              color: Colors.black,
                            ),
                            label: Text(
                              labelFormatter.format(_dateTime!),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Center(
                  child: Text("An error occurred."),
                ),
    );
  }
}
