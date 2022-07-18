import 'package:chatapp/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        .where('name', isEqualTo: searchController.text)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        Get.snackbar("Oh Noo", "No Users Found ");
        setState(() {
          isLoading = false;
        });
        return;
      }
      value.docs.forEach((user) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Chat")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: "Type Username...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    onSearch();
                  },
                  icon: Icon(Icons.search))
            ],
          ),
          if (searchResult.length.isGreaterThan(0))
            Expanded(
              child: ListView.builder(
                itemBuilder: ((context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      child: Image.network(searchResult[index]['image']),
                    ),
                    title: Text(searchResult[index]['name']),
                    subtitle: Text(searchResult[index]['email']),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.message),
                    ),
                  );
                }),
                itemCount: searchResult.length,
                shrinkWrap: true,
              ),
            )
          else if (isLoading == true)
            Center(
                child: CircularProgressIndicator(
              color: Colors.amber,
            ))
        ],
      ),
    );
  }
}
