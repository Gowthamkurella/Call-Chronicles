import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_dialer_page.dart';
import 'package:at_contact/at_contact.dart';

class CallerDetailsPage extends StatelessWidget {
  final CallLogEntry selectedCallLogEntry;
  final List<CallLogEntry> callHistory;

  const CallerDetailsPage({
    Key? key,
    required this.selectedCallLogEntry,
    required this.callHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                selectedCallLogEntry.name ?? 'Unknown',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              subtitle: Text(
                selectedCallLogEntry.number ?? 'No Number',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              trailing: IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CustomDialerPage(initialNumber: selectedCallLogEntry.number ?? ''), // Example number
                  ));

                },
              ),
            ),
            Divider(color: Colors.blueGrey[700]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan[900]),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: callHistory.length,
                itemBuilder: (context, index) {
                  final entry = callHistory[index];
                  final formattedDate = DateFormat('dd/MM/yyyy hh:mm:ss a').format(DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0));
                  return ListTile(
                    leading: Icon(_getCallTypeIcon(entry.callType), color: Colors.white),
                    title: Text(formattedDate, style: TextStyle(color: Colors.white)),
                    subtitle: Text('Duration: ${entry.duration} sec', style: TextStyle(color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.missed: return Icons.call_missed;
      case CallType.outgoing: return Icons.call_made;
      case CallType.incoming: return Icons.call_received;
      default: return Icons.call_end_sharp;
    }
  }

  Future<void> _launchDialer(String number) async {
    final Uri _url = Uri.parse('tel:$number');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}
