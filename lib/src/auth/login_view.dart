import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/src/auth/signup_view.dart';
import 'package:awaku/src/home/home_item_list_view.dart';
import 'package:awaku/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        authenticated: (user) {
          // Navigate to any screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User Logged In'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeItemListView(),
            ),
          );
          // Navigator.pushNamed(context, HomeItemListView.routeName);
        },
        unauthenticated: (message) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message!),
            behavior: SnackBarBehavior.floating,
          ),
        ),
      );
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
                const CircleAvatar(radius: 50),
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
                    loading: ref
                        .watch(authNotifierProvider)
                        .maybeWhen(orElse: () => false, loading: () => true),
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).login(
                              email: email.text,
                              password: password.text,
                            ),
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
