import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/auth/presentation/provider/auth_provider.dart';
import 'package:fleet_flow/common/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: SizedBox(
          width: 300,
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FleetFlow Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                InfoLabel(
                  label: 'Email (manager or dispatcher)',
                  child: TextBox(controller: _emailController),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'Password',
                  child: PasswordBox(
                    controller: _passwordController,
                    revealMode: PasswordRevealMode.peekAlways,
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return AppButton(
                      text: 'Login',
                      isLoading: auth.isLoading,
                      onPressed: () {
                        auth.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
