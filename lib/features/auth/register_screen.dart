
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmController =
      TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    // Verifye tout chan yo anvan nou voye request la.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verifye password yo menm.
    if (_passwordController.text !=
        _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Modpas yo pa menm.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _phoneController.text.trim(),

        // Password prensipal la
        password: _passwordController.text,

        // Password confirmation lan
        passwordConfirmation:
            _confirmController.text,
      );

      if (!mounted) return;

      // Apre registration reyisi,
      // ale sou Home.
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Yon erè rive: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kreye kont',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const Text(
                  'Kreye kont Resto Kay-Y ou 🍽️',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 30,
                ),

                // NON
                AppTextField(
                  controller:
                      _nameController,

                  label: 'Non konplè',

                  prefixIcon:
                      Icons.person_outline,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Antre non ou';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                // EMAIL
                AppTextField(
                  controller:
                      _emailController,

                  label: 'Email',

                  prefixIcon:
                      Icons.email_outlined,

                  keyboardType:
                      TextInputType.emailAddress,

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

                // TELEFÒN
                AppTextField(
                  controller:
                      _phoneController,

                  label: 'Telefòn',

                  prefixIcon:
                      Icons.phone_outlined,

                  keyboardType:
                      TextInputType.phone,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Antre telefòn ou';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                // PASSWORD
                AppTextField(
                  controller:
                      _passwordController,

                  label: 'Modpas',

                  prefixIcon:
                      Icons.lock_outline,

                  obscureText: true,

                  validator: (value) {
                    if (value == null ||
                        value.length < 6) {
                      return 'Modpas la dwe gen omwen 6 karaktè';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                // CONFIRM PASSWORD
                AppTextField(
                  controller:
                      _confirmController,

                  label: 'Konfime modpas',

                  prefixIcon:
                      Icons.lock_outline,

                  obscureText: true,

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Konfime modpas la';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'Modpas yo pa menm';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 25,
                ),

                // REGISTER BUTTON
                AppButton(
                  text: 'Kreye kont',

                  loading: _loading,

                  onPressed: _register,
                ),

                const SizedBox(
                  height: 15,
                ),

                // LOGIN
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },

                  child: const Text(
                    'Mwen deja gen yon kont',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
