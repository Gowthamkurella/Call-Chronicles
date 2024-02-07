import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'caller_details_page.dart';
import 'custom_dialer_page.dart';
import 'contact_list_page.dart';
import 'mainpage.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';


void main() => runApp(MyApp());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/your-animation-3.json', // Make sure this path matches your Lottie file's location
          frameRate: FrameRate.max,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Call Log App',
      theme: ThemeData(
        brightness: Brightness.dark, // Use a dark theme as the base
        primaryColor: Colors.blueGrey[900], // Dark blue-grey as the primary color
        colorScheme: ColorScheme.dark().copyWith(
          secondary: Colors.cyanAccent, // Cyan as the accent color
        ),
        appBarTheme: AppBarTheme(
          color: Colors.blueGrey[900], // Matching the primary color
          foregroundColor: Colors.grey[300], // Light grey color for title and icons
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.cyan[900], // Vibrant orange for the FloatingActionButton
          foregroundColor: Colors.blueGrey[900], // Dark blue-grey for the icon, ensuring good contrast
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: FutureBuilder(
        future: _simulateStartupTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MainNavigationScreen(); // Transition to the main app screen.
          } else {
            return SplashScreen(); // Show the loading screen with the Lottie animation.
          }
        },
      ),
    );
  }
}

Future<void> _simulateStartupTasks() async {
  // Simulate some startup tasks like fetching data or initializing services
  await Future.delayed(Duration(seconds: 3)); // Adjust the delay as needed
}



class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();

}

class _CallLogScreenState extends State<CallLogScreen> {
  Iterable<CallLogEntry>? _callLogs;
  Iterable<CallLogEntry>? _filteredCallLogs;
  String _searchQuery = '';
  String _currentFilter = 'All';
  final List<String> _filters = ['All', 'Missed', 'Outgoing', 'Incoming', 'Unknown'];
  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }



  Future<void> _fetchCallLogs() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      var status1 = await Permission.contacts.request();
      Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries;
        // Initialize _filteredCallLogs with all call logs when fetched
        _filteredCallLogs = entries;
      });
    } else {
      print('Call Log permission not granted');
    }
  }

  void _filterCallLogs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCallLogs = _callLogs?.where((log) {
        final nameLower = log.name?.toLowerCase() ?? '';
        final number = log.number ?? '';
        return nameLower.contains(query.toLowerCase()) || number.contains(query);
      }).toList();
    });
  }

  IconData _getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.missed:
        return Icons.phone_missed; // Stays relevant but slightly different visually
      case CallType.outgoing:
        return Icons.phone_forwarded; // Represents calls being made, but with a callback twist
      case CallType.incoming:
        return Icons.phone_callback; // Indicates calls coming in, with a forwarding motion
      default:
        return Icons.phone_disabled_sharp; // Suggests a pause in communication, for general or other types
    }
  }

  Iterable<CallLogEntry> get filteredCallLogs {
    final query = _searchQuery.toLowerCase();
    final filter = _currentFilter;
    return _callLogs?.where((log) {
      final nameMatch = log.name?.toLowerCase().contains(query) ?? false;
      final numberMatch = log.number?.contains(query) ?? false;
      final matchesQuery = nameMatch || numberMatch;
      if (filter == 'All') return matchesQuery;
      if (filter == 'Missed' && log.callType == CallType.missed) return matchesQuery;
      if (filter == 'Outgoing' && log.callType == CallType.outgoing) return matchesQuery;
      if (filter == 'Incoming' && log.callType == CallType.incoming) return matchesQuery;
      if (filter == 'Unknown' && (log.name == null || log.name!.isEmpty)) return matchesQuery;
      return false;
    }) ?? Iterable<CallLogEntry>.empty();
  }


  static const platform = MethodChannel('com.yourcompany.calllog/delete');

  Future<void> deleteCallLogEntry(String callLogId) async {
    try {
      await platform.invokeMethod('deleteCallLogEntry', {'callLogId': callLogId});
      // Update your UI or state as necessary
    } on PlatformException catch (e) {
      print("Failed to delete call log entry: '${e.message}'.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Log App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Calls',
                suffixIcon: Icon(Icons.search),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: _filterCallLogs,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    value: _currentFilter,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    elevation: 16,
                    dropdownColor: Colors.blueGrey[700],
                    style: TextStyle(color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        _currentFilter = newValue!;
                      });
                    },
                    items: _filters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCallLogs.length,
              itemBuilder: (context, index) {
                final entry = filteredCallLogs.elementAt(index);
                final timestamp = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
                final formattedDate = DateFormat('dd/MM/yyyy hh:mm:ss a').format(timestamp); // For displaying date and time

                // Convert duration from seconds to a more readable format (e.g., "2 mins 15 secs")
                final durationMinutes = (entry.duration ?? 0) ~/ 60;
                final durationSeconds = (entry.duration ?? 0) % 60;
                final formattedDuration = '${durationMinutes}m ${durationSeconds}s';

                return ListTile(
                  leading: Icon(
                    _getCallTypeIcon(entry.callType),
                    color: entry.callType == CallType.missed ? Colors.red : Colors.white, // Red for missed calls, white for others
                  ),

                  title: Text(entry.name ?? 'Unknown', style: TextStyle(color: Colors.white)),
                  subtitle: Text('${entry.number ?? 'No Number'}', style: TextStyle(color: Colors.grey[400])),
                  onTap: () {
                    // Filter call history for the selected number
                    final List<CallLogEntry> filteredHistory = _callLogs?.where((log) => log.number == entry.number).toList() ?? [];


                    // Navigate to CallerDetailsPage with the selected log entry and filtered history
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CallerDetailsPage(
                          selectedCallLogEntry: entry,
                          callHistory: filteredHistory,
                        ),
                      ),
                    );
                  },
                  trailing: Container(
                    width: 120, // Adjust width based on your layout needs
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 20, // Height for the Marquee widget to control scrolling area height
                          width: 80,// Height for the Marquee widget
                          child: Marquee(
                            text: formattedDate, // Your formatted date text
                            style: TextStyle(color: Colors.white),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 20.0, // Space between the end of the text and the beginning on repeat
                            velocity: 50.0, // Speed of the scroll
                            pauseAfterRound: Duration(seconds: 1), // Pause between loops
                            startPadding: 10.0, // Padding before the text starts scrolling
                            accelerationDuration: Duration(seconds: 1), // Time it takes to reach full scroll velocity
                            accelerationCurve: Curves.linear, // Scroll acceleration curve
                            decelerationDuration: Duration(milliseconds: 500), // Time to slow down to a stop
                            decelerationCurve: Curves.easeOut, // Scroll deceleration curve
                          ),
                        ),
                        Text('Duration: $formattedDuration', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),

    );
  }
}


