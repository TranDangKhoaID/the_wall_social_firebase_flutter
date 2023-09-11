import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/comment.dart';
import 'package:social_media_app/components/comment_button.dart';
import 'package:social_media_app/components/like_button.dart';
import 'package:social_media_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const WallPost({
    super.key, 
    required this.message, 
    required this.user, 
    required this.time,
    required this.postId, 
    required this.likes
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentController = TextEditingController();

  @override
  void initState() {  
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });

    ///access the document is firebase
    DocumentReference posRef = FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      posRef.update({
        'Likes' : FieldValue.arrayUnion([currentUser.email])
      });
    }else{
      posRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText){
    //write the comment to firestore
    if (commentText.isEmpty) {
      return;
    }
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
          "CommentText": commentText,
          "CommentedBy": currentUser.email,
          "CommentTime": Timestamp.now()
        });
  }
  //show a dialog
  void showCommentDialog(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: "Write a comment.."
          ),        
        ),
        actions: [
          //cancel
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //clear
              _commentController.clear();
            }, 
            child: const Text(
              'Cancel'
            )
          ),
          //post 
           TextButton(
            onPressed: () {
              addComment(_commentController.text);
              Navigator.pop(context);
              //clear
              _commentController.clear();

            }, 
            child: Text(
              "Post",
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, 
        borderRadius: BorderRadius.circular(8)
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 10),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [    
          //wall post
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [     
              //message        
              Text(widget.message),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(
                      color: Colors.grey[400]
                    ),
                  ),
                  Text(
                    " . ",
                    style: TextStyle(
                      color: Colors.grey[400]
                    ),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(
                      color: Colors.grey[400]
                    ),
                  ),
                ],
              )      
            ],
          ),
          const SizedBox(height: 20,),
          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Like
              Column(
                children: [
                  //like button
                  LikeButton(
                    isLiked: isLiked, 
                    onTap: toggleLike
                  ),
                  const SizedBox(height: 5,),
                  //like count
                  Text(widget.likes.length.toString(), style: const TextStyle(color: Colors.grey),),
                ],
              ),
              const SizedBox(width: 10,),
              //comment
              Column(
                children: [
                  //like button
                  CommentButton(
                    onTap: showCommentDialog
                  ),
                  const SizedBox(height: 5,),
                  //like count
                  Text(
                    '0',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20,),
          //comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime",descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //show loading cirlce if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  //return the comment
                  return Comment(
                    text: commentData["CommentText"], 
                    user: commentData["CommentedBy"], 
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
