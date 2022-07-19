import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/widgets/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key, required this.user}) : super(key: key);
  UserModel user;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List searchResult = [];
  bool isLoading = false;
  void onSearch() async {
    setState(() {
      searchResult = [];
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where('email'.toLowerCase(),
            isEqualTo: searchController.text.toLowerCase().trim())
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        Get.snackbar("Oh Noo", "No Users Found on this email found",
            snackPosition: SnackPosition.BOTTOM,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10));
        setState(() {
          isLoading = false;
        });
        return;
      }
      for (var user in value.docs) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var tstyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(txtstyle: tstyle.titleSmall!.copyWith(
          color: AppColors.white
        ), text: "Search Chat"),
        backgroundColor: AppColors.green,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(height: 45,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: "Type Username...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      onSearch();
                    },
                    icon: const Icon(Icons.search)),
              )
            ],
          ),
          if (searchResult.length.isGreaterThan(0))
            Expanded(
              child: ListView.builder(
                itemBuilder: ((context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          NetworkImage(searchResult[index]['image']),
                    ),
                    title: CustomText(
                        txtstyle: tstyle.titleMedium!,
                        text: searchResult[index]['name']),
                    subtitle: CustomText(
                        txtstyle: tstyle.bodyMedium!,
                        text: searchResult[index]['email']),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          searchController.text = "";
                        });
                        Get.to(() => ChatScreen(
                            currentUser: widget.user,
                            friendId: searchResult[index]['uid'],
                            friendName: searchResult[index]['name'],
                            friendImage: searchResult[index]['image']));
                      },
                      icon: const Icon(Icons.message),
                    ),
                  );
                }),
                itemCount: searchResult.length,
                shrinkWrap: true,
              ),
            )
          else if (isLoading == true)
            const Center(
                child: CircularProgressIndicator(
              color: AppColors.amber,
            ))
        ],
      ),
    );
  }
}
