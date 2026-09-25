// lib/features/auth/presentation/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:showmovies/core/widgets/custom_button.dart';
import 'package:showmovies/core/widgets/custom_text_field.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/movies');
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bienvenue",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connectez-vous pour continuer",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Mot de passe",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: "Se connecter",
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                _emailController.text,
                                _passwordController.text,
                              ),
                            );
                          }
                        },
                      );

                      // À ajouter juste sous le CustomButton de connexion dans auth_page.dart
                    },
                  ),

                  SizedBox(height: 16),

                  TextButton(
                    onPressed: () => {
                      if (_formKey.currentState!.validate())
                        {
                          context.read<AuthBloc>().add(
                            AuthRegisterRequested(
                              _emailController.text,
                              _passwordController.text,
                            ),
                          ),
                        },
                    },
                    child: Text("Pas compte ? S'inscrire instantanement"),
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
