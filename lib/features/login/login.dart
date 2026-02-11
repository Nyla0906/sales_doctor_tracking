import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants.dart';
import 'cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.success) {
            context.go(AppRoutes.activity);
            context.read<LoginCubit>().reset(); // qaytib kelganda qayta trigger bo'lmasin
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(
                  labelText: "Username or Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.loading
                          ? null
                          : () {
                        context.read<LoginCubit>().login(
                          userCtrl.text.trim(),
                          passCtrl.text.trim(),
                        );
                      },
                      child: state.loading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("LOGIN"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  debugPrint("GO TO REGISTER");
                  context.push(AppRoutes.register);
                },

                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
