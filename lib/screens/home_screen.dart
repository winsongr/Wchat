import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/screens/auth_screen.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/screens/search_screen.dart';
import 'package:chatapp/service/registernotification.dart';
import 'package:chatapp/widgets/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.user}) : super(key: key);
  UserModel user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void configureLocalNotification() {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('chat');

    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "com.winson.chatapp",
      "Wchat",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, remoteNotification.title,
        remoteNotification.body, notificationDetails,
        payload: null);
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        {
          showNotification(message.notification!);
        }
        return;
      }
    });
    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({'pushToken': token});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    registerNotification();
    configureLocalNotification();
  }

  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: CustomText(
            txtstyle: tstyle.titleLarge!.copyWith(color: AppColors.white),
            text: 'Hey 🤞${widget.user.name.trimRight().capitalizeFirst}'),
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => const AuthScreen());
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('messages')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length < 1) {
              return Center(
                child: CustomText(
                    txtstyle: tstyle.titleMedium!, text: "No Chats Found!"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: ((context, index) {
                var friendId = snapshot.data.docs[index].id;
                var lastMsg = snapshot.data.docs[index]['last_msg'];
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(friendId)
                      .get(),
                  builder: (context, AsyncSnapshot asyncsnapshot) {
                    if (asyncsnapshot.hasData) {
                      var friend = asyncsnapshot.data;

                      return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friend['image']),
                          ),
                          title: CustomText(
                              txtstyle: tstyle.titleMedium!,
                              text: friend['name']),
                          subtitle: CustomText(
                            txtstyle: tstyle.titleMedium!
                                .copyWith(color: AppColors.grey),
                            text: lastMsg,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: (() => Get.to(() => ChatScreen(
                              currentUser: widget.user,
                              friendId: friend['uid'],
                              friendName: friend['name'],
                              friendImage: friend['image']))));
                    }
                    return const LinearProgressIndicator();
                  },
                );
              }),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(SearchScreen(user: widget.user));
        },
        backgroundColor: AppColors.red,
        child: const Icon(Icons.search),
      ),
    );
  }
}
