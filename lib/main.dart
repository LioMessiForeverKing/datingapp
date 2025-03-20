import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://fihkddbtptxtiucoafvc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpaGtkZGJ0cHR4dGl1Y29hZnZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0Nzg3NTMsImV4cCI6MjA1ODA1NDc1M30.9paoJuOTmA04fEIhyHI1LW2RoVVE2LIO54EWqtWH9Lc',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String? _userId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    // Start animation when screen loads
    _animationController.forward();
    
    // Store the subscription so we can cancel it in dispose
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data){
      final newUserId = data.session?.user.id;
      
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _userId = newUserId;
        });
        
        // Navigate to HomeScreen when user logs in
        if (newUserId != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen(userId: newUserId)),
          );
        }
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      // The state will be updated automatically through the auth state listener
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }

  @override
  void dispose() {
    // Cancel the auth state subscription
    _authStateSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo and App Name
                Hero(
                  tag: 'logo',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1BEE7),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 70,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MelodyMatch',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Find your perfect harmony with someone who shares your musical taste.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                ),
                const Spacer(),
                // Sign In Button
                if (_userId == null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        const webClientId = '153680830303-6odds05j2321o48k9ddrv62nidh00icv.apps.googleusercontent.com';
                        const iosClientId = '153680830303-rj6m12gos6qn1bms5f9t6ookdef8k2g9.apps.googleusercontent.com';
                        final GoogleSignIn googleSignIn = GoogleSignIn(
                          clientId: iosClientId,
                          serverClientId: webClientId,
                        );
                        final googleUser = await googleSignIn.signIn();
                        final googleAuth = await googleUser!.authentication;
                        final accessToken = googleAuth.accessToken;
                        final idToken = googleAuth.idToken;

                        if (accessToken == null) {
                          throw 'No Access Token found.';
                        }
                        if (idToken == null) {
                          throw 'No ID Token found.';
                        }

                        await supabase.auth.signInWithIdToken(
                          provider: OAuthProvider.google,
                          idToken: idToken,
                          accessToken: accessToken,
                        );
                      }, 
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_userId != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _signOut,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
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
}