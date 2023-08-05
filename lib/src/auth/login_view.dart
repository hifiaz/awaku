import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/service/provider/states/login_states.dart';
import 'package:awaku/src/auth/signup_view.dart';
import 'package:awaku/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  static const routeName = '/login';
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ref.listen(authenticationProvider, (previous, next) {
      Logger().d('message $next');
      if (next is LoginStateError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Awaku: Record Your Health Body',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                TextField(
                  controller: email,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
                const SizedBox(height: 40),
                Center(
                  child: CustomButton(
                    width: double.infinity,
                    isDisabled: false,
                    title: 'Sign in',
                    onPressed: () => ref
                        .read(authenticationProvider.notifier)
                        .login(email.text, password.text),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have account? '),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupView(),
                        ),
                      ),
                      child: const Text('Signup'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Center(
                //   child: SignInButton(
                //     Buttons.GoogleDark,
                //     onPressed: () => ref
                //         .read(authNotifierProvider.notifier)
                //         .continueWithGoogle(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
