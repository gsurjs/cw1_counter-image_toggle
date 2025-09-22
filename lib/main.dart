import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 App',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: CounterImageScreen(toggleTheme: _toggleTheme),
    );
  }
}

class CounterImageScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  CounterImageScreen({required this.toggleTheme});
  
  @override
  _CounterImageScreenState createState() => _CounterImageScreenState();
}

class _CounterImageScreenState extends State<CounterImageScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _showFirstImage = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Load saved state for graduate students
    _loadState();
  }
  
  // Graduate students only - Load state from SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _showFirstImage = prefs.getBool('showFirstImage') ?? true;
    });
  }
  
  // Graduate students only - Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    await prefs.setBool('showFirstImage', _showFirstImage);
  }
  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveState(); // Save state after incrementing
  }
  
  void _toggleImage() {
    _animationController.reverse().then((_) {
      setState(() {
        _showFirstImage = !_showFirstImage;
      });
      _animationController.forward();
      _saveState(); // Save state after toggling image
    });
  }
  
  // Graduate students only - Reset function with confirmation dialog
  Future<void> _resetApp() async {
    bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reset'),
          content: Text('Are you sure you want to reset all data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
    
    if (shouldReset == true) {
      setState(() {
        _counter = 0;
        _showFirstImage = true;
      });
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset animation
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CW1 - Counter & Image Toggle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Counter display
            Text(
              'Counter Value:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$_counter',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Increment button
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Text('Increment'),
            ),
            SizedBox(height: 40),
            
            // Image with fade transition animation
            FadeTransition(
              opacity: _animation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _showFirstImage ? Colors.blue : Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    _showFirstImage ? Icons.image : Icons.photo,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Toggle Image button
            ElevatedButton(
              onPressed: _toggleImage,
              child: Text('Toggle Image'),
            ),
            SizedBox(height: 20),
            
            // Theme toggle button
            ElevatedButton(
              onPressed: widget.toggleTheme,
              child: Text('Toggle Light/Dark Mode'),
            ),
            SizedBox(height: 20),
            
            // Reset button for graduate students - visually distinct
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}