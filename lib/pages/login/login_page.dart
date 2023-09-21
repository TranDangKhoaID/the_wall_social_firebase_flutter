import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/components/button.dart';
import 'package:social_media_app/components/text_field.dart';
import 'package:social_media_app/helper/dialog.dart';
import 'package:social_media_app/pages/login/cubit/login_cubit.dart';
import 'package:social_media_app/pages/login/cubit/login_state.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: BlocProvider(
            create: (context) => LoginCubit(),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is ErrorState) {
                  Navigator.pop(context);
                  displayMessage(state.errorMessage, context);
                }
                else if(state is LoadingState){
                  showDialog(
                    context: context,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                else if(state is LoggedInState){
                  //pop loading circle
                  if (context.mounted) Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //logo
                      const Icon(
                        Icons.lock,
                        size: 100,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      //welcome
                      Text(
                        "Welcome back, you've been missed",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      //email textfield
                      MyTextField(
                          controller: emailTextController,
                          hintText: 'Email',
                          obscureText: false),
                      const SizedBox(
                        height: 10,
                      ),
                      //password textfield
                      MyTextField(
                          controller: passwordTextController,
                          hintText: 'Password',
                          obscureText: true),
                      const SizedBox(
                        height: 10,
                      ),
                      //sign in button
                      MyButton(
                        onTap: () {
                          final email = emailTextController.text;
                          final password = passwordTextController.text;
                          BlocProvider.of<LoginCubit>(context).signIn(email, password);
                        }, 
                        text: 'Sign In'
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      //go to register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Not a member?",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              "Register now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
