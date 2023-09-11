import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button.dart';
import 'package:social_media_app/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
 
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  //sign up
  void signUp() async {
    //show dia log
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    //make sure password match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      //pop loadinh circle
      Navigator.pop(context);
      //show error
      displayMessage("Passwords don't match!");
    }
    //try creating the user
    try {
      //create the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text, 
        password: passwordTextController.text);

      //after creating the user, create a new document in cloud firebase called User
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
            'username': emailTextController.text.split('@')[0], //inital username
            'bio': 'Empty bio...' //inital empty bio
            //add my additional fields as needed
          });

      //pop loading circle
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      //
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }
  //display a dialog message
  void displayMessage(String message){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const SizedBox(height: 40,),
                  //welcome
                  Text(
                    "Lets create an account for you",
                    style: TextStyle(
                      color: Colors.grey[700]
                    ),
                  ),
                  const SizedBox(height: 25,),
                  //email textfield
                  MyTextField(
                    controller: emailTextController, 
                    hintText: 'Email', 
                    obscureText: false
                  ),
                  const SizedBox(height: 10,),
                  //password textfield
                  MyTextField(
                    controller: passwordTextController, 
                    hintText: 'Password', 
                    obscureText: true
                  ),
                  const SizedBox(height: 10,),
                  //confirm password textfield
                  MyTextField(
                    controller: confirmPasswordTextController, 
                    hintText: 'Confirm Password', 
                    obscureText: true
                  ),
                  const SizedBox(height: 10,),
                  //sign in button
                  MyButton(
                    onTap: signUp,
                    text: 'Sign Up'
                  ),
                  const SizedBox(height: 25,),
                  //go to register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.grey[700]
                        ),
                      ),
                      const SizedBox(width: 4,),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}