import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'config.dart';
import 'homepage.dart';
import 'get_started_page.dart';
import 'history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showGetStarted = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Initialize any necessary services here
    // For now, just ensure Supabase is ready
    setState(() => _loading = false);
  }

  void _onGetStarted() {
    setState(() {
      _showGetStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    if (_showGetStarted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GetStartedPage(
          onGetStarted: _onGetStarted,
        ),
      );
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('BudgetBuddy'),
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              tooltip: 'History',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => HistoryPage()),
                );
              },
            ),
          ],
        ),
        body: HomePage(),
      ),
    );
  }
}
