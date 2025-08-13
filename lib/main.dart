import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'homepage.dart';
import 'get_started_page.dart';
import 'history_page.dart';
import 'landing_page.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'auth_service.dart';

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
  bool _isAuthenticated = false;
  bool _showSignInPage = false;
  bool _showSignUpPage = false;
  bool _showHistoryPage = false;
  bool _showProfilePage = false;
  bool _showSettingsPage = false;
  bool _showSecurityPage = false;
  bool _showHelpPage = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((authState) {
      if (mounted) {
        if (authState.event == AuthChangeEvent.signedIn) {
          print('Auth state changed: signed in');
          setState(() {
            _isAuthenticated = true;
          });
        } else if (authState.event == AuthChangeEvent.signedOut) {
          print('Auth state changed: signed out');
          setState(() {
            _isAuthenticated = false;
          });
        }
      }
    });
  }

  void _initializeApp() async {
    setState(() => _loading = true);
    
    // Check authentication state
    _isAuthenticated = AuthService.isAuthenticated;
    
    // Small delay to show loading screen
    await Future.delayed(Duration(milliseconds: 500));
    
    setState(() => _loading = false);
  }

  void _onGetStarted() {
    setState(() {
      _showGetStarted = false;
    });
  }

  void _onSignInSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onSignUpSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onSignOut() async {
    try {
      await AuthService.signOut();
      setState(() {
        _isAuthenticated = false;
      });
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    print('Building current screen: loading=$_loading, getStarted=$_showGetStarted, authenticated=$_isAuthenticated, showSignIn=$_showSignInPage, showSignUp=$_showSignUpPage, showProfile=$_showProfilePage, showSettings=$_showSettingsPage, showSecurity=$_showSecurityPage, showHelp=$_showHelpPage');
    
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue[600]),
              SizedBox(height: 16),
              Text('Initializing BudgetBuddy...'),
            ],
          ),
        ),
      );
    }
    
    if (_showGetStarted) {
      return GetStartedPage(
        onGetStarted: _onGetStarted,
      );
    }

    // Show sign in page if requested
    if (_showSignInPage) {
      return SignInPage(
        onSignInSuccess: () {
          print('Sign in success callback');
          _onSignInSuccess();
          setState(() {
            _showSignInPage = false;
          });
        },
        onBack: () {
          setState(() {
            _showSignInPage = false;
          });
        },
      );
    }

    // Show sign up page if requested
    if (_showSignUpPage) {
      return SignUpPage(
        onSignUpSuccess: () {
          print('Sign up success callback');
          _onSignUpSuccess();
          setState(() {
            _showSignUpPage = false;
          });
        },
        onBack: () {
          setState(() {
            _showSignUpPage = false;
          });
        },
      );
    }

    // Show history page if requested
    if (_showHistoryPage) {
      print('Rendering HistoryPage');
      return HistoryPage(
        onBack: () {
          setState(() {
            _showHistoryPage = false;
          });
        },
      );
    }

    // Show profile page if requested
    if (_showProfilePage) {
      print('Rendering ProfilePage');
      return _buildProfilePage();
    }

    // Show settings page if requested
    if (_showSettingsPage) {
      print('Rendering SettingsPage');
      return _buildSettingsPage();
    }

    // Show security page if requested
    if (_showSecurityPage) {
      print('Rendering SecurityPage');
      return _buildSecurityPage();
    }

    // Show help page if requested
    if (_showHelpPage) {
      print('Rendering HelpPage');
      return _buildHelpPage();
    }

    if (!_isAuthenticated) {
      return LandingPage(
        onSignIn: () {
          print('Sign in button pressed');
          setState(() {
            _showSignInPage = true;
          });
        },
        onSignUp: () {
          print('Sign up button pressed');
          setState(() {
            _showSignUpPage = true;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('BudgetBuddy'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              if (_isAuthenticated) {
                setState(() {
                  _showHistoryPage = true;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please sign in to access transaction history')),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'profile') {
                // Show profile page only if authenticated
                if (_isAuthenticated) {
                  setState(() {
                    _showProfilePage = true;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please sign in to access your profile')),
                  );
                }
              } else if (value == 'signout') {
                print('Sign out selected');
                _onSignOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[600]),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: HomePage(),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showProfilePage = false;
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Colors.blue.shade600,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // User Info
                Text(
                  AuthService.userDisplayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  AuthService.userEmail ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Profile Options
                _buildProfileOption(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences and configuration',
                  onTap: () {
                    print('Settings button tapped. _isAuthenticated: $_isAuthenticated');
                    if (_isAuthenticated) {
                      print('Setting _showSettingsPage to true');
                      setState(() {
                        _showSettingsPage = true;
                      });
                      print('_showSettingsPage set to true');
                    } else {
                      print('User not authenticated, showing snackbar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please sign in to access settings')),
                      );
                    }
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildProfileOption(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Password and account security',
                  onTap: () {
                    print('Security button tapped. _isAuthenticated: $_isAuthenticated');
                    if (_isAuthenticated) {
                      print('Setting _showSecurityPage to true');
                      setState(() {
                        _showSecurityPage = true;
                      });
                      print('_showSecurityPage set to true');
                    } else {
                      print('User not authenticated, showing snackbar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please sign in to access security settings')),
                      );
                    }
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    print('Help button tapped. _isAuthenticated: $_isAuthenticated');
                    if (_isAuthenticated) {
                      print('Setting _showHelpPage to true');
                      setState(() {
                        _showHelpPage = true;
                      });
                      print('_showHelpPage set to true');
                    } else {
                      print('User not authenticated, showing snackbar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please sign in to access help & support')),
                      );
                    }
                  },
                ),
                
                Spacer(),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showProfilePage = false;
                      });
                      _onSignOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showSettingsPage = false;
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Settings Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings,
                    size: 40,
                    color: Colors.blue.shade600,
                  ),
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Settings Options
                _buildSettingsOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage push notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notifications settings opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSettingsOption(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Change app language',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language settings opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSettingsOption(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: 'Light or dark mode',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Theme settings opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSettingsOption(
                  icon: Icons.currency_exchange,
                  title: 'Currency',
                  subtitle: 'Set default currency',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Currency settings opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSettingsOption(
                  icon: Icons.backup,
                  title: 'Backup & Restore',
                  subtitle: 'Manage data backup',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup settings opened')),
                    );
                  },
                ),
                
                Spacer(),
                
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSettingsPage = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      'Back to Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showSecurityPage = false;
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Security Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.security,
                    size: 40,
                    color: Colors.blue.shade600,
                  ),
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'Account Security',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Security Options
                _buildSecurityOption(
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password change feature opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSecurityOption(
                  icon: Icons.phone_android,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add extra security layer',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('2FA settings opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSecurityOption(
                  icon: Icons.devices,
                  title: 'Active Sessions',
                  subtitle: 'Manage logged in devices',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Active sessions opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSecurityOption(
                  icon: Icons.login,
                  title: 'Login History',
                  subtitle: 'View account access logs',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login history opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildSecurityOption(
                  icon: Icons.block,
                  title: 'Blocked Accounts',
                  subtitle: 'Manage blocked users',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Blocked accounts opened')),
                    );
                  },
                ),
                
                Spacer(),
                
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSecurityPage = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      'Back to Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHelpPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showHelpPage = false;
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Help Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.help,
                    size: 40,
                    color: Colors.blue.shade600,
                  ),
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'Help & Support',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Help Options
                _buildHelpOption(
                  icon: Icons.question_answer,
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('FAQ section opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildHelpOption(
                  icon: Icons.book,
                  title: 'User Guide',
                  subtitle: 'Complete app tutorial',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User guide opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildHelpOption(
                  icon: Icons.video_library,
                  title: 'Video Tutorials',
                  subtitle: 'Step-by-step video guides',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Video tutorials opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildHelpOption(
                  icon: Icons.contact_support,
                  title: 'Contact Support',
                  subtitle: 'Get help from our team',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contact support opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildHelpOption(
                  icon: Icons.bug_report,
                  title: 'Report Bug',
                  subtitle: 'Report app issues',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bug report opened')),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                _buildHelpOption(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Share your suggestions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Feedback form opened')),
                    );
                  },
                ),
                
                Spacer(),
                
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showHelpPage = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      'Back to Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
