import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class SingleMessage extends StatelessWidget {
  const SingleMessage({Key? key, required this.message, required this.isMe})
      : super(key: key);
  final String message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
                color: isMe ? AppColors.green : AppColors.orange,
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            child: CustomText(
              text: message,
              txtstyle: tstyle.bodyLarge!.copyWith(color: AppColors.white),
            ))
      ],
    );
  }
}
