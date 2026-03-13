import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/customTextFeild.dart';
import 'package:flutter_app/components/CustomElevatedButton.dart';
import 'package:flutter_app/welcomePage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
          "181974127537-p6gmrboln9ithvv0bqc2l7l47effl7aa.apps.googleusercontent.com",
    );
    final account = await googleSignIn.authenticate();

    if (account == null) return null;

    final googleAuth = account.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> fromState = GlobalKey<FormState>();
  bool isLoading = true;

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
                        color: const Color.fromARGB(255, 87, 48, 48)
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Login', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 5),
                  Text('Login to continue using the app',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
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
                    height: 5,
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () async {
                        if (email.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your email first"),
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password reset email sent"),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = "Something went wrong";

                          if (e.code == 'user-not-found') {
                            message = "No user found with this email";
                          } else if (e.code == 'invalid-email') {
                            message = "Invalid email address";
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                      child: Text(
                        'Forget Password?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  CustomElevatedButton(
                    label: "Login",
                    onPressed: () async {
                      if (fromState.currentState!.validate()) {
                        final auth = FirebaseAuth.instance;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final credential =
                              await auth.signInWithEmailAndPassword(
                            email: email.text.trim(),
                            password: password.text.trim(),
                          );

                          final user = credential.user;

                          if (user != null) {
                            if (user.emailVerified) {
                              Navigator.of(context)
                                  .pushReplacementNamed('welcome');
                            } else {
                              await user.sendEmailVerification();
                              Navigator.of(context).pop();
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                title: 'User not verified',
                                desc: 'Go to your Gmail to verify your email!',
                              ).show();
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          Navigator.of(context).pop();

                          if (e.code == 'user-not-found') {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'User not found',
                              desc: 'No user found for that email.',
                            ).show();
                          } else if (e.code == 'wrong-password') {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Wrong password',
                              desc: 'Wrong password provided for that user.',
                            ).show();
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: e.message ?? 'Something went wrong!',
                            ).show();
                          }
                        }
                      } else {
                        print('Form not valid!');
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text('Or login with',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade400,
                        foregroundColor: Colors.white,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white),
                      ),
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          UserCredential? user = await signInWithGoogle();

                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Welcome ${user.user?.displayName}"),
                              ),
                            );

                            print("Login Success: ${user.user?.email}");

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomePage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Login cancelled")),
                            );
                          }
                        } catch (e) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/Google_icon.png',
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text('Login with Google'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('signup');
                          },
                          child: Text('Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.brown.shade600,
                                  )))
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
