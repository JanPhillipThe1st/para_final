import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:para_final/presentation/pages/sign_up.dart';
import 'package:para_final/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD3AFEl6TfjeVffU456i1IAxmYehNcUgL8',
      appId: "1:402617973882:android:c8f1d93110f19f5344cfc3",
      messagingSenderId: '402617973882',
      projectId: 'para-transportation',
      storageBucket: 'para-transportation.appspot.com',
    ),
    // options: const FirebaseOptions(
    //   apiKey: 'AIzaSyC1otrAffpEES7P5rWZW7BFAivT6PpZjb4',
    //   appId: "1:322172466330:android:b679d43a17a1ba84a1db23",
    //   messagingSenderId: '322172466330',
    //   projectId: 'para-transportation-5dbce',
    //   storageBucket: 'para-transportation-5dbce.appspot.com',
    // ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 58, 127, 183)),
          useMaterial3: true,
        ),
        home: SplashScreen());
    // home: SignUp());
  }
}
