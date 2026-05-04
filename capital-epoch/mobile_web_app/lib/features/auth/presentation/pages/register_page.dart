import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('注册', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '账号')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: '密码'), obscureText: true),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('返回登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

