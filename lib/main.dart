import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/screens/auth_screen.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> usersignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      UserModel userModel = UserModel.fromJson(userData);
      return HomeScreen( user: userModel,);
    } else {      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
          future: usersignedIn(),
        ));
  }
}
