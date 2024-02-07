import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'custom_dialer_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'mainpage.dart';
import 'package:at_contact/at_contact.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = "";
  List<String> alphabet = List.generate(26, (index) => String.fromCharCode(index + 65));


  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission needed"),
          content: Text("This app needs contact permission to proceed. Please enable it in app settings."),
          actions: <Widget>[
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                 // This will open app settings
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _fetchContacts() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      print("Fetched ${contacts.length} contacts."); // Debug print
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    } else {
      print("Contact permission was denied.");

      // _showPermissionDialog(context);// Debug print
    }
  }


  String _getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    if (names.length > 0) {
      initials += names.first[0]; // Add the first character of the first name
    }
    if (names.length > 1) {
      initials += names.last[0]; // Add the first character of the last name
    }
    return initials.toUpperCase();
  }


  void _searchContacts(String query) {
    final searchLower = query.toLowerCase();
    final filteredContacts = _contacts.where((contact) {
      final nameMatch = contact.displayName.toLowerCase().contains(searchLower);
      final numberMatch = contact.phones.any((phone) => phone.number.replaceAll(' ', '').contains(query));
      return nameMatch || numberMatch;
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredContacts = filteredContacts; // Update _filteredContacts based on the search query
    });
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _searchQuery.isEmpty
        ? _contacts
        : _contacts.where((contact) {
      final nameMatch = contact.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
      final numberMatch = contact.phones.any((phone) => phone.number.replaceAll(' ', '').contains(_searchQuery));
      return nameMatch || numberMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                suffixIcon: Icon(Icons.search),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: _searchContacts,
            ),
          ),


          Expanded(

            child: GroupedListView<Contact, String>(
              elements: filteredContacts,
              groupBy: (contact) => contact.displayName[0].toUpperCase(),
              groupComparator: (value1, value2) => value1.compareTo(value2),
              itemComparator: (item1, item2) => item1.displayName.compareTo(item2.displayName),
              order: GroupedListOrder.ASC,
              useStickyGroupSeparators: true, // Stick headers to top
              floatingHeader: false, // Disable floating header to avoid overlap
              groupSeparatorBuilder: (String value) => Container(
                color: Colors.black, // Match background color
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              itemBuilder: (c, contact) => ListTile(
                title: Text(contact.displayName, style: TextStyle(color: Colors.white)),
                subtitle: contact.phones.isNotEmpty ? Text(contact.phones.first.number, style: TextStyle(color: Colors.grey)) : null,
                leading: (contact.photo != null && contact.photo!.isNotEmpty)
                    ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                    : CircleAvatar(child: Text(contact.displayName[0].toUpperCase(), style: TextStyle(color: Colors.white))),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContactDetailsPage(contact: contact))),
              ),
            ),
          ),

        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}





// Existing ContactListPage implementation...
class ContactDetailsPage extends StatelessWidget {
  final Contact contact;
  ContactDetailsPage({required this.contact});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _sendMessages(String phoneNumber) async {
    // Define the country code to remove
    const String countryCode = '+91';

    // Remove the country code if present
    String cleanedPhoneNumber = phoneNumber.startsWith(countryCode)
        ? phoneNumber.substring(countryCode.length)
        : phoneNumber;

    // Clean up the phone number by removing any spaces or special characters
    cleanedPhoneNumber = cleanedPhoneNumber.replaceAll(RegExp(r'\s+'), '');

    // Create the SMS URI
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanedPhoneNumber,
    );

    // Attempt to launch the SMS app
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not launch $smsUri');
      // Optionally, show an error message to the user
    }
  }



  // void _deleteContact(BuildContext context) async {
  //   await contact.delete();
  //   bool confirmDelete = await showDialog(
  //     context: context,
  //
  //     builder: (BuildContext context) =>
  //         AlertDialog(
  //           backgroundColor: Colors.grey[850], // Dark background
  //           title: Text(
  //               "Confirm Delete", style: TextStyle(color: Colors.purpleAccent)),
  //           content: Text("Are you sure you want to delete this contact?",
  //               style: TextStyle(color: Colors.white70)),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text(
  //                   "Cancel", style: TextStyle(color: Colors.grey[500])),
  //               onPressed: () => Navigator.of(context).pop(false),
  //             ),
  //             TextButton(
  //               child: Text(
  //                   "Delete", style: TextStyle(color: Colors.redAccent)),
  //               onPressed: () => Navigator.of(context).pop(true),
  //             ),
  //           ],
  //         ),
  //   );
  //
  //   if (confirmDelete) {
  //     // Delete the contact
  //     await contact.delete();
  //     // Navigate back to ContactListPage and refresh it
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => ContactListPage()),
  //           (Route<
  //           dynamic> route) => false, // Remove all routes below the ContactListPage
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details'),
        backgroundColor: Colors.black87,

      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                      Text(
                        contact.displayName ?? 'N/A',
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Divider(color: Colors.grey[700], height: 30),
                      Text(
                        'Phone Numbers',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                      ...contact.phones.map((phone) => ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          phone.number,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // This keeps the row's size just as big as its children.
                          children: [
                            IconButton(
                              icon: Icon(Icons.call, color: Colors.green),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      CustomDialerPage(
                                          initialNumber: phone.number ??
                                              ''), // Example number
                                ));
                              }
                              ),
                            IconButton(
                              icon: Icon(Icons.message, color: Colors.cyanAccent),
                              onPressed: () => _sendMessages(phone.number),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

}


