import 'package:flutter/material.dart';
import 'package:para_final/data/methods/firestore_methods.dart';
import 'package:para_final/presentation/pages/home_screen.dart';
import 'package:para_final/presentation/pages/sign_up.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';
import 'package:para_final/presentation/widgets/para_emblem.dart';
import 'package:para_final/presentation/widgets/text_field_widget.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController(),
      _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            emblem,
            TextFieldWidget(
                hinttext: "Username",
                controller: _usernameController,
                onchange: (value) {}),
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            TextFieldWidget(
              hinttext: "Password",
              controller: _passwordController,
              obscured: true,
              onchange: (value) {},
            ),
            // StreamBuilder<UserState>(
            //   stream: userCubit.stream,
            //   builder: (context, snapshot) {
            //     return Text(snapshot.data == null
            //         ? "No Data"
            //         : snapshot.data!.username!);
            //   },
            // ),
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 15)),
                  backgroundColor: MaterialStateProperty.all(Colors.white)),
              onPressed: () async {
                Map<String, dynamic> user = await FirestoreMethods().login(
                    username: _usernameController.text,
                    password: _passwordController.text);
                if (user.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Successfully logged in as: " + user["name"])));
                  Navigator.of(context).push(MaterialPageRoute(
                      settings: RouteSettings(name: "/home_screen"),
                      builder: (context) => HomeScreen(userModel: user)));
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Please wait for the review'),
                      content: const Text(
                          "Sorry, your account is not available this time."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: defaultTextStyle.copyWith(
                        color: Color.fromARGB(255, 14, 159, 179),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                  Icon(
                    Icons.login,
                    color: Color.fromARGB(255, 14, 159, 179),
                    weight: 10,
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            Text(
              "Or",
              textAlign: TextAlign.center,
              style: defaultTextStyle.copyWith(
                color: textColor,
                decorationColor: textColor,
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Text(
                  "Sign up",
                  style: defaultTextStyle.copyWith(
                      color: textColor,
                      decorationColor: textColor,
                      decoration: TextDecoration.underline),
                )),
          ],
        ),
      ),
    );
  }
}
