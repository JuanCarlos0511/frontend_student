/// Success screen shown after registration is submitted.
import 'package:flutter/material.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/presentation/screens/login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 64, color: AppTheme.successGreen),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Solicitud Enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(16)),
                child: const Text(
                  'Tu solicitud ha sido recibida exitosamente. '
                  'Nuestro equipo administrativo validará tu documentación; '
                  'te notificaremos vía correo electrónico una vez que tu cuenta sea activada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.darkText,
                      height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 18, color: AppTheme.mediumGrey),
                  SizedBox(width: 6),
                  Text(
                    'Tiempo estimado: 24-48 horas hábiles.',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.mediumGrey),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('Volver al Inicio de Sesión'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
