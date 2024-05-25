import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;
import './navBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    final authProvider =
        Provider.of<AuthProvider.AuthenticationProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'HOME',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
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
        actions: [
          IconButton(
              onPressed: () async {
                authProvider.signOut();
                authProvider.setUserID(null);
                Navigator.pushNamed(context, "/login");
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              )),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
          future: authProvider.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AlertDialog(
                  title: const Text('No User Data'),
                  content: const Text('Please Login/Signup to Access Profile'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      child: const Text('Go to Login/SignUp'),
                    ),
                  ]);
            } else {
              var userData = snapshot.data!;
              return SizedBox(
                width: (320 / 360) * screenWidth,
                height: (110 / 640) * screenHeight,
                child: Stack(
                  children: [
                    Positioned(
                      left: (20 / 360) * screenWidth,
                      top: (10 / 640) * screenHeight,
                      child: Container(
                        width: (90 / 640) * screenHeight,
                        height: (90 / 640) * screenHeight,
                        decoration: ShapeDecoration(
                          image: userData["Image"] == null
                              ? const DecorationImage(
                                  image: AssetImage('assets/emptyProfile.png'),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: NetworkImage(userData["Image"]),
                                  fit: BoxFit.cover,
                                ),
                          shape: const OvalBorder(side: BorderSide(width: 1)),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: (140 / 360) * screenWidth,
                      top: (30 / 640) * screenHeight,
                      child: Text(
                        userData["name"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: (140 / 360) * screenWidth,
                      top: (45 / 640) * screenHeight,
                      child: Text(
                        userData["email"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.underline,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: (140 / 360) * screenWidth,
                      top: (60 / 640) * screenHeight,
                      child: Text(
                        'Gender: ${userData["gender"]}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w100,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: (140 / 360) * screenWidth,
                      top: (75 / 640) * screenHeight,
                      child: Text(
                        'Role: ${userData["role"]}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w100,
                          height: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
      bottomNavigationBar: const NavBar(),
    );
  }
}
