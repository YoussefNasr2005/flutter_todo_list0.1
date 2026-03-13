import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/customTextFeild.dart';
import 'package:flutter_app/components/CustomElevatedButton.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> fromState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 65, left: 10, right: 10),
          child: Form(
            key: fromState,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/notebook.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 177, 18, 18)
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Register',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 5),
                  Text('Enter Your Personal information',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  CustomTextField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "not vaild!";
                      }
                      return null;
                    },
                    myController: userName,
                    titleBeforeTextFeild: "Username",
                    hint: "Enter Your Username",
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "not vaild!";
                      }
                      return null;
                    },
                    myController: email,
                    titleBeforeTextFeild: "Email",
                    hint: "Enter Your Email",
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "not vaild!";
                      }
                      return null;
                    },
                    myController: password,
                    titleBeforeTextFeild: "Password",
                    hint: "Enter Your Password",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomElevatedButton(
                    onPressed: () async {
                      if (fromState.currentState!.validate()) {
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email.text,
                            password: password.text,
                          );

                          await credential.user!.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Go to your Gmail to verify your account!"),
                            ),
                          );

                          Navigator.of(context).pushReplacementNamed('login');
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: 'Weak password',
                              desc: 'The password provided is too weak.',
                            ).show();
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: 'Email already in use',
                              desc:
                                  'The account already exists for that email.',
                            ).show();
                            print('The account already exists for that email.');
                          }
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        print('not valid!');
                      }
                    },
                    label: "Register",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Do you've an account?",
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('login');
                          },
                          child: Text('Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: const Color.fromARGB(
                                          255, 173, 6, 6))))
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
