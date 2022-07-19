import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/widgets/custom_text.dart';
import 'package:chatapp/widgets/message_textfield.dart';
import 'package:chatapp/widgets/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen(
      {Key? key,
      required this.currentUser,
      required this.friendId,
      required this.friendName,
      required this.friendImage})
      : super(key: key);
  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;
  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.network(
                friendImage,
                height: 35,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            CustomText(
                txtstyle: tstyle.titleLarge!
                    .copyWith(fontSize: 20, color: AppColors.white),
                text: friendName)
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('messages')
                  .doc(friendId)
                  .collection('chats')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: CustomText(
                        text: "Say Hi",
                        txtstyle: tstyle.titleMedium!.copyWith(fontSize: 20),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      bool isMe = snapshot.data!.docs[index]['senderId'] ==
                          currentUser.uid;

                      return SingleMessage(
                          message: snapshot.data!.docs[index]['message'],
                          isMe: isMe);
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )),
          MessageTextField(
            friendId: friendId,
            currentId: currentUser.uid,
          )
        ],
      ),
    );
  }
}
