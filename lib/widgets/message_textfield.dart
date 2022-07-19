import 'package:chatapp/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageTextField extends StatefulWidget {
  MessageTextField({Key? key, this.currentId, required this.friendId})
      : super(key: key);
  final String? currentId;
  final String friendId;
  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsetsDirectional.all(8),
      child: Row(
        children: [
          Expanded(
              child: SizedBox(height: 50,
                child: TextField(
            controller: _controller,
            decoration: InputDecoration(
                  hintText: "Type Your Message",
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 0),
                      gapPadding: 10,
                      borderRadius: BorderRadius.circular(30))),
          ),
              )),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              String message = _controller.text;
              _controller.clear();
              if (message.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .collection('chats')
                    .add({
                  "senderId": widget.currentId,
                  "recieverId": widget.friendId,
                  "message": message,
                  "type": "text",
                  "date": DateTime.now(),
                }).then((value) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.currentId)
                      .collection('messages')
                      .doc(widget.friendId)
                      .set({
                    'last_msg': message,
                  });
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(widget.currentId)
                    .collection('chats')
                    .add({
                  "senderId": widget.currentId,
                  "recieverId": widget.friendId,
                  "message": message,
                  "type": "text",
                  "date": DateTime.now(),
                }).then((value) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.currentId)
                      .collection('messages')
                      .doc(widget.friendId)
                      .set({
                    'last_msg': message,
                  });
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.green),
              child: const Icon(
                Icons.send,
                color: AppColors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
