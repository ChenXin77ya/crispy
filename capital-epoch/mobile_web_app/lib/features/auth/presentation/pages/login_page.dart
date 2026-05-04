import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('登录', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '账号')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: '密码'), obscureText: true),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('进入（Mock）'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('去注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

