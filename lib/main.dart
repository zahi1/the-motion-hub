import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/profile_page.dart'; 
import 'providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'The Motion Hub',
        theme: ThemeData(
          brightness: Brightness.dark, // Used dark mode in heree
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.dark,
          ).copyWith(
            secondary: Colors.purpleAccent,
          ),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            color: Colors.deepPurple,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.grey,
          ),
        ),
        initialRoute: '/login', // Start with the LoginPage
        routes: {
          '/login': (context) => const LoginPage(), // LoginPage route
          '/main': (context) => const MainPage(),   // MainPage route
          '/profile': (context) => const ProfilePage(), // ProfilePage route
        },
      ),
    );
  }
}
