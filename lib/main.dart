import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class _HomePageState extends State<HomePage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    
    supabase.auth.onAuthStateChange.listen((data){
      setState(() {
        _userId = data.session?.user.id;
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_userId ?? 'Not signed in'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () async {
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
                }, child: Text('Sign In')),
                SizedBox(width: 16),
                if (_userId != null)
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Sign Out'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}