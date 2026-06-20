import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    final email = _email.text.trim();
    final password = _password.text;
    if (_isRegister) {
      cubit.register(email, password);
    } else {
      cubit.signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final busy = state.isSubmitting;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App icon
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 88,
                              height: 88,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Brand name
                        Text(
                          'archivo',
                          textAlign: TextAlign.center,
                          style: tt.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Knowledge Vault',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Form heading
                        Text(
                          _isRegister
                              ? 'Create your account'
                              : 'Sign in to your vault',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _email,
                          enabled: !busy,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextFormField(
                          controller: _password,
                          enabled: !busy,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => busy ? null : _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Min 6 characters'
                              : null,
                        ),

                        // Error
                        if (state.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.error!,
                            style: TextStyle(color: cs.error, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Primary CTA
                        FilledButton(
                          onPressed: busy ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isRegister ? 'Create account' : 'Sign in',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: cs.outlineVariant)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ),
                            Expanded(child: Divider(color: cs.outlineVariant)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Google sign-in
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () =>
                                    context.read<AuthCubit>().signInWithGoogle(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4285F4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle register/login
                        TextButton(
                          onPressed: busy
                              ? null
                              : () =>
                                    setState(() => _isRegister = !_isRegister),
                          child: Text(
                            _isRegister
                                ? 'Already have an account? Sign in'
                                : "Don't have an account? Register",
                            style: TextStyle(color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
