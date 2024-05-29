import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  final authenticationInstance = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? _userId;
  String? _role;
  bool _authenticated = false;

  bool get isAuthenticated {
    return _authenticated;
  }

  String? get userId {
    return _userId;
  }

  String? get role {
    return _role;
  }

  void setUserID(User? user) async {
    if (user == null) {
      return;
    }
    _userId = user.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(_userId).get();
    if (userDoc.exists) {
      _role = userDoc.get("role");
      // await requestNotificationPermissions();
      String? token = await messaging.getToken();
      await FirebaseFirestore.instance.collection('Users').doc(_userId).update({
        'fcmToken': token,
      });
      _authenticated = true;
      notifyListeners();
    } else {
      _userId = null;
      _role = null;
      _authenticated = false;
      await authenticationInstance.signOut();
    }
  }

  void setRole(String? role) {
    _role = role;
  }

  Future<Map<String, dynamic>?> getUser() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(_userId).get();

    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<String> signup(
      {required String email,
      required String password,
      required String name,
      required String gender,
      required String role,
      File? image}) async {
    UserCredential authResult;
    try {
      authResult = await authenticationInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      IdTokenResult? idTokenResult = await authResult.user?.getIdTokenResult();

      if (idTokenResult != null) {
        String? token = idTokenResult.token;
        DateTime? issueTime = idTokenResult.issuedAtTime;
        DateTime? customExpirationTime =
            issueTime?.add(const Duration(hours: 2));

        if (token != null && customExpirationTime != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('idToken', token);
          await prefs.setString(
              'expirationTime', customExpirationTime.toIso8601String());
        }
      }

      await requestNotificationPermissions();
      String? token = await messaging.getToken();

      Map<String, dynamic> object = {
        'name': name,
        'email': email,
        // 'dateOfBirth': dateOfBirth,
        'gender': gender,
        'role': role,
        'fcmToken': token,
      };

      if (image != null) {
        var imageName = DateTime.now().millisecondsSinceEpoch.toString();
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('driver_images/$imageName.jpg');
        var uploadTask = storageRef.putFile(image);
        print("uploading");
        var downloadUrl = await (await uploadTask).ref.getDownloadURL();
        print("done");

        object["Image"] = downloadUrl;
      }
      if (role.toLowerCase() == 'vendor') {
        object["stock"] = [];
      } else {
        object["cart"] = [];
      }
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(authResult.user!.uid)
          .set(object);
      _authenticated = true;
      _userId = authResult.user!.uid;
      _role = role;
      // _role = role;
      notifyListeners();
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "email";
      } else {
        return "other";
      }
    } catch (e) {
      // ignore: avoid_print
      print("The error is: ${e.toString()}");
      return "failed";
    }
  }

  Future<String> login(
      {required String email, required String password}) async {
    UserCredential authResult;
    try {
      authResult = await authenticationInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      IdTokenResult? idTokenResult = await authResult.user?.getIdTokenResult();

      if (idTokenResult != null) {
        String? token = idTokenResult.token;
        DateTime? issueTime = idTokenResult.issuedAtTime;
        DateTime? customExpirationTime =
            issueTime?.add(const Duration(hours: 2));

        if (token != null && customExpirationTime != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('idToken', token);
          await prefs.setString(
              'expirationTime', customExpirationTime.toIso8601String());
        }
      }

      _authenticated = true;
      _userId = authResult.user!.uid;
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(_userId);

      await requestNotificationPermissions();

      String? token = await messaging.getToken();
      userDoc.update({
        'fcmToken': token,
      });

      _role = ((await userDoc.get()).data() as Map<String, dynamic>)["role"];
      notifyListeners();
      return "success";
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-email' || e.code == 'invalid-credential') {
        return "incorrect";
      } else {
        return "other";
      }
    } catch (e) {
      // ignore: avoid_print
      print("The error is: ${e.toString()}");
      return "error";
    }
  }

  Future<void> signOut() async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection('Users').doc(_userId).update({
        'fcmToken': FieldValue.delete(),
      });
    }
    _userId = null;
    _role = null;
    _authenticated = false;
    await authenticationInstance.signOut();
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
}
