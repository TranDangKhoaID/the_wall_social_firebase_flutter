
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/drawer.dart';
import 'package:social_media_app/components/text_field.dart';
import 'package:social_media_app/components/wall_post.dart';
import 'package:social_media_app/helper/helper_methods.dart';
import 'package:social_media_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //text controller
  final textController = TextEditingController();
  //log out
  void signOut(){
    FirebaseAuth.instance.signOut();
  }
  //post message
  void postMessage(){
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],  
      });
    }

    //clear the text
    setState(() {
      textController.clear();
    });
  }

  //navigator to profile page
  void goToProFilePage(){
    //pop mmenu drawer
    Navigator.pop(context);
    //go to
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('The Wall'),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProFilePage,
        onSignout: signOut,
      ),
      body: Column(
        children: [
          //the wall
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy(
                    "TimeStamp",
                    descending: true
                  )
                  .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          //get the message
                          final post = snapshot.data!.docs[index];
                          return WallPost(
                            message: post['Message'], 
                            user: post['UserEmail'], 
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: formatDate(post['TimeStamp']),
                          ); 
                        },
                      );
                    } else if(snapshot.hasError){
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: Center(child: Text('Empty'),),
                    );
                  },
            )
          ),
          //post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: 'Write something on the wall',
                    obscureText: false,
                  )
                ),
                //post button
                IconButton(
                  onPressed: postMessage, 
                  icon: const Icon(Icons.arrow_circle_up)
                )
              ],
            ),
          ),
          //logged in as
          Text("Logged in as: " + currentUser.email!, style: const TextStyle(color: Colors.grey),),
          const SizedBox(height: 30,)
        ],
      )
    );
  }
}