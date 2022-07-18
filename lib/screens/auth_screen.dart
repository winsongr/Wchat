import 'package:chatapp/auth_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future signInFunc() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    DocumentSnapshot userExist =
        await firestore.collection('users').doc(userCredential.user!.uid).get();
    if (userExist.exists) {
      print(userCredential.user!.email);
    } else {
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'image': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'date': DateTime.now(),
      });
    }
    Get.offAll(() => AuthCheck());
  }

  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;
    var textscale = Get.textScaleFactor;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: Get.height * 0.2,
              ),
              Container(
                width: Get.width,
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/chat.png'),
                  ),
                ),
              ),
              Text(
                "Chat App",
                textScaleFactor: textscale,
                style: tstyle.titleLarge!.copyWith(color: Colors.green),
              ),
              SizedBox(
                height: Get.height * 0.2,
              ),
              SizedBox(
                  width: Get.width * 0.6,
                  child: ElevatedButton(
                      onPressed: () {
                        signInFunc();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: Row(children: [
                        Image.asset(
                          "assets/google.png",
                          width: 40,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Sign In With Google",
                          textScaleFactor: textscale,
                          style:
                              tstyle.bodyLarge!.copyWith(color: Colors.black),
                        )
                      ]))),
            ],
          ),
        ),
      ),
    );
  }
}
