import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().login(
        email:
            _emailController.text.trim(),
        password:
            _passwordController.text,
      );

      if (!mounted) return;

      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _loading = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color:
                          Color(0xFF008C95),
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  const Text(
                    'Byenveni 👋',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Konekte pou kòmande manje ou renmen yo.',
                    style: TextStyle(
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  AppTextField(
                    controller:
                        _emailController,
                    label: 'Email',
                    prefixIcon:
                        Icons.email_outlined,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Antre email ou';
                      }

                      if (!value.contains('@')) {
                        return 'Email la pa valid';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  AppTextField(
                    controller:
                        _passwordController,
                    label: 'Modpas',
                    prefixIcon:
                        Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Antre modpas ou';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  AppButton(
                    text: 'Konekte',
                    loading: _loading,
                    onPressed: _login,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go(
                          '/register',
                        );
                      },
                      child: const Text(
                        'Ou poko gen kont? Kreye youn',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}