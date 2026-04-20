/// Multi-step registration wizard with animated transitions.
///
/// Steps: 1) Email  2) Name/Last name  3) Password  4) Profile photo  5) Voucher (PDF).
/// Uses [RegistrationProvider] for state and upload progress.
///
/// On entry, checks for previous registration data in SharedPreferences.
/// If a previous submission was rejected, shows the reason and offers
/// to reload the data. If password is kept, skips to the photo step.
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_registration/logic/registration_provider.dart';
import 'package:uni_social_student/features/auth_registration/presentation/screens/registration_success_screen.dart';
import 'package:uni_social_student/shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isForward = true;

  late final RegistrationProvider _registrationProvider;

  // Progress bar animation
  late final AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  // Header fade + slide
  late final AnimationController _headerCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  // Form keys – one per text-input step
  final _step0Key = GlobalKey<FormState>(); // Email
  final _step1Key = GlobalKey<FormState>(); // Name
  final _step2Key = GlobalKey<FormState>(); // Password

  // Text controllers
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // File state
  String? _profilePhotoFileName;
  String? _profilePhotoFilePath;
  String? _voucherFileName;
  String? _voucherFilePath;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Tracks whether user chose to keep the previous password
  bool _keepPreviousPassword = false;
  String? _previousPassword;

  static const int _totalSteps = 5;

  static const _steps = [
    _StepMeta(
      title: 'Correo Institucional',
      subtitle: 'Tu email universitario oficial',
      icon: Icons.alternate_email_rounded,
    ),
    _StepMeta(
      title: 'Datos Personales',
      subtitle: 'Cuéntanos cómo te llamas',
      icon: Icons.person_rounded,
    ),
    _StepMeta(
      title: 'Contraseña',
      subtitle: 'Crea una contraseña segura',
      icon: Icons.lock_rounded,
    ),
    _StepMeta(
      title: 'Foto de Perfil',
      subtitle: 'Adjunta una imagen para identificar tu cuenta',
      icon: Icons.account_circle_rounded,
    ),
    _StepMeta(
      title: 'Voucher de Pago',
      subtitle: 'Adjunta tu comprobante de pago',
      icon: Icons.receipt_long_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1 / _totalSteps).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
    _progressCtrl.forward();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1.0,
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _registrationProvider = RegistrationProvider();

    // Reset provider state and check for previous registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registrationProvider.reset();
      _checkPreviousRegistration(_registrationProvider);
    });
  }

  /// Check for previous registration and show appropriate dialog.
  Future<void> _checkPreviousRegistration(RegistrationProvider provider) async {
    await provider.checkPreviousRegistration();
    if (!mounted) return;

    if (provider.hasPendingRequest) {
      _showPendingDialog();
    } else if (provider.hasPreviousRejection) {
      _showRejectionDialog(provider);
    }
  }

  /// Show dialog when there's already a pending registration.
  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: AppTheme.pendingAmber, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Solicitud en revisión',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Text(
          'Ya tienes una solicitud de registro pendiente de revisión. '
          'Te notificaremos cuando sea procesada.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dCtx);
              Navigator.pop(context);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when previous registration was rejected, with option to reload data.
  void _showRejectionDialog(RegistrationProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppTheme.errorRed, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Solicitud devuelta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu solicitud anterior fue devuelta por el siguiente motivo:',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppTheme.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.rejectionReason ?? 'Sin motivo especificado.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.darkText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Puedes cargar tus datos anteriores para ahorrar tiempo al re-enviar.',
              style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearPreviousData();
              Navigator.pop(dCtx);
            },
            child: const Text('Empezar de cero'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              _loadPreviousData(provider);
            },
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: const Text('Cargar datos anteriores'),
          ),
        ],
      ),
    );
  }

  /// Pre-fill form fields with previous data and ask about password.
  void _loadPreviousData(RegistrationProvider provider) {
    final data = provider.previousData;
    if (data == null) return;

    _emailCtrl.text = data['email'] as String? ?? '';
    _firstNameCtrl.text = data['firstName'] as String? ?? '';
    _lastNameCtrl.text = data['lastName'] as String? ?? '';
    _previousPassword = data['password'] as String? ?? '';

    setState(() {});

    // Ask about password
    _showPasswordChoiceDialog();
  }

  /// Dialog asking if user wants to keep or change their password.
  void _showPasswordChoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppTheme.primaryRed, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('¿Qué deseas hacer con tu contraseña?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Text(
          'Puedes mantener la misma contraseña de tu solicitud anterior '
          'o crear una nueva.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              setState(() {
                _keepPreviousPassword = false;
                _passwordCtrl.clear();
                _confirmPasswordCtrl.clear();
              });
              // Stay at step 0 so user reviews data
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Cambiar contraseña'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              setState(() {
                _keepPreviousPassword = true;
                _passwordCtrl.text = _previousPassword ?? '';
                _confirmPasswordCtrl.text = _previousPassword ?? '';
              });
              // Jump to photo step (step 3) – skip password
              _goToStep(3, true);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Mantener contraseña'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _headerCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _registrationProvider.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────

  void _goToStep(int newStep, bool forward) {
    final double target = (newStep + 1) / _totalSteps;
    final double current = (_currentStep + 1) / _totalSteps;
    _progressAnim = Tween<double>(begin: current, end: target).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
    _progressCtrl.forward(from: 0);
    _headerCtrl.forward(from: 0);
    setState(() {
      _isForward = forward;
      _currentStep = newStep;
    });
  }

  void _onContinue() {
    bool valid = false;
    switch (_currentStep) {
      case 0: // Email
        valid = _step0Key.currentState?.validate() ?? false;
      case 1: // Name
        valid = _step1Key.currentState?.validate() ?? false;
      case 2: // Password
        valid = _step2Key.currentState?.validate() ?? false;
      case 3: // Photo
        if (_profilePhotoFilePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Debes adjuntar una foto de perfil (JPG/PNG).'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        valid = true;
      case 4: // Voucher
        if (_voucherFilePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Debes adjuntar el voucher de pago (PDF).'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        _submitRegistration();
        return;
    }
    if (valid) _goToStep(_currentStep + 1, true);
  }

  void _onBack() {
    if (_currentStep > 0) {
      // If user kept password and is going back from photo, skip password step
      if (_keepPreviousPassword && _currentStep == 3) {
        _goToStep(1, false);
        return;
      }
      _goToStep(_currentStep - 1, false);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profilePhotoFileName = result.files.single.name;
        _profilePhotoFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _pickVoucherFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _voucherFileName = result.files.single.name;
        _voucherFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _submitRegistration() async {
    final provider = context.read<RegistrationProvider>();
    final success = await provider.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      profilePhotoPath: _profilePhotoFilePath,
      voucherPath: _voucherFilePath,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const RegistrationSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.message),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Step content builders ───────────────────────────────────────

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: // Email
        return Form(
          key: _step0Key,
          child: CustomTextField(
            controller: _emailCtrl,
            hint: 'correo@universidad.edu',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa tu correo institucional';
              }
              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v.trim())) {
                return 'Formato de correo inválido';
              }
              return null;
            },
          ),
        );

      case 1: // Name
        return Form(
          key: _step1Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _firstNameCtrl,
                hint: 'Nombres',
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tus nombres';
                  if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lastNameCtrl,
                hint: 'Apellidos',
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tus apellidos';
                  if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                  return null;
                },
              ),
            ],
          ),
        );

      case 2: // Password
        return Form(
          key: _step2Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _passwordCtrl,
                hint: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePassword,
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordCtrl,
                hint: 'Confirmar contraseña',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureConfirm,
                  onTap: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                  if (v != _passwordCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        );

      case 3: // Profile photo
        return _buildProfilePhotoStep();

      case 4: // Voucher
        return _buildVoucherStep();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfilePhotoStep() {
    final hasFile = _profilePhotoFileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 170,
            decoration: BoxDecoration(
              color: hasFile
                  ? AppTheme.successGreen.withOpacity(0.06)
                  : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasFile ? AppTheme.successGreen : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: hasFile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIcon(
                        icon: Icons.check_rounded,
                        color: AppTheme.successGreen,
                        bgColor:
                            AppTheme.successGreen.withOpacity(0.15),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _profilePhotoFileName!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca para cambiar',
                        style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIcon(
                        icon: Icons.add_a_photo_outlined,
                        color: AppTheme.primaryRed,
                        bgColor:
                            AppTheme.primaryRed.withOpacity(0.08),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Seleccionar imagen',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, JPEG, PNG o WEBP',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.mediumGrey),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 14, color: AppTheme.primaryRed),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'La foto de perfil es obligatoria para completar el registro.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoucherStep() {
    final hasFile = _voucherFileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _pickVoucherFile,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 170,
            decoration: BoxDecoration(
              color: hasFile
                  ? AppTheme.successGreen.withOpacity(0.06)
                  : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasFile ? AppTheme.successGreen : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: hasFile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIcon(
                        icon: Icons.check_rounded,
                        color: AppTheme.successGreen,
                        bgColor:
                            AppTheme.successGreen.withOpacity(0.15),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _voucherFileName!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca para cambiar',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.mediumGrey),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIcon(
                        icon: Icons.cloud_upload_outlined,
                        color: AppTheme.primaryRed,
                        bgColor:
                            AppTheme.primaryRed.withOpacity(0.08),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Seleccionar archivo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Solo archivos PDF',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.mediumGrey),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 14, color: AppTheme.primaryRed),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'El voucher es obligatorio para completar el registro.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _registrationProvider,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: Consumer<RegistrationProvider>(
          builder: (context, reg, _) {
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Custom app bar ────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20),
                              color: AppTheme.darkText,
                              onPressed: reg.isLoading ? null : _onBack,
                            ),
                            const Expanded(
                              child: Text(
                                'Crear Cuenta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                '${_currentStep + 1} / $_totalSteps',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Animated progress bar ─────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (_, __) => ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progressAnim.value,
                                  minHeight: 4,
                                  backgroundColor: AppTheme.lightGrey,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryRed),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Step dots ─────────────────────
                            Row(
                              children: List.generate(
                                  _totalSteps * 2 - 1, (i) {
                                if (i.isOdd) {
                                  final int leftStep = i ~/ 2;
                                  final bool done =
                                      leftStep < _currentStep;
                                  return Expanded(
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 350),
                                      height: 2,
                                      color: done
                                          ? AppTheme.primaryRed
                                          : Colors.grey.shade200,
                                    ),
                                  );
                                }
                                final int dotIndex = i ~/ 2;
                                return _StepDot(
                                  index: dotIndex,
                                  currentStep: _currentStep,
                                  icon: _steps[dotIndex].icon,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Step header ─────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: FadeTransition(
                          opacity: _headerFade,
                          child: SlideTransition(
                            position: _headerSlide,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _steps[_currentStep].title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkText,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _steps[_currentStep].subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.mediumGrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Step content ────────────────────────
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimatedSwitcher(
                            duration:
                                const Duration(milliseconds: 360),
                            transitionBuilder:
                                _slideTransitionBuilder,
                            child: SingleChildScrollView(
                              key: ValueKey<int>(_currentStep),
                              physics:
                                  const ClampingScrollPhysics(),
                              child:
                                  _buildStepContent(_currentStep),
                            ),
                          ),
                        ),
                      ),

                      // ── Navigation buttons ─────────────────
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 12, 24, 28),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: reg.isLoading
                                    ? null
                                    : _onContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.primaryRed,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppTheme.primaryRed
                                          .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  shadowColor: AppTheme.primaryRed
                                      .withOpacity(0.4),
                                ),
                                child: Text(
                                  _currentStep ==
                                          _totalSteps - 1
                                      ? 'Enviar Solicitud'
                                      : 'Continuar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: reg.isLoading
                                    ? null
                                    : _onBack,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppTheme.mediumGrey,
                                ),
                                child: const Text(
                                  'Regresar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Upload overlay with progress ──────────
                if (reg.isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.88),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryRed,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Enviando solicitud...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Upload progress percentage
                          Consumer<RegistrationProvider>(
                            builder: (_, rp, __) {
                              final pct =
                                  (rp.uploadProgress * 100).toInt();
                              return Text(
                                '$pct %',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.mediumGrey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Directional slide transition for [AnimatedSwitcher].
  Widget _slideTransitionBuilder(
      Widget child, Animation<double> animation) {
    final int? stepKey = (child.key is ValueKey<int>)
        ? (child.key as ValueKey<int>).value
        : null;
    final bool isEntering = stepKey == _currentStep;

    late final Tween<Offset> tween;
    if (isEntering) {
      tween = _isForward
          ? Tween(begin: const Offset(1.0, 0), end: Offset.zero)
          : Tween(begin: const Offset(-1.0, 0), end: Offset.zero);
    } else {
      tween = _isForward
          ? Tween(begin: const Offset(-1.0, 0), end: Offset.zero)
          : Tween(begin: const Offset(1.0, 0), end: Offset.zero);
    }

    return ClipRect(
      child: SlideTransition(
        position: tween.animate(
          CurvedAnimation(
            parent: animation,
            curve: isEntering ? Curves.easeOut : Curves.easeIn,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────

class _StepMeta {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StepMeta(
      {required this.title, required this.subtitle, required this.icon});
}

class _StepDot extends StatelessWidget {
  final int index;
  final int currentStep;
  final IconData icon;
  const _StepDot(
      {required this.index, required this.currentStep, required this.icon});

  @override
  Widget build(BuildContext context) {
    final bool isDone = index < currentStep;
    final bool isActive = index == currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: isActive ? 46 : 34,
      height: isActive ? 46 : 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isDone || isActive ? AppTheme.primaryRed : AppTheme.lightGrey,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.38),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        isDone ? Icons.check_rounded : icon,
        size: isActive ? 22 : 17,
        color: isDone || isActive ? Colors.white : AppTheme.mediumGrey,
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;
  const _VisibilityToggle({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          key: ValueKey<bool>(obscure),
          color: AppTheme.mediumGrey,
          size: 20,
        ),
      ),
      onPressed: onTap,
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _CircleIcon(
      {required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
