/// Login screen – presentation layer.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/auth_registration/presentation/screens/register_screen.dart';
import 'package:uni_social_student/features/home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LoginProvider>();
    final success = await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.message),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.school_rounded,
                      size: 80, color: AppTheme.primaryRed),
                  const SizedBox(height: 16),
                  const Text(
                    'Red Social\nUniversitaria',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                        height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión con tu cuenta institucional',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu correo institucional';
                      }
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                          .hasMatch(value.trim())) {
                        return 'Formato de correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  Consumer<LoginProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleLogin,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppTheme.white))
                            : const Text('Iniciar Sesión'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('¿No tienes cuenta?',
                            style: TextStyle(
                                color: AppTheme.mediumGrey, fontSize: 13)),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _navigateToRegister,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Solicitar registro de cuenta'),
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
