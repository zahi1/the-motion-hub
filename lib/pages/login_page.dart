import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_page.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Motion Hub'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Welcome Banner
            Text(
              "Welcome to The Motion Hub",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's move together! Log in to access your account.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // App Logo
            Image.asset(
              'assets/images/default_profile.png',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            // Email Input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password Input
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Login Button
            ElevatedButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;

                if (email.isEmpty || !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+\$").hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email address.')),
                  );
                  return;
                }
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password cannot be empty.')),
                  );
                  return;
                }
                // Proceed to the main page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainPage()), // Navigate to MainPage
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Sign-Up Prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.purpleAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _currentStep = 0;
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  DateTime? _selectedDate;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _currentStep--;
            });
          },
        )
            : null,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select your birthday.')),
              );
              return;
            }

            final age = DateTime.now().year - _selectedDate!.year;
            if (age < 13) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Not Eligible'),
                  content: const Text(
                    'Sorry, you are not eligible for The Motion Hub... but thanks for checking us out!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
              return;
            }
          }

          if (_currentStep < 4) {
            setState(() {
              _currentStep++;
            });
          } else {
            // Final step, register user
            Provider.of<UserProvider>(context, listen: false).setUser(
              _usernameController.text,
              _fullNameController.text,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()), // Navigate to MainPage
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Birthday'),
            content: TextField(
              controller: _birthdayController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Select your birthday'),
              onTap: () => _selectDate(context),
            ),
            isActive: _currentStep == 0,
          ),
          Step(
            title: const Text('Email'),
            content: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || !value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            isActive: _currentStep == 1,
          ),
          Step(
            title: const Text('Password'),
            content: TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            isActive: _currentStep == 2,
          ),
          Step(
            title: const Text('Username'),
            content: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            isActive: _currentStep == 3,
          ),
          Step(
            title: const Text('Full Name'),
            content: TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            isActive: _currentStep == 4,
          ),
        ],
      ),
    );
  }
}
