import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomDialerPage(),
      theme: ThemeData.dark(), // Apply dark theme to the entire app
    );
  }
}

class CustomDialerPage extends StatefulWidget {
  final String initialNumber;

  CustomDialerPage({Key? key, this.initialNumber = ''}) : super(key: key);

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<CustomDialerPage> {
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumber =
        widget.initialNumber; // Initialize with the passed initial number
  }

  void _dialNumber() async {
    final Uri _url = Uri.parse('tel:$_phoneNumber');
    if (!await launchUrl(_url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to launch dialer')),
      );
    }
  }

  Widget _buildDialButton(
      {required String digit, IconData? icon, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[850],
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 24)
              : Text(digit, style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Ensure the background matches the theme
      appBar: AppBar(
        title: Text('Dial Pad'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0, // Remove the shadow for a flatter appearance
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(_phoneNumber, style: TextStyle(
                fontSize: 32, color: Colors.white, letterSpacing: 2.0)),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var row in ['123', '456', '789'])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row.split('').map((digit) =>
                          _buildDialButton(
                            digit: digit,
                            onTap: () => setState(() => _phoneNumber += digit),
                          )).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDialButton( // * Button
                        digit: '*',
                        onTap: () => setState(() => _phoneNumber += '*'),
                      ),
                      _buildDialButton( // 0 Button
                        digit: '0',
                        onTap: () => setState(() => _phoneNumber += '0'),
                      ),
                      _buildDialButton( // # Button
                        digit: '#',
                        onTap: () => setState(() => _phoneNumber += '#'),
                      ),
                    ],
                  ),
                ),
                // Last row adjusted to mimic the approach of the other rows
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Opacity(
                        opacity: 0.0,
                        child: _buildDialButton(
                          digit: '',
                          onTap: () {}, // Empty onTap for alignment placeholder
                        ),
                      ),
                      ElevatedButton( // Dial Button
                        onPressed: _dialNumber,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          primary: Colors.green,
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.call, size: 30, color: Colors.white),
                      ),
                      IconButton( // Backspace/Delete Button
                        onPressed: () => setState(() {
                          _phoneNumber = _phoneNumber.isNotEmpty ? _phoneNumber.substring(0, _phoneNumber.length - 1) : '';
                        }),
                        icon: Icon(Icons.backspace, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}