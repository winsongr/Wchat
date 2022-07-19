import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/widgets/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Future<Widget> usersignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      UserModel userModel = UserModel.fromJson(userData);
      return HomeScreen(
        user: userModel,
      );
    } else {
      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;
    return FutureBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return SafeArea(
          child: Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/chat.png'),
                CustomText(
                    txtstyle:
                        tstyle.titleLarge!.copyWith(color: AppColors.green),
                    text: "WChat")
              ],
            )),
          ),
        );
      },
      future: usersignedIn(),
    );
  }
}
