import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "이름"),
                validator: (value) =>
                    value!.isEmpty ? "이름을 입력하세요" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "이메일"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.contains("@") ? null : "올바른 이메일을 입력하세요",
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "비밀번호"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "비밀번호는 6자 이상이어야 합니다" : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: "비밀번호 확인"),
                obscureText: true,
                validator: (value) =>
                    value != _passwordController.text ? "비밀번호가 일치하지 않습니다" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("회원가입 성공!")),
                    );
                  }
                },
                child: const Text("가입하기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}