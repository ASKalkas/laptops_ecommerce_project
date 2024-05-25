// import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './Providers/authProvider.dart' as AuthProvider;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  String gender = "";
  String userType = "";

  final authenticationInstance = FirebaseAuth.instance;
  var authenticationMode = 0;

  void toggleAuthMode() {
    if (authenticationMode == 0) {
      setState(() {
        authenticationMode = 1;
      });
    } else {
      setState(() {
        authenticationMode = 0;
      });
    }
  }

  void getGender(String g) {
    setState(() {
      gender = g;
    });
  }

  void getUserType(String role) {
    setState(() {
      userType = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider.AuthenticationProvider>(
        context,
        listen: false);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    void loginORsignup(File? image) async {
      print("start");
      var email = emailController.text.trim();
      var password = passwordController.text.trim();
      var confirmPassword = confirmController.text.trim();
      var firstName = firstNameController.text.trim();
      var lastName = lastNameController.text.trim();
      String succesFailure = "";
      try {
        if (authenticationMode == 1) // sign up
        {
          if (email == "" ||
              password == "" ||
              firstName == "" ||
              lastName == "" ||
              gender == "" ||
              userType == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Missing field/s'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            if (confirmPassword == password) {
              succesFailure = await authProvider.signup(
                  email: email,
                  password: password,
                  name: "$firstName $lastName",
                  gender: gender,
                  role: userType,
                  image: image);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password and confirm password do not match.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } else //log in
        {
          if (email == "" || password == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Missing field/s'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            succesFailure =
                await authProvider.login(email: email, password: password);
          }
        }

        if (succesFailure == "success") {
          Navigator.pushNamed(context, "/home");
        } else if (succesFailure == "email") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email Already in Use'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (succesFailure == "incorrect") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email/Password is incorrect'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (succesFailure == 'failed') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (err) {
        // ignore: avoid_print
        print(err.toString());
      }
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
            width: screenWidth,
            height: screenHeight,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/delivery.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: authenticationMode == 1
                ? Register(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    gender: gender,
                    userType: userType,
                    toggleAuthMode: toggleAuthMode,
                    loginORsignup: loginORsignup,
                    getGender: getGender,
                    getUserType: getUserType,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmController: confirmController,
                    lastNameController: lastNameController,
                    firstNameController: firstNameController,
                  )
                : Login(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    toggleAuthMode: toggleAuthMode,
                    loginORsignup: loginORsignup,
                    emailController: emailController,
                    passwordController: passwordController,
                  )));
  }
}

class Login extends StatelessWidget {
  const Login(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.toggleAuthMode,
      required this.loginORsignup,
      required this.emailController,
      required this.passwordController});

  final double screenWidth;
  final double screenHeight;
  final Function toggleAuthMode;
  final Function loginORsignup;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Vertically center the column
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: (160 / 360) * screenWidth,
            height: (20 / 640) * screenHeight,
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Colors.white.withOpacity(0),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter E-mail', // Placeholder text
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: (11 / 640) * screenHeight),
          Container(
            width: (160 / 360) * screenWidth,
            height: (20 / 640) * screenHeight,
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Colors.white.withOpacity(0),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Enter Password', // Placeholder text
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: (11 / 640) * screenHeight),
          Container(
            width: (87 / 360) * screenWidth,
            height: (27 / 640) * screenHeight,
            decoration: ShapeDecoration(
              color: const Color(0xFF181E1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(395),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: TextButton(
              onPressed: () => {loginORsignup(null)},
              child: const Text(
                "Log in",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
          ),
          SizedBox(height: (28 / 640) * screenHeight),
          SizedBox(
            width: (259 / 360) * screenWidth,
            height: (16 / 640) * screenHeight,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Sign up",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 2, 38, 68),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        toggleAuthMode();
                      },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 259,
            height: 16,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Continue as Guest?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, "/home");
                  },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Register extends StatefulWidget {
  Register(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.passwordController,
      required this.emailController,
      required this.toggleAuthMode,
      required this.loginORsignup,
      required this.confirmController,
      required this.lastNameController,
      required this.firstNameController,
      required this.getGender,
      required this.getUserType,
      required this.gender,
      required this.userType});

  final double screenWidth;
  final double screenHeight;
  final String gender;
  final String userType;
  final Function toggleAuthMode;
  final Function loginORsignup;
  final Function getGender;
  final Function getUserType;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController confirmController;
  final TextEditingController passwordController;
  final TextEditingController emailController;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Vertically center the column
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            final image =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image != null) {
              setState(() {
                _image = File(image.path);
              });
            }
          },
          child: Container(
            width: (100 / 360) * widget.screenWidth,
            height: (100 / 360) * widget.screenWidth,
            decoration: const ShapeDecoration(
              color: Colors.grey,
              shape: OvalBorder(
                side: BorderSide(width: 1, color: Color(0xFF644F3E)),
              ),
            ),
            child: Center(
              child: _image == null
                  ? const Text(
                      'Click to upload Image',
                      textAlign: TextAlign.center,
                    )
                  : ClipOval(
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: (100 / 360) * widget.screenWidth,
                        height: (100 / 360) * widget.screenWidth,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: (43 / 640) * widget.screenHeight,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: (111 / 360) * widget.screenWidth,
              height: (17 / 640) * widget.screenHeight,
              decoration: ShapeDecoration(
                color: const Color(0xFFD9D9D9),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Colors.white.withOpacity(0),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: TextField(
                controller: widget.firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter FirstName', // Placeholder text
                  contentPadding:
                      EdgeInsets.only(bottom: (12 / 640) * widget.screenHeight),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: (36 / 360) * widget.screenWidth),
            Container(
              width: (111 / 360) * widget.screenWidth,
              height: (17 / 640) * widget.screenHeight,
              decoration: ShapeDecoration(
                color: const Color(0xFFD9D9D9),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Colors.white.withOpacity(0),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: TextField(
                controller: widget.lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter LastName', // Placeholder text
                  contentPadding:
                      EdgeInsets.only(bottom: (12 / 640) * widget.screenHeight),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: (12 / 640) * widget.screenHeight),
        Container(
          width: (160 / 360) * widget.screenWidth,
          height: (17 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextField(
            controller: widget.emailController,
            decoration: InputDecoration(
              hintText: 'Enter E-mail', // Placeholder text
              contentPadding:
                  EdgeInsets.only(bottom: (10 / 640) * widget.screenHeight),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: (12 / 640) * widget.screenHeight),
        Container(
          width: (160 / 360) * widget.screenWidth,
          height: (17 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextField(
            controller: widget.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter Password', // Placeholder text
              contentPadding:
                  EdgeInsets.only(bottom: (10 / 640) * widget.screenHeight),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: (12 / 640) * widget.screenHeight),
        Container(
          width: (160 / 360) * widget.screenWidth,
          height: (17 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextField(
            controller: widget.confirmController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm Password', // Placeholder text
              contentPadding:
                  EdgeInsets.only(bottom: (10 / 640) * widget.screenHeight),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: (12 / 640) * widget.screenHeight),
        Container(
          width: (160 / 360) * widget.screenWidth,
          height: (17 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                value: widget.gender == "" ? null : widget.gender,
                hint: widget.gender == "" ? const Text("Gender") : null,
                items: <String>['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.getGender(newValue);
                },
              ),
            ),
          ),
        ),
        SizedBox(height: (12 / 640) * widget.screenHeight),
        Container(
          width: (160 / 360) * widget.screenWidth,
          height: (17 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                value: widget.userType == "" ? null : widget.userType,
                hint: widget.userType == "" ? const Text("Vendor/Buyer") : null,
                items: <String>['Vendor', 'Buyer'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.getUserType(newValue);
                },
              ),
            ),
          ),
        ),
        SizedBox(height: (15 / 640) * widget.screenHeight),
        Container(
          width: (87 / 360) * widget.screenWidth,
          height: (27 / 640) * widget.screenHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFF181E1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(395),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextButton(
            onPressed: () {
              widget.loginORsignup(_image);
            },
            child: const Text(
              "Sign up",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
        ),
        SizedBox(height: (15 / 640) * widget.screenHeight),
        SizedBox(
          width: (259 / 360) * widget.screenWidth,
          height: (16 / 640) * widget.screenHeight,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Already Have an Account? ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Log in",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 105, 185, 255),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      widget.toggleAuthMode();
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
