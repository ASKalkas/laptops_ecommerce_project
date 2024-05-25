import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laptops_ecommerce_project/Providers/productsProvider.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;
import './Providers/productsProvider.dart';
import './Providers/connectivityProvider.dart';
import 'firebase_options.dart';
import './cartStock.dart';
import './authScreen.dart';
import './homeScreen.dart';
import './profile.dart';
import './productScreen.dart';
import './addItemScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (ctx) => AuthProvider.AuthenticationProvider()),
        ChangeNotifierProvider(
          create: (ctx) => ProductsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Chatting App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (ctx) => ConnectivityWrapper(),
          '/login': (ctx) => const LoginScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/profile': (ctx) => const ProfilePage(),
          '/cart': (ctx) => const CartStock(),
          '/addItem': (ctx) => const AddItem(),
          '/product': (ctx) => const ProductScreen(),
        },
        initialRoute: "/",
      ),
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConnectivityProvider(context),
      child: Initialize(),
    );
  }
}

class Initialize extends StatefulWidget {
  @override
  State<Initialize> createState() => _InitializeState();
}

class _InitializeState extends State<Initialize> {
  bool _initialized = false;
  bool _error = false;
  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      setState(() {
        _initialized = true;
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user == null) {
            // User is signed out
            Navigator.pushNamed(context, "/login");
          } else {
            IdTokenResult? idTokenResult = await user.getIdTokenResult();

            if (idTokenResult != null) {
              String? token = idTokenResult.token;
              DateTime? issueTime = idTokenResult.issuedAtTime;
              DateTime? customExpirationTime =
                  issueTime?.add(Duration(hours: 2));

              if (token != null && customExpirationTime != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('idToken', token);
                await prefs.setString(
                    'expirationTime', customExpirationTime.toIso8601String());
              }
            }

            print(user);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final authProvider =
                  Provider.of<AuthProvider.AuthenticationProvider>(context,
                      listen: false);
              authProvider.setUserID(user);
              Navigator.pushNamed(context, "/home");
            });
          }
        });
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
        print('hie');
        print(e);
      });
    }
  }

  void _checkConnection(BuildContext context) {
    final provider = Provider.of<ConnectivityProvider>(context, listen: false);
    if (!provider.isConnected) {
      provider.showNoInternetAlert(context);
    }
  }

  @override
  void initState() {
    bool flag = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ConnectivityProvider>(context, listen: false);
      if (!provider.isConnected) {
        provider.showNoInternetAlert(context);
      } else {
        initializeFlutterFire();
      }
    });
    if (flag) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Getting Everything in Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.00, 0.00),
              end: Alignment(-1, 0),
              colors: [Colors.white, Color.fromARGB(255, 48, 46, 46)],
            ),
          ),
        ),
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: const Placeholder());
  }
}
